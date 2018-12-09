
## 3.1 运行第一个镜像

```bash
$ docker run debian echo "Hello World"
```

我们可以用以下命令, 请求 Docker 提供一个容器中的 shell:
```bash
$ docker run -i -t debian /bin/bash 
root@622ac5689680:/# echo "Hello from Container-land!" 
Hello from Container-land!
root@622ac5689680:/# exit
exit
```
当中的 -i 和 -t 参数表示我们想要一个附有 tty 的交互会话(interactive session)，/bin/bash 参数表示你想 获得一个 bash shell。当你退出 shell 时，容器就会停止——主进程运行多久，容器就运行 多久。

## 3.2 基本命令

`-h` 参数来设定一个新的主机名(hostname): 
```bash
$ docker run -h CONTAINER_NAME -i -t debian /bin/bash 
root@CONTAINER_NAME:/#
```

我们可以把容器的名称或 ID 作为 `docker inspect` 命令的参数，来获取更多有关某个容器的信息:
```bash
$ docker inspect CONTAINER_NAME
$ docker inspect ––format {{.NetworkSettings.IPAddress}} CONTAINER_NAME
```

`docker diff`可以看到有哪些文件被改动过:
```bash
$ docker diff CONTAINER_NAME
```

Docker 容器使用联合文件系统(UFS)，它允许多个文件系统以层级方式挂载，并 表现为一个单一的文件系统。镜像的文件系统以只读方式挂载，任何对运行中容器的改变 则只会发生在它之上的可读写层。因此，Docker 只需查看最上面的可读写层，便可找出曾 对运行系统所作的所有改变。

最后要为大家介绍的是`docker logs`, 以容器名称作为它的参数，就能得知这个容器里曾经发生过的一切事情:
```bash
$ docker logs CONTAINER_NAME
```

由于 shell 是唯一一个在容器中运行的进程, 执行 `exit` 退出之后, 容器也会同时停止. 这时候如果执行 `docker ps`, 你会发现已经没有任何正在运行的容器了.

`docker ps -a` 它会列出所有容器，包括已经停止的 容器(官方说法是“已退出容器”，exited container)。已退出的容器可以用`docker start` 重启.

如果想删除所有已停止的容器，可以利用 `docker ps -aq -f status=exited` 的结果，结果中包含所有已停止容器的 ID。例如:
```bash
$ docker rm -v $(docker ps -aq -f status=exited)
```
请注意 -v 参数在这里的作用，它意味着当所有由 Docker 管理的数据卷已经 没有和任何容器关联时，都会一律删除。

为了避免已停止的容器的数量不断增加，可以在执行`docker run`的时候加上 `--rm` 参数，它的作用是当容器退出时，容器和相关的文件系统会被一并删掉。

要把容器转成镜像的话，执行`docker commit`即可. 执行`docker commit`时，你需要提供的参数包 括容器的名称(“cowsay”)、新镜像的名称(“cowsayimage”)，以及用来存放镜像的仓库 名称(“test”):
```bash
$ docker commit cowsay test/cowsayimage
d1795abbc71e14db39d24628ab335c58b0b45458060d1973af7acf113a0ce61d
```

命令的返回值是这个镜像的唯一识别码(unique ID)。现在，我们创建了一个能随时使用， 并且已安装 cowsay 的镜像:
```bash
$ docker run test/cowsayimage /usr/games/cowsay "Moo"
```

## 3.3 通过Dockerfile创建镜像

Dockerfile 是一个描述如何创建 Docker 镜像所需步骤的文本文件. 我们先创建一个文件夹和文件:
```bash
$ mkdir cowsay
$ cd cowsay
$ touch Dockerfile
```

然后把下面的内容放入 Dockerfile:
```
FROM debian:wheezy
RUN apt-get update && apt-get install -y cowsay fortune
```

`FROM` 指令指定初始镜像. 所有 Dockerfile 一定要有 FROM 指令作为第一个非注释指令。RUN 指令指 定的 shell 命令，是将要在镜像里执行的。

现在已准备好生成镜像了，在同一目录下执行 docker build 命令:
```bash
$ ls
Dockerfile
$ docker build -t test/cowsay-dockerfile . 
Sending build context to Docker daemon 2.048 kB 
Step 0 : FROM debian:wheezy
 ---> f6fab3b798be
Step 1 : RUN apt-get update && apt-get install -y cowsay fortune
 ---> Running in 29c7bd4b0adc
...
Setting up cowsay (3.03+dfsg1-4) ...
 ---> dd66dc5a99bd
Removing intermediate container 29c7bd4b0adc
Successfully built dd66dc5a99bd
```

