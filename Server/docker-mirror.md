# Docker 国内镜像

来源: [国内 docker 仓库镜像对比](https://ieevee.com/tech/2016/09/28/docker-mirror.html)

修改 `/etc/docker/daemon.json`(Linux) 或者 `%programdata%\docker\config\daemon.json`(Windows) 来配置 Daemon, 请在该配置文件中加入(没有该文件的话, 请先建一个):

```json
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
```

然后执行以下命令使生效:

```bash
systemctl daemon-reload
systemctl restart docker
```

## 官方的中国区加速器了

`https://registry.docker-cn.com`

## 网易163 Docker镜像

`http://hub-mirror.c.163.com`

## ustc的镜像

`https://docker.mirrors.ustc.edu.cn`