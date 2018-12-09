
### 2.3.3

CMD可以通过docker run后面的参数来覆盖，而ENTRYPOINT只能通过docker run 的 --entrypoint 参数来覆盖.

### 2.5.2

使用 .dockerignore 文件。在镜像构建过程中，Docker 会将 Dockerfile 所在文件夹下的内 容(即 build context)复制到构建环境中。使用 .dockerignore 文件可以将指定文件或者 文件夹在镜像构建时从文件复制列表中排除。
