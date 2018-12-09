
## 3.5 使用Redis官方镜像

删除容器:
```bash
docker rm $(docker ps -aq)
```

```bash
# 后台运行一个redis服务
$ docker run --name myredis -d redis 

# 新创建一个容器连接到 myredis
$ docker run --rm -it --link myredis:redis redis /bin/bash root@ca38735c5747:/data
# redis-cli -h redis -p 6379 redis:6379> ping
PONG
redis:6379> set "abc" 123 
OK
redis:6379> get "abc" 
"123"
redis:6379> exit 
root@ca38735c5747:/data# exit
exit
```

能将两个容器神奇地连接在一起，是通过docker run命令的--link myredis:redis参数实 现的。这个参数告诉 Docker 把新容器与现存的“myredis”容器连接起来，并且在新容器 中以“redis”作为“myredis”容器的主机名。为了实现这一点，Docker 会在新容器中的 / etc/hosts 里添加一个新条目，把“redis”指向“myredis”的 IP 地址。这样就能够在执行 redis-cli 的时候直接使用“redis”作为主机名，而不需想办法找出或传递 Redis 容器的 IP 地址给 redis-cli。

挂载主机目录:

	docker run -d -v /host/ dir:/container/dir test/webserver

备份redis容器数据到当前目录的backup目录下: 

```bash
docker run --rm --volumes-from myredis -v $(pwd)/backup:/backup debian cp /data/dump.rdb /backup/
```

连接的初始化是通过执行`docker run`命令时传入`--link CONTAINER:ALIAS`参数，其中 `CONTAINER` 是目标容器的名称，而 `ALIAS`(别名)是主容器用来称呼目标容器的一个本地名称。

默认情况下，无论容器之间是否已经建立了显式连接，都可以互相通信。如果想要防止尚 未连接的容器能够互联，可以在启动 Docker 守护进程时加上 --icc=false 和 --iptables 这 两个参数。当容器之间建立了连接时，Docker 便会设置 iptables 规则让容器可以在已声明 为开放(exposed)的端口上进行通信。

Docker 的连接功能目前还有一些不足之处。其中最大的不足也许就是连接只能 是静态的。虽然连接在容器重启之后应该还能工作，但如果目标容器被替换了，连接是不 会更新的。此外，目标容器必须在主容器之前启动，这意味着双向连接是不可能的。

## 4.5 利用数据卷和数据容器管理

首先，可以在执行 Docker 时，通过 `-v` 选项来宣告一个数据卷:
```bash
$ docker run -it --name container-test -h CONTAINER -v /data debian /bin/bash 
root@CONTAINER:/# ls /data
root@CONTAINER:/#
```
这样，容器中的 `/data` 目录便成为了一个数据卷。镜像的 /data 目录中的所有文件将被复制到数据卷内。我们可以在主机上打开一个新的 shell，通过执行 `docker inspect` 命令，找出数据卷在主机上的实际位置:
```bash
$ docker inspect -f {{.Mounts}} container-test
[{5cad... /mnt/sda1/var/lib/docker/volumes/5cad.../_data /data local true}]
```
在这个例子中，容器的 `/data/` 卷仅仅是一个指向主机中 `/var/lib/docker/volumes/5cad.../_data` 目录的连接。为了证明这一点，我们可以在主机上添加一个文件到那个目录:
```bash
$ sudo touch /var/lib/docker/volumes/5cad.../_data/test-file 
```
你应该可以立刻在容器中看到它:
```bash
$ root@CONTAINER:/# ls /data 
test-file
```
设置数据卷的第二种方法是通过在 `Dockerfile` 中使用 `VOLUME` 指令: 
```
FROM debian:wheezy
VOLUME /data
```
这个做法与执行 `docker run` 时提供 `-v /data` 参数的效果是相同的。

第三种方法: 将 `docker run` 命令的 `-v` 选项用法进行扩展，使到能够具体指明数据卷要绑 定的主机目录，命令格式为`-v HOST_DIR:CONTAINER_DIR`(其中`HOST_DIR`为主机目录， `CONTAINER_DIR` 为容器目录)，而 `Dockerfile` 并不支持这样做(因为这是不可移植的，而且 还会有安全风险)。这个命令的用法如下:
```bash
$ docker run -v /home/adrian/data:/data debian ls /data
```
这个例子把主机的 `/home/adrian/data` 目录挂载到容器的 `/data` 目录。容器能够使用 `/home/adrian/data` 目录中已有的任何文件。如果容器已经有 `/data` 目录，它的内容将会被数据卷所隐藏。与先前的几个命令不同，这次并没有文件会从镜像复制到数据卷，而卷也不会被 Docker 删除(换句话说，假如数据卷是挂载到一个用户选定的目录的话，那么 `docker rm -v` 是不会把它删除的)。

### 4.5.1 共享数据

另一种容器间共享数据的方法是，在运行`docker run`命令时，传入`--volumes-from CONTAINER`参数。例如，我们可以创建一个新的容器，让它能够访问之前的示例中该容器的数据卷，像这样:
```bash
$ docker run -it -h NEWCONTAINER --volumes-from container-test debian /bin/bash 
root@NEWCONTAINER:/# ls /data
test-file
root@NEWCONTAINER:/#
```

p68