创建成功后，就可以与之前一样运行镜像了:
```bash
$ docker run test/cowsay-dockerfile /usr/games/cowsay "Moo"
```

> #### 镜像 容器和联合文件系统
> 为了使大家明白镜像与容器之间的关系，我必须为大家讲解清楚一个 Docker 使用的 核心技术，那就是联合文件系统(有时也称为“联合挂载”)。联合文件系统允许多个 文件系统叠加，并表现为一个单一的文件系统。文件夹中的文件可以来自多个文件系 统，但如果有两个文件的路径完全相同，最后挂载的文件则会覆盖较早前挂载的文 件。Docker 支持多种不同的联合文件系统实现，包括 AUFS、Overlay、devicemapper、 BTRFS及ZFS。具体使用哪种实现取决于你所用的系统，可以通过docker info命令， 查看输出结果中“Storage Driver”的值得知。文件系统是可以变更的，但你必须清楚 你所做的事，以及它所带来的好处和坏处，否则我不建议你这样做。
> Docker 的镜像由多个不同的“层”(layer)组成，每一个层都是一个只读的文件系统。 Dockerfile 里的每个指令都会创建一个新的层，而这个层将位于前一个层之上。当一个 镜像被转化成一个容器时(譬如通过docker run或docker create命令)，Docker引 擎会在镜像之上添加一个处于最上层的可读写文件系统(同时还会对一些配置进行初 始化，如 IP 地址、名称、ID，以及资源使用限制等)。
> 由于不必要的层会使镜像变得臃肿(而且 AUFS 最多只能有 127 个层)，你会发现很多 Dockerfile 都把多个 UNIX 命令放在同一个 RUN 指令中，以减少层的数量。
> 容器可以处于以下几种状态之一:已创建(created)、重启中(restarting)、运行中 (running)、已暂停(paused)和已退出(exited)。“已创建”指容器已通过 docker create 命令初始化，但未曾启动。很多时候“已退出”也称为“已停止”，指容器中 没有正在运行的进程(虽然“已创建”状态的容器也没有正在运行的进程，但“已退 出”的容器至少启动过一次)。容器的主进程退出时，容器也会退出。“已退出”的容 器可以用docker start命令重启。已停止的容器不等于一个镜像，因为前者还会保留 对配置、元数据和文件系统的改动。“重启中”状态实际上很少遇见，当 Docker 引擎  尝试重启一个启动失败的容器时，它才会出现。

通过利用 Dockerfile 的 `ENTRYPOINT` 指令，我们可以让用户更易于使用这个镜像。 `ENTRYPOINT` 指令让我们指定一个可执行文件，同时还能处理传给 `docker run` 的参数。
在 Dockerfile 的最后加上下面这一行: 
```
ENTRYPOINT ["/usr/games/cowsay"]
```
现在再次生成新镜像，以后使用这个新镜像时再也不需要指定 `cowsay` 命令了:
```bash
$ docker build -t test/cowsay-dockerfile . ...
$ docker run test/cowsay-dockerfile "Moo" ...
```
这样确实简单多了。可是，我们却失去了将容器中 fortune 命令的输出作为 `cowsay` 输入的 能力。为了解决这个问题，我们可以把 `ENTRYPOINT` 指定为一个我们自己的脚本，这种做法 在创建 Dockerfile 时是很常见的。现在创建一个新文件 entrypoint.sh，把下面的内容放入文 件中，并保存至 Dockerfile 的同一目录下:
```bash
#!/bin/bash
if [ $# -eq 0 ]; then
	/usr/games/fortune | /usr/games/cowsay
else
	/usr/games/cowsay "$@"
fi
```
还需要用 `chmod +x entrypoint.sh` 把文件设为可执行。

下一步需要更改 Dockerfile，使它把这个 脚本放进镜像中，并且通过 `ENTRYPOINT` 指令调用它。现在修改 Dockerfile 如下:
```
FROM debian
RUN apt-get update && apt-get install -y cowsay fortune
COPY entrypoint.sh / 
ENTRYPOINT ["/entrypoint.sh"]
```

`COPY` 指令所做的仅仅是把一个文件从主机复制到镜像的文件系统，第一个参数是主机 的文件，第二个参数是目标路径，这与 `cp` 命令类似。

## 3.4 使用寄存服务

`docker pull amouat/revealjs:latest` 是指从Docker Hub的amouat/revealjs 仓库下载标签为 latest 的镜像。

如果镜像名称以字符串和 / 开头，如 amouat/revealjs，那么它属于“用户”命 名空间(“user”namespace)。Docker Hub 上的这些镜像都上传自某个用户。

