# Ubuntu 使用手册


## 常用工具

```sh
apt install vim -y
apt install wget -y
apt install git -y
wget https://gitee.com/alanway/Notebook/raw/master/Else/_vimrc
mv _vimrc ~/.vimrc

apt install ffmpeg # 视频处理工具
apt-get install ibus-rime # 输入法: https://github.com/rime/home/wiki/RimeWithIBus
```

* [sublime](https://www.sublimetext.com/)
* [sublime merge](https://www.sublimemerge.com/)
* node
* visual studio code
* Jetbrain IDEA
* VMware workstation pro
* vlc
* [dash-to-panel](https://github.com/home-sweet-gnome/dash-to-panel)
* [whistle](https://github.com/avwo/whistle/blob/master/README-zh_CN.md)
* [mitmproxy](https://github.com/mitmproxy/mitmproxy)

## 截图

* __PrtSc__ – 获取整个屏幕的截图并保存到 Pictures 目录。
* __Shift + PrtSc__ – 获取屏幕的某个区域截图并保存到 Pictures 目录。
* __Alt + PrtSc__ –获取当前窗口的截图并保存到 Pictures 目录。
* __Ctrl + PrtSc__ – 获取整个屏幕的截图并存放到剪贴板。
* __Shift + Ctrl + PrtSc__ – 获取屏幕的某个区域截图并存放到剪贴板。
* __Ctrl + Alt + PrtSc__ – 获取当前窗口的 截图并存放到剪贴板。


```sh
apt install flameshot # 支持注释、裁减、模糊, GitHub: https://github.com/lupoDharkael/flameshot
apt-get install scrot # 基于终端的一个较新的截图工具
```

> [在 Linux 下截屏并编辑的最佳工具](https://linux.cn/article-10070-1.html)

## 录屏

```sh
apt-get install simplescreenrecorder # https://www.maartenbaert.be/simplescreenrecorder/
apt-get install kazam
```

Gnome3 系用户，可以按 `ctrl + shift + alt + r`，屏幕右下角有红点出现，则开始录屏，要结束的话再按一次 `ctrl + shift + alt + r`，录好的视频在 `~/Videos` 下.

## 安装Docker

参考: [docker-install-script.md](./docker-install-script.md)

```sh
git clone git@github.com:alanwei43/docker-nginx.git # 获取nginx, 用于反向代理
```
