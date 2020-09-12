apt update 
apt install git -y
cd /etc/apt
git init
chown -R alan .git/

apt-get install build-essential -y # dev tools
apt install gcc -y
apt install net-tools -y # ifconfig 工具
apt install flameshot -y # 截图工具
apt install vim -y 
apt install wget -y
apt install ffmpeg -y # 视频处理类库
apt-get install scrot -y # 命令行截图工具
apt-get install simplescreenrecorder -y # 录屏工具
apt install network-manager-l2tp-gnome -y # VPN工具
apt-get install vlc -y # 媒体播放工具

# config git
git config --global core.editor "vim"
git config --global credential.helper "cache --timeout 360000"

# install remmina
apt-add-repository ppa:remmina-ppa-team/remmina-next
apt update
apt install remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice
killall remmina

# install official docker
apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
docker --version

# install docker by aliyun mirror
apt-get update
apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
apt-get -y update
apt-get -y install docker-ce

snap install chromium