诸如 debian 或 ubuntu 的名称，不包含前缀或 /，属于“根”命名空间(“root” namespace)。它由 Docker 公司所控制，为一些常用的软件及发行版预留在 Docker Hub 上发布的官方镜像。

以主机名或 IP 开头的名称，代表该镜像来自第三方的寄存服务(并非 Docker Hub)，包括公司或组织自己搭建的寄存服务.

## 3.5 使用Redis官方镜像

首先获取镜像:
```
$ docker pull redis
```

启动 Redis 容器: 
```
$ docker run --name myredis -d redis
585b3d36e7cec8d06f768f6eb199a29feb8b2e5622884452633772169695b94a
```

`-d` 参数让容器在后台运行, 会把容器的输出打印出来, 只会返回容器 ID，然后就会退出。可以通过 docker logs 命令查看容器的输出。

启动一个新的容器来运行 redis-cli，并把这两个容器连接上: 
```bash
$ docker run --rm -it --link myredis:redis redis /bin/bash 
root@ca38735c5747:/data# redis-cli -h redis -p 6379 
redis:6379> ping
PONG
redis:6379> set "abc" 123 OK
redis:6379> get "abc" "123"
redis:6379> exit 
root@ca38735c5747:/data# exit 
exit
```

`docker run`命令的`--link myredis:redis`参数告诉 Docker 把新容器与现存的“myredis”容器连接起来，并且在新容器以“redis”作为“myredis”容器的主机名。为了实现这一点，Docker 会在新容器中的 `/etc/hosts` 里添加一个新条目，把“redis”指向“myredis”的 IP 地址。这样就能够在执行 redis-cli 的时候直接使用“redis”作为主机名，而不需想办法找出或传递 Redis 容器的 IP 地址给 redis-cli。

数据卷是直接在主机挂载的文件或目录，不属于常规联合文件系统的一部分。这意 味着它们允许与其他容器共享，而任何修改都会直接发生在主机的文件系统里。声明一个 目录为数据卷有两种方法，第一种是在 Dockerfile 里使用 `VOLUME` 指令，第二种是在执行 `docker run` 的时候使用 `-v` 参数。下列的 Dockerfile 指令以及 `docker run` 命令，都会在容器中的 /data 创建一个数据卷:
```
VOLUME /data
```
以及
```bash
$ docker run -v /data test/webserver
```

默认情况下，目录或文件会挂载在主机的 Docker 安装目录之下(通常是 `/var/lib/docker/`)。 执行 `docker run` 命令的时候可以指定用于挂载的主机目录(例如 `docker run -d -v /host/ dir:/container/dir test/webserver`)。出于可移植性和安全方面的考虑，主机目录是无法 在 Dockerfile 中指定的(该文件或目录在其他系统中可能不存在，而容器不应在未获得明 确授权的情况下挂载敏感文件，譬如 etc/passwd)。

为正在运行的 Redis(myredis) 容器做备份: 
```bash
$ docker run --rm -it --link myredis:redis redis /bin/bash 
root@09a1c4abf81f:/data# redis-cli -h redis -p 6379 
redis:6379> set "persistence" "test"
OK
redis:6379> save
OK
redis:6379> exit 
root@09a1c4abf81f:/data# exit 
exit
$ docker run --rm --volumes-from myredis -v $(pwd)/backup:/backup debian cp /data/dump.rdb /backup/
$ ls backup 
dump.rdb
```

这里用 `-v` 参数挂载一个主机上已知的目录，并通过 `--volumes-from` 将新容器连接至 Redis 数据库目录。

myredis 容器使用完毕后，可以把它停止并删掉:
```bash
$ docker stop myredis myredis
$ docker rm -v myredis myredis 
```
所有剩下的容器都可以这样删掉:
```bash
$ docker rm $(docker ps -aq) 45e404caa093
e4b31d0550cd
7a24491027fc
...
```

### 4.2.4 基础镜像
alpine 镜像, 它的大小仅仅 5MB 多一点.

### 4.2.5 Dockerfile指令

Dockerfile 的注释方法是 以 # 作为一行的开头。

> #### Exec 与 Shell 格式的对比
> 一些指令(RUN、CMD 以及 ENTRYPOINT)能够接受 shell 和 exec 这两种格 式。exec格式需要用到一个JSON数组(例如，["executable", "param1", "param2"])，其中第一个元素是一个可执行文件，其他元素是它执行时所使 用的参数。Shell 格式使用的是自由形式的字符串，字符串会传给 /bin/sh -c 执行。exec 格式适用于需要规避 shell 对字符串作出错误解析的情况，或者 当镜像里没有包含 /bin/sh 时。

