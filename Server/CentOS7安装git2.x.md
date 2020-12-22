## How to Install latest version of Git ( Git 2.x ) on CentOS 7

[ref](https://computingforgeeks.com/how-to-install-latest-version-of-git-git-2-x-on-centos-7/)

### 从源安装

```bash
yum remove git* # 删除老版本

# 安装新版本
yum -y install  https://centos7.iuscommunity.org/ius-release.rpm
yum -y install  git2u-all
```

### 源码安装

```bash
# 安装依赖
yum groupinstall "Development Tools"
yum -y install wget perl-CPAN gettext-devel perl-devel  openssl-devel  zlib-devel

## 下载并安装
export VER="2.22.0"
wget https://github.com/git/git/archive/v${VER}.tar.gz
tar -xvf v${VER}.tar.gz
rm -f v${VER}.tar.gz
cd git-*
make install
```