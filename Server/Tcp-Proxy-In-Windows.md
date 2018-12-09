
# Windows 上的TCP代理设置
目前我们出现一个需求是将外网来的TCP请求代理到内网的某个服务器上, 比如我们的 Windows 上需要部署一个 RabbitMQ 推送服务, 但因为某些原因我们无法使用 Windows 版本的 RabbitMQ, 想将 RabbitMQ 部署在Linux服务器上, 确实有很多其他方式来满足这个需求, 比如再加一个服务器, 然后分配一个公网IP, 最后我们选择在 Windows 服务器上安装 VMware 然后虚拟一个Ubuntu系统. 现在需要将外网的 RabbitMQ 请求映射到 Ubuntu 上, 大概请求途径如下:

	Client(120.80.123.226) -> Windows(Public IP: 204.79.197.200, VMWare NAT IP: 192.168.60.1) -> Ubuntu(VMware NAT IP: 192.168.60.128)

(RabbitMQ默认使用的端口号是5672)

现在当 Client 请求 204.79.197.200:5672 订阅消息时, Windows 服务器需要将 120.80.123.226:xxxxx 请求映射到 Ubuntu 的 192.168.60.128:5672 上, 对于这个需求可以使用 powershell 的 `netsh interface portproxy` 命令来完成 TCP Proxy.

[只需设置如下](http://serverfault.com/questions/17990/easy-tcp-proxy-on-windows) :

	netsh interface portproxy add v4tov4 listenport=5672 listenaddress=201.79.167.200 connectaddress=192.168.60.128 connectport=5672 protocol=tcp

具体参数参见[MSDN](https://technet.microsoft.com/en-us/library/cc776297(v=ws.10).aspx), 大意是监听对于 tcp://204.79.197.200:5672 的TCP请求, 然后代理到 tcp://192.168.60.128:5672 上.
RabbitMQ还用到了其他端口号, 需要依次添加.

我第一次在测试服务器上测试通过了, 后来部署到正式环境怎么测试都不通过. 周五折腾了一天, 把赛门铁克都卸载了, 突然周一上班醒悟了.
测试服务器是一个独立的服务器, 只绑定了一个公网IP地址, 没有局域网IP地址, 所以上述设置是生效的. 而正式服务器被部署在一个局域网中了, 不仅配置了公网IP还有一个局域网IP(假设IP是192.168.1.50, 网关时192.168.1.1), 这就导致上述的配置无法生效, 因为192.168.1.50那台Windows服务器压根就监听不到公网IP(204...), 正式环境的TCP请求大概如下:

	Client(120.80.123.226) -> Gateway(Public IP: 204.79.179.200, Private IP: 192.168.1.1) -> Windows(Public IP: 204.79.197.200, Private IP: 192.168.1.50, VMWare NAT IP: 192.168.60.1) -> Ubuntu(VMware NAT IP: 192.168.60.128)

虽然当时正式服务器的Gateway将 204.79.179.200 的请求都传递给了 192.168.1.50, 可是 192.168.1.50 接收到数据包上的请求IP地址是 192.168.1.1 , 并不是 204.79.179.200, 所以正式的Windows服务器需要使用如下命令来设置:

	netsh interface portproxy add v4tov4 listenport=5672 listenaddress=192.168.1.50 connectaddress=192.168.60.128 connectport=5672 protocol=tcp

这是我们当时的正式环境的网络设置情况. 你需要搞清楚服务器的网络位置和情况, 然后才能设置正确的 listenaddress(TCP请求的IP地址) 和 listenport(TCP请求的端口号).
另外 netsh interface protproxy 目前支持tcp协议, 所以protocol=tcp这个参数可以省略.