以下列出的是 Dockerfile 的可用指令: 

* `ADD`: 从构建环境的上下文或远程 URL 复制文件至镜像。如果是从一个本地路径添加一个归 档文件，那么它会被自动解压。由于 ADD 指令涵盖的功能相当广泛，一般最好还是使用 相对简单的 COPY 指令来复制构建环境上下文的文件和目录，并用 RUN 指令配合 curl 或 wget 来下载远程资源(这样还可以在同一个指令中处理和删除下载文件)。
* `CMD`: 当容器启动时执行指定的指令。如果还定义了 `ENTRYPOINT` ，该指令将被解释为 `ENTRYPOINT` 的参数(在这种情况下，请确保使用的是 exec 格式)。`CMD` 指令也会被 `docker run` 命令中镜像名称后面的所有参数覆盖。假如定义了多个CMD指令，那么只有 最后一个生效，前面出现过的 CMD 指令全部无效(包括出现在基础镜像中的那些)。
* `COPY`: 用于从构建环境的上下文复制文件至镜像。它有两种形式，`COPY src dest` 以及 `COPY ["src", "dest"]`，两者皆从上下文中的 src 复制文件或目录至容器内的 dest。如果路 径中有空格的话，那么必须使用 JSON 数组的格式。通配符可以用来指定多个文件或 目录。请注意，你不能指定上下文以外的 src 路径(例如`../another_dir/myfile`不管用的)。
* `ENTRYPOINT`: 设置一个于容器启动时运行的可执行文件(以及默认参数)。任何 `CMD` 指令或 `docker run` 命令中镜像名称之后的参数，将作为参数传给这个可执行文件。`ENTRYPOINT` 指令通常用于提供“启动”脚本，目的是在解析参数之前，对变量和服务进行初始化。
* `ENV`: 设置镜像内的环境变量。这些变量可以被随后的指令引用。例如:
```
...
ENV MY_VERSION 1.3
RUN apt-get install -y mypackage=$MY_VERSION
...
```
在镜像中这些变量仍然可用。
* `EXPOSE`: 向 Docker 表示该容器将会有一个进程监听所指定的端口。提供这个信息的目的是用 于连接容器(参见4.4节)或在执行`docker run`命令时通过-P参数把端口发布开来; `EXPOSE` 指令本身并不会对网络有实质性的改变。
* `FROM`: 设置 Dockerfile 使用的基础镜像; 随后的指令皆执行于这个镜像之上。基础镜像以“镜像:标签”(IMAGE:TAG)的格式表示(例如 debian:wheezy)。如果省略标签，那么就被视为最新(latest)，但我强烈建议你一定要给标签设置为某个特定版本，以免出现任何意想不到的事情。`FROM` 必须为 Dockerfile 的第一条指令。
* `MAINTAINER`: 把镜像中的“作者”元数据设定为指定的字符串。可以通过 `docker inspect -f {{.Author}} IMAGE` 这个命令来查看该信息。这个指令通常用于设置镜像维护者的姓名和联系方式。
* `ONBUILD`: 指定当镜像被用作另一个镜像的基础镜像时将会执行的指令。对于处理一些将要添加到子镜像的数据，这个指令将会非常有用(例如，把代码从一个已选定的目录中复制出来，并在执行构建脚本时使用它)。
* `RUN`: 在容器内执行指定的指令，并把结果保存下来。
* `USER`: 设置任何后续的 `RUN`、`CMD` 或 `ENTRYPOINT` 指令执行时所用的用户(用户名或 UID)。请注意，UID 在主机和容器中是相同的，但用户名则可能被分配到不同的 UID，导致设置权限时变得复杂。
* `VOLUME`: 指定为数据卷的文件或目录。如果该文件或目录已经在镜像中存在，那么当容器启动时，它就会被复制至这个卷。如果提供了多个参数，那么就会被解释成多个数据卷。出于对可移植性和安全性的考虑，你不能在 Dockerfile 中指定数据卷将会使用的主机目录。更多相关信息参见 4.5 节。
* `WORKDIR`: 对任何后续的 RUN、CMD、ENTRYPOINT、ADD 或 COPY 指令设置工作目录。这个指令可多次使用。支持使用相对路径，按上次定义的 WORKDIR 解析。

## 4.3 使容器与世界相连

通过 `-p` 或 `-P` 选项来“发布”端口。这个命令能够将主机的端口转发到容器上: 
```bash
$ docker run -d -p 8000:80 nginx
```

