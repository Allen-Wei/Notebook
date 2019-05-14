# RabbitMQ 安装
这里主要介绍Ubuntu的安装, 其他的就自行官网查找吧.

## Ubuntu

在安装一下包之前, 先更新一下源:
	
	sudo apt-get update

### 安装 Erlang/OTP

	sudo apt-get install erlang erlang-doc

via: [How to install erlang in Ubuntu 12.04?](http://askubuntu.com/questions/190612/how-to-install-erlang-in-ubuntu-12-04)

### 安装 RabbitMQ Server

	sudo apt-get install RabbitMQ-Server

我的Ubuntu上直接使用这个命令就能安装, 如果你的找不到这个包, 可以安装[官网](http://www.rabbitmq.com/install-debian.html)提供的 `APT Repository` 方式安装.

So easy!!!
