# Wireguard

## 服务器端安装

执行以下命令启动Wireguard(需要安装Docker): 

```bash
docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e SERVERURL=172.105.199.140 \
  -e SERVERPORT=51820 \
  -e PEERS=1 \
  -e PEERDNS=auto \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -p 51820:51820/udp \
  -v $PWD/config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  linuxserver/wireguard
```

## Mac 连接

### 安装Client 

Via [Mac 配置 WireGuard 客户端](https://blog.kelu.org/tech/2020/03/13/mac-install-wireguard.html) 

安装 WireGuard 客户端

```bash
brew install wireguard-tools
```

配置 WireGurad 客户端

```
sudo mkdir /usr/local/etc/wiregurad 
sudo touch /usr/local/etc/wiregurad/wg0.conf
```

`wg0.conf` 文件如下：

```ini
[Interface]
Address = 10.200.200.2/32
PrivateKey = <client_private_key>
MTU = 1420
   
[Peer]
PublicKey = <server_public_key>
Endpoint = <SERVER_IP:SERVER_PORT>
AllowedIPs = 10.200.0.0/16
PersistentKeepalive = 25
```

启动 WireGuard

```bash
sudo wg-quick up wg0-client
sudo wg show
```

### 配置文件 

Via [聊聊内核里的 WireGuard](https://zhuanlan.zhihu.com/p/147377961)

生成 WireGuard 两对公钥和私钥，分别是服务器和客户端的: 
```bash
wg genkey | tee server_privatekey | wg pubkey > server_publickey
wg genkey | tee client_privatekey | wg pubkey > client_publickey
```

#### 服务器配置

Wireguard 的配置都在 `/etc/wireguard` 目录下，在服务器上编辑 `/etc/wireguard/wg0.conf` 并输入以下内容。

```ini
[Interface]
Address = 10.100.0.1/16  # 这里指的是使用 10.100.0.1，网段大小是 16 位
SaveConfig = true
ListenPort = 51820  # 监听的 UDP 端口
PrivateKey = < 这里填写 Server 上 privatekey 的内容 >
# 下面这两行规则允许访问服务器的内网
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client，可以有很多 Peer
[Peer]
PublicKey = < 这里填写 Client 上 publickey 的内容 >
AllowedIPs = 10.100.0.2/32  # 这个 Peer 只能是 10.100.0.2
# 如果想把所有流量都通过服务器的话，这样配置：
# AllowedIPs = 0.0.0.0/0, ::/0
```

然后，我们可以使用 `wg-quick up wg0` 启动 `wg0` 这个设备了。

通过 `wg show` 可以看到：
```bash
interface: wg0
  public key: xxxxxx
  private key: (hidden)
  listening port: 51820

peer: xxxxx
  allowed ips: 10.100.0.2/32
```

#### 客户端配置

在客户端新建文件，可以放到 `/etc/wireguard/wg0.conf` 中，也可以随便放哪儿，用客户端读取就行。我这里使用的是 Mac 官方客户端，在 Mac AppStore 里可以找到。

```ini
[Interface]
PrivateKey = < 这里填写 Client 上 privatekey 的内容 >
Address = 10.100.0.2/32
DNS = 8.8.8.8  # 连接后使用的 DNS, 如果要防止 DNS 泄露，建议使用内网的 DNS 服务器

[Peer]
PublicKey = < 这里填写 Server 上 publickey 的内容 >
Endpoint = 1.1.1.1:51820  # 服务端公网暴露地址，51280 是上面指定的
AllowedIPs = 10.100.0.0/16,172.17.0.11/20  # 服务器可以相应整个网段以及服务器的内网
# 如果想把所有流量都通过服务器的话，这样配置：
# AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```