`-p 8000:80` 参数告诉Docker将主机的8000端口转发至容器的80端口。或者，可以使用 `-P` 选项来告诉 Docker 自动选择一个主机上未使用的端口。例如:
```bash
$ ID=$(docker run -d -P nginx) 
$ docker port $ID 80 0.0.0.0:32771
$ curl localhost:32771
```

`docker port`命令可以找出被Docker分配的端口。

## 4.4 容器互联

连接的初始化是通过执行 `docker run` 命令时传入 `--link CONTAINER:ALIAS` 参数 ，其中 CONTAINER 是目标容器的名称，而 ALIAS(别名)是主容器用来称呼目标容器的一个本地名称。 使用 Docker 的连接也会把目标容器的别名和 ID 添加到主容器中的 `/etc/hosts`，允许主容器通过名称找到目标容器。

Docker 还会在主容器内设置一系列的环境变量，目的是为了更方便与目标容器通信。 Docker 还导入了目标容器的环境变量，并在它们的名字前面加上 CONTAINER_NAME_ENV。

功能目前还有一些不足之处。其中最大的不足也许就是连接只能是静态的。虽然连接在容器重启之后应该还能工作，但如果目标容器被替换了，连接是不会更新的。此外，目标容器必须在主容器之前启动，这意味着双向连接是不可能的。

## 4.5 利用数据卷和数据容器管理数据

总共有三种不同的方法进行数据卷的初始化.

1. 可以在执行 Docker 时，通过 `-v` 选项来宣告一个数据卷:
```bash
$ docker run -it --name container-test -h CONTAINER -v /data debian /bin/bash 
root@CONTAINER:/# ls /data 
root@CONTAINER:/#
```
容器中的 /data 目录便成为了一个数据卷。镜像的 /data 目录中的所有文件将被复制到数据卷内。我们可以在主机上打开一个新的shell，通过执行`docker inspect`命令，找出 数据卷在主机上的实际位置:
```bash
$ docker inspect -f {{.Mounts}} container-test
[{5cad... /mnt/sda1/var/lib/docker/volumes/5cad.../_data /data local true}]
```
容器的 `/data/` 卷仅仅是一个指向主机中 `/var/lib/docker/volumes/5cad.../_data` 目录的连接

2. 设置数据卷的第二种方法是通过在 Dockerfile 中使用 `VOLUME` 指令: 
```
FROM debian:wheezy
VOLUME /data
```
这个做法与执行 `docker run` 时提供 `-v /data` 参数的效果是相同的。

> Dockerfile 中 `VOLUME` 指令之后的所有指令不可以对该数据卷有任何修改.

3. 第三种方法将`docker run`命令的`-v`选项用法进行扩展，使到能够具体指明数据卷要绑定的主机目录，命令格式为`-v HOST_DIR:CONTAINER_DIR`(其中`HOST_DIR`为主机目录， `CONTAINER_DIR`为容器目录): 
```bash
$ docker run -v /home/adrian/data:/data debian ls /data
```

这个例子把主机的 /home/adrian/data 目录挂载到容器的 /data 目录。容器能够使用 /home/adrian/data 目录中已有的任何文件。如果容器已经有 /data 目录，它的内容将会被数据卷所隐藏。与先前的几个命令不同，这次并没有文件会从镜像复制到数据卷，而卷也不会被 Docker删除(换句话说，假如数据卷是挂载到一个用户选定的目录的话，那么`docker rm -v`是不会把它删除的)。

### 4.5.1 共享数据

另一种容器间共享数据的方法是，在运行`docker run`命令时，传入`--volumes-from CONTAINER` 参数: 
```bash
$ docker run -it -h NEWCONTAINER --volumes-from container-test debian /bin/bash
```

> 与卷关联的那个容器(在刚才的例子中，就是 container-test)无论正在运行与否，刚才的命令都能使用。只要至少存在着一个容器与卷关联，那么卷就不会被删除。

### 4.5.2 数据容器

用以下命令，为 PostgreSQL 数据库创建一个数据容器:
```bash
$ docker run --name dbdata postgres echo "Data-only container for postgres"
```
这个命令将从 postgres 镜像创建一个容器，并且初始化镜像中定义的所有数据卷，最后执行 echo 命令并退出。

现在便可以通过 `--volumes-from` 参数 ，使其他容器也能够使用这个数据卷。例如:
```bash
$ docker run -d --volumes-from dbdata --name db1 postgres
```

数据卷只会在满足以下条件的时候被删除:

