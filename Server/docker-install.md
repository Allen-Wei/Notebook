# Install Docker


## Aliyun Mirror

### Ubuntu

```bash
> apt-get install -y apt-transport-https ca-certificates curl software-properties-common
> curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
> add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable"
> apt-get update
> apt-get install docker-ce
```

# Set Proxy

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://{your_key}.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```


## Tuna Mirror

来源: [Docker Community Edition 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/docker-ce/)

### Ubuntu

```bash
> apt-get remove docker docker-engine docker.io #如果你过去安装过 docker，先删掉
> apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common #安装依赖
> curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - #信任 Docker 的 GPG 公钥
> add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" #对于 amd64 架构的计算机，添加软件仓库
> apt-get update
> apt-get install docker-ce
```
