
### 2.3.3

`CMD`可以通过`docker run`后面的参数来覆, 而`ENTRYPOINT`只能通过`docker run` 的 `--entrypoint` 参数来覆盖.

### 2.5.2

使用 `.dockerignore` 文件。在镜像构建过程中, Docker 会将 Dockerfile 所在文件夹下的内容(即 build context)复制到构建环境中。使用 `.dockerignore` 文件可以将指定文件或者文件夹在镜像构建时从文件复制列表中排除。

如果你正连接到一个 Docker 容器, 无论容器是以交互模式启动, 还是通过使用`docker attach`, 当你试图以 __CTRL-C__ 断开时, 容器也会同时停止。但如果使用 __CTRL-P CTRL-Q__ 的话, 就可以从容器分离, 而不会停止容器。
这个方法只有在附有 TTY 的交互模式下才有效(即同时使用了 `-i` 和 `-t` 选项)。