* 容器被 `docker rm -v` 命令删除，或
* `docker run` 命令执行时带有 `--rm` 选项 
以及
* 目前没有容器与该数据卷关联
* 该数据卷没有被指定使用主机目录(即没有使用 -v HOST_DIR:CONTAINER_DIR 语法)


### 4.6.1 run命令

### 4.6.2 容器管理

`docker attach [OPTIONS] CONTAINER` attach 命令允许用户查看容器内的主进程，或与它进行交互。例如:
```bash
$ ID=$(docker run -d debian sh -c "while true; do echo 'tick'; sleep 1; done;") 
$ docker attach $ID
tick
tick
tick 
tick
```
这时候，如果你按下 CTRL-C 中断命令的话，不但进程会结束，还会导致容器退出。

`docker create` 从镜像创建容器，但不启动它。与docker run大部分参数相同。`docker start`命令可以用来启动容器。

`docker cp` 在容器和主机之间复制文件和目录。

`docker exec` 在容器中运行一个命令。可用于执行维护工作，或替代 SSH 用作登入容器。

例如:
```bash
$ ID=$(docker run -d debian sh -c "while true; do sleep 1; done;") 
$ docker exec $ID echo "Hello"
Hello
$ docker exec -it $ID /bin/bash
root@5c6c32041d68:/# ls
bin   dev  home  lib64  mnt  proc  run   selinux  sys  usr boot  etc  lib   media  opt  root  sbin  srv    tmp  var
root@5c6c32041d68:/# exit
exit
```

`docker kill` 发送信号给容器中的主进程(PID 1)。默认发送 SIGKILL 信号，这将导致容器立即退出。另外，发送的信号可以通过 -s 选项指定。该命令会返回容器的 ID。

例如:
```bash
$ ID=$(docker run -d debian bash -c  "trap 'echo caught' SIGTRAP; while true; do sleep 1; done;")
$ docker kill -s SIGTRAP $ID 
e33da73c275b56e734a4bbbefc0b41f6ba84967d09ba08314edd860ebd2da86c 
$ docker logs $ID
caught
$ docker kill $ID 
e33da73c275b56e734a4bbbefc0b41f6ba84967d09ba08314edd860ebd2da86c
```

`docker pause` 暂停容器内的所有进程。进程不会接收到关于它们被暂停的任何信号，因此它们无法执行正常结束或清理的程序。进程可以通过 `docker unpause` 命令重启。`docker pause` 的底层利用 Linux 的 cgroup freezer 功能实现。这个命令与 `docker stop` 不同，`docker stop` 会将所有进程停止，并对进程发送信号，让它们察觉得到。

`docker restart` 重新启动一个或多个容器。大致相当于先对容器执行 `docker stop`，然后执行 `docker start`。`-t` 为一个可选参数，它指定一个等待时间，即容器被 SIGTERM 信号杀掉之前， 让容器有多少时间关闭。

`docker rm` 删除一个或多个容器。返回值是删除成功的容器名称或ID。默认情况下，`docker rm`不 会删除任何数据卷。`-f` 参数可以用来删除运行中的容器，而 `-v` 参数会删除由容器创建的数据卷(只要它们不是绑定挂载，或正被其他容器使用)。

> #### 绑定挂载
> 使用数据卷时特别指明主机目录(即使用了`-v HOST_DIR:CONTAINER_DIR`这个语法)，这个做法一般被称为绑定挂载(Bind Mounting)。这个说法多少会令人误解，因为从技术上而言，所有数据卷都是绑定挂载的，不同的是该挂载点的位置是具体指定的，而不是藏于某个 Docker 管理的目录下。

例如，要删除所有已停止的容器:
```bash
$ docker rm $(docker ps -aq)
```

`docker start` 启动一个或多个已停止的容器。可以用来重新启动已退出的容器，或启动由 `docker create` 创建但从未启动的容器.

`docker stop` 停止(但不删除)一个或多个容器。对容器执行`docker stop`后，它的状态将转变为 “已退出”。`-t` 为一个可选参数，它指定一个等待时间，即容器被 SIGTERM 信号杀掉之前，让容器有多少时间关闭 。

> #### 从容器分离
> 如果你正连接到一个 Docker 容器，无论容器是以交互模式启动，还是通过使用`docker attach`，当你试图以CTRL-C断开时，容器也会同时停止。但如果使用 CTRL-P CTRL-Q的 话，就可以从容器分离，而不会停止容器。 这个方法只有在附有 TTY 的交互模式下才有效(即同时使用了 `-i` 和 `-t` 选项)。


### 4.6.3 Docker信息

`docker info` 打印 Docker 系统和主机的各种信息。 

`docker help` 把一个子命令作为参数，打印有关该子命令的使用方法和帮助信息。相当于运行命令时 提供 `--help` 参数。

`docker version` 打印 Docker 客户端和服务器版本，以及编译时使用的 Go 版本。


### 4.6.4 容器信息

`docker diff` 对比容器所使用的镜像，显示容器的文件系统的变化。例如:
```bash
$ ID=$(docker run -d debian touch /NEW-FILE) 
$ docker diff $ID
```

`docker events` 打印守护进程的实时事件。键入 Ctrl-C 退出。

`docker inspect` 把容器或镜像作为参数，获取它们的详细信息。这些信息包括大部分配置信息、联网设置以及数据卷的映射信息 。这个命令接受 `-f` 参数，让用户提供一个 Go 模板，对输出结果进行格式编排和信息过滤。

`docker logs` 输出容器的“日志”，也就是曾经输出到容器中的 STDERR 或 STDOUT 的内容。

`docker port` 把容器作为参数，列出它的端口映射信息。还可以指定要查看的容器内部端口和协议。常用于执行 `docker run -P <image>` 命令之后查看已分配的端口。

`docker ps` 提供关于当前容器的高阶信息，例如名称、ID和状态。这个命令支持很多不同参数，其中值得一提的是 `-a` 参数，它可以用来获取所有容器的信息，而不仅仅是运行中的容器。还有`-q`参数，它使得这个命令只返回容器的ID，对于用作其他命令如`docker rm` 的输入非常有用。

`docker top` 把容器作为参数，提供该容器内运行中进程的信息。实际上，这个命令是在主机上运行 UNIX 的 `ps` 命令，然后把容器以外的进程过滤掉。这个命令接受与 `ps` 命令相同的参数，默认为 `-ef`(但请注意，PID 字段必须出现在输出里)。

### 4.6.5 镜像管理

`docker build` 从 Dockerfile 建立镜像。

`docker commit` 从指定的容器创建镜像。虽然`docker commit`在创建镜像时很有用，但由于`docker build`的可重复性强，因此一般情况下还是比较推荐使用后者。默认情况下，容器在创建镜像前会先暂停，但这个行为可以用 `--pause=false` 选项禁止。这个命令接受 `-a` 和 `-m` 参数来设定元数据。

`docker export` 将容器的文件系统中的内容以 tar 归档的格式导出，并输出到 STDOUT。生成的归档可以通过docker import导入。请注意，它只会导出文件系统;任何元数据，如映射端口、CMD 和 ENTRYPOINT 配置将会丢失。另外，数据卷也不会包含在导出归档中。你可以将这个命令与 `docker save` 作对比。

`docker history` 输出镜像中每个镜像层的信息。

`docker images` 列出所有本地镜像，包括库名称、标签名称以及镜像大小等信息。	这个命令能够接受几个参数，尤其值得一提的是 `-q`，它使命令只返回镜像 ID，方便用作其他命令如 `docker rmi` 的输入。
 如要删除所有被遗留的镜像(dangling image)11，可以使用以下命令: 
 ```bash
 $ docker rmi $(docker images -q -f dangling=true)
 ```

`docker import` 从一个含有文件系统的归档文件创建镜像，归档可以由docker export产生。归档可以通过文件路径或 URL 指定，或者通过 STDIN 流导入(使用“-”参数)。命令的返回值是新创建镜像的 ID 。可以通过提供仓库和标签名称来为镜像附加标签。要注意的是， 通过 import 生成的镜像只会有一个镜像层，并会失去所有的 Docker 配置信息，如已指定为开放的端口和 CMD 指令的值。你可以将这个命令与 `docker load` 相比较。
下面的例子用先导出后导入的方法，将一个镜像原来所有的镜像层合为一个。
```bash
$ docker export 35d171091d78 | docker import - flatten:test 
5a9bc529af25e2cf6411c6d87442e0805c066b96e561fbd1935122f988086009
$ docker history flatten:test
IMAGE CREATED CREATED BY SIZE COMMENT 
981804b0c2b2 59 seconds ago 317.7 MB Imported from -
```

`docker load` 加载仓库，仓库以 tar 归档的形式从 STDIN 读入。仓库可以包含数个镜像和标签 。与 `docker import` 不同，该镜像还包含历史和元数据。适用的归档文件可以通过 `docker save` 创建，这使得 save 和 load 能成为寄存服务器以外用于分发镜像及备份的方案。

`docker rmi` 删除指定的一个或多个镜像。镜像可以用 ID 或仓库加标签名称的方式来指定。如果指定了仓库名称，但没有提供标签名，那么标签会被默认为 latest。要删除存在于多个仓库的镜像，需要用 ID 指定镜像，并同时使用 `-f` 参数，而且需要对每个仓库分别执行。

`docker save` 把指定的镜像或仓库储存到 tar 归档，并输出到 STDOUT(如要写入文件，可以使用 `-o` 选项)。镜像可以用 ID 或 `repository:tag` 方式指定。如果只指定了仓库名称，则该仓库中的所有镜像将会被储存到归档，而不仅仅是带 `latest` 标签的镜像。与 `docker load` 结合使用，可以用来分发或备份镜像。 例如: 

```bash
$ docker save -o /tmp/redis.tar redis:latest
$ docker rmi redis:latest
Untagged: redis:latest
Deleted: 868be653dea3ff6082b043c0f34b95bb180cc82ab14a18d9d6b8e27b7929762c 
...
$ docker load -i /tmp/redis.tar 
$ docker images redis
```

`docker tag` 将镜像与一个仓库和标签名称关联。镜像可以通过 ID 或仓库加标签的方式指定(如未供标签名，默认为 latest )。如果没有为新名称提供标签，也默认为 latest.

例如:
```bash
$ docker tag faa2b75ce09a newname ➊
$ docker tag newname:latest amouat/newname ➋
$ docker tag newname:latest amouat/newname:newtag ➌
$ docker tag newname:latest myregistry.com:5000/newname:newtag ➍
```

➊ 把 ID 为 faa2b75ce09a 的镜像添加到仓库 newname，因为没有指定标签名，所以标签 默认为 latest。

➋ 把 newname:latest 镜像添加到 amouat/newname 仓库，这一次也是使用 latest 标签。 这个名称的格式适用于把镜像推送到 Docker Hub，假设用户为 amouat。

➌ 与上一个命令一样，除了标签不再是 latest，而是 newtag。

➍ 将 newname:latest 镜像添加到 myregistry.com/newname 仓库，并使用 newtag 作为标签。 这个名称的格式适用于把镜像推送到位于 http://myregistry.com:5000 的寄存服务器。

### 4.6.6 使用寄存服务器

Docker 把用户 凭证保存在你的主目录中的 `.dockercfg` 文件.

`docker login` 在指定的寄存服务器进行注册或登录。如果未指定服务器，则假设为 Docker Hub。如果有需要，程序将会要求你提供一些详细信息，你也可以通过参数提供这些信息。

`docker logout` 从 Docker 寄存服务器注销。如果未指定服务器，则假定为 Docker Hub。 

`docker pull` 从寄存服务器下载指定的镜像。寄存服务器由镜像名称决定，默认为 Docker Hub。若 没有提供标签名，则下载标签为 latest 的镜像(如该标签可用)。通过 -a 参数可以下载仓库中所有镜像。

`docker push` 将镜像或仓库推送到寄存服务器。如果没有指定标签，则仓库中的所有镜像都会推送到服务器，而不仅仅是标记为 latest 的镜像。

`docker search` 列出 Docker Hub 上匹配搜索词的公共仓库。限制结果为最多 25 个仓库。过滤条件还可以包括最低星级以及镜像是否自动生成。通常，在网站上搜索会是最便利的。


# 5 在开发中应用Docker

Dockerfile 文件描述如下: 

```
FROM python:3.4
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi 		# 添加用户和用户组
RUN pip install Flask==0.10.1 uWSGI==2.0.8    			# 使用 pip 安装python包
WORKDIR /app 											# 切换容器工作目录
COPY app /app 											# 将主机当前目录下的 app 目录复制到容器 /app 目录下
EXPOSE 9090 9191 										# 容器开放 9090 和 9191 端口
USER uwsgi 												# 设置容器当前执行用户为 uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", "--callable", "app", "--stats", "0.0.0.0:9191"]
```

执行以下命令创建python应用: 
```bash
$ docker build -t identidock . # 构建docker镜像
$ docker run -d -P --name port-test identidock  # 根据镜像(identidock)创建容器 port-test
$ docker port port-test 
9090/tcp -> 0.0.0.0:32769 
9191/tcp -> 0.0.0.0:32768
```

这么做有个问题，即使代码只有少许改变，我们也需要重新创建镜像，并且重启容器。有一个简单的解决方法。我们可以把主机上的源码目录绑定挂载(bind mount)到容器内的源码目录之上:
```bash
$ docker run -d -P -v "$PWD"/app:/app identidock
```

`-v "$PWD"/app:/app`参数把位于当前目录下的`app`目录挂载到容器内。它将覆盖容器中`/app`目录的内容。参数 `-v` 必须是绝对路径。
