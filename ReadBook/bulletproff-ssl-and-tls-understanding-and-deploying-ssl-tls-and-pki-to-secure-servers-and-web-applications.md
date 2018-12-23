# HTTPS 权威指南 在服务器和Web应用上部署SSL/TLS和PKI

## 11.2 密钥和证书管理

大多数用户借助OpenSSL是因为希望配置并运行能够支持SSL的Web服务器. 整个过程包括3 个步骤:
1. 生成强加密的私钥;
2. 创建证书签名申请(certificate signing request，CSR)并且发送给CA;
3. 在你的Web服务器上安装CA提供的证书

### 11.2.1 生成密钥

在使用公钥加密之前的第一步是生成一个私钥. 在开始之前，你必须进行几个选择. 

#### 密钥算法
OpenSSL支持RSA、DSA和ECDSA密钥，但是在实际使用场景中不是所有密钥类型都适用的. 例如对于Web服务器的密钥，所有人都使用RSA，因为DSA一般因为效率问题会限制在1024位(Internet Explorer不支持更长的DSA密钥)，而ECDSA还没有被大部分的CA支持. 对于SSH来说，一般都是使用DSA和RSA，而不是所有的客户端都支持ECDSA算法. 

#### 密钥长度
默认的密钥长度一般都不够安全，所以我们需要指定要配置的密钥长度。例如RSA密钥默认的长度是512位，非常不安全。如果今天你的服务器上还是用512位的密钥，入侵者可以先获取你的证书，使用暴力方式来算出对应的私钥，之后就可以冒充你的站点了。现在，一般认为2048位的RSA密钥是安全的，所以你应该采用这个长度的密钥。DSA密钥也应该不少于2048位，ECDSA密钥则应该是256位以上。

#### 密码
强烈建议使用密码去保存密钥，虽然这是只一个可选项。受密码保护的密钥可以被安全地存储、传输以及备份。但与此同时，这样的密钥也会带来不便，因为我们如果没有密码的话，就无法使用密钥了。例如每次你想要重启Web服务器的时候就会被要求输入密码。

#### 使用`genrsa`命令来生成RSA密钥

```bash
$ openssl genrsa -aes128 -out fd.key 2048
```
这里指定私钥会使用AES-128算法来加密保存。当然也可以使用AES-192或者AES-256 (分别使用开关-aes192和-aes256)，但是最好不要使用其他算法(DES、3DES和SEED)。私钥以所谓的PEM格式存储. 你可以使用下面的rsa命令解析出私钥的结构: 
```bash
$ openssl rsa -text -in fd.key
```
如果你需要单独查看密钥的公开部分，可以使用下面的rsa命令: 
```bash
$ openssl rsa -in fd.key -pubout -out fd-public.key
```
创建ECDSA密钥的过程是类似的，但是不能创建任意长度的密钥。对于每个密钥，你需要选择一个命名曲线(named curve)，它可以控制密钥长度，同时也限定了椭圆曲线的参数。下面的例子使用secp256r1这个命名曲线创建一个256位长度的ECDSA密钥:
```bash
$ openssl ecparam -genkey -name secp256r1 | openssl ec -out ec.key -aes128
```

### 11.2.2 创建证书签名申请

一旦有了私钥，就可以创建证书签名申请(certificate signing request，CSR)。这是要求CA 给证书签名的一种正式申请，该申请包含申请证书的实体的公钥以及该实体的某些信息。该数据将成为证书的一部分。CSR始终使用它携带的公钥所对应的私钥进行签名。
```bash
$ openssl req -new -key fd.key -out fd.csr
```

> 根据RFC 2985的5.4.1节1，质询密码(challenge password)是一个可选字段，用于在证书吊销过程中确认申请过该证书的最初实体的身份。如果输入这个字段，则会将密码包括在CSR文件中并发送给CA。几乎没有CA会依赖这个字段，我所看到的帮助信息都建议将这一字段留空，因为设置一个质询密码并没有增加CSR的任何安全性。另外不要将这个字段和密钥密码混淆了，它们的作用是不一样的。

检查一遍CSR是正确的。可以这么做:
```bash
$ openssl req -text -in fd.csr -noout
```

### 11.2.3 用当前证书生成CSR文件

如果你想更新一张证书并且不想对里面的信息作任何更改, 使用下面的命令可以用当前的证书创建一个全新的CSR文件:
```bash
$ openssl x509 -x509toreq -in fd.crt -out fd.csr -signkey fd.key
```

### 11.2.4 非交互方式生成CSR
生成CSR并不一定要使用交互方式。使用自定义的OpenSSL配置文件，可以将这个过程自动 化(本节中介绍的)，并且还可做一些交互方式无法完成的事情(后续几节会介绍)。
例如我们想自动生成www.feistyduck.com的CSR文件，可以先创建一个fd.cnf文件:
```
[req]
prompt = no distinguished_name = dn req_extensions = ext input_password = PASSPHRASE
[dn]
CN = www.feistyduck.com
emailAddress = webmaster@feistyduck.com O = Feisty Duck Ltd
L = London
C = GB
[ext]
subjectAltName = DNS:www.feistyduck.com,DNS:feistyduck.com
```

然后使用下面的命令直接创建CSR文件:
```bash
$ openssl req -new -config fd.cnf -key fd.key -out fd.csr
```

### 11.2.5 自签名证书
如果已经有了CSR，可以使用下面的文件创建证书:
```bash
$ openssl x509 -req -days 365 -in fd.csr -signkey fd.key -out fd.crt
```

也可以无需单独创建一个CSR，使用下面的命令直接使用私钥创建自签名证书:
```bash
$ openssl req -new -x509 -days 365 -key fd.key -out fd.crt
```

如果你不想有交互提示，直接使用-subj并带上标题信息就可以了: 
```bash
$ openssl req -new -x509 -days 365 -key fd.key -out fd.crt -subj "/C=GB/L=London/O=Feisty Duck Ltd/CN=www.feistyduck.com"
```

### 11.2.6 创建对多个主机名有效的证书

默认情况下，OpenSSL创建的证书只包含一个公用名而且只能设置一个主机名。有两种方式在一张证书里面支持多主机名。一种方式是在X.509的使用者可选名称(subject alternative name，SAN)扩展字段里面列出所有要使用的主机名;另外一种就是使用泛域名。可 以将两种方式合在一起，这样更加方便。在实际使用的时候，可以设置顶级域名和一个泛域名来囊括所有二级域名(例如feistyduck.com和*.feistyduck.com)。

> 当证书包括可选名称的时候，所有公用名就会被忽略。CA新创建的证书甚至可能不再包括任何公用名，所以，请在可选名称列表中包含所有想要的主机名。

首先，将扩展信息放在一个单独的文本文件中，我将该文件命名为fd.ext。在这个文件中， 指定扩展的名称(subjectAltName)，并且像下面这样列出需要的主机名:
`subjectAltName = DNS:*.feistyduck.com, DNS:feistyduck.com` 然后当使用x509命令签发证书的时候，使用`-extfile`开关引用该文件:

```bash
$ openssl x509 -req -days 365 -in fd.csr -signkey fd.key -out fd.crt -extfile fd.ext
```

### 11.2.7 检查证书

x509命令可以帮助你查看刚生成的自签名证书。下面使用`-text`来打印证书内容，使用`-noout`则不打印编码后的证书内容，这样可以减少信息干扰(默认情况下会打印):
```bash
$ openssl x509 -text -in fd.crt -noout
```

### 11.2.8 密钥和证书格式转换

私钥和证书可以以各种格式进行存储，所以你可能经常需要进行各种格式之间的转换，最常见的格式如下:

1. Binary (DER) certificate
包含原始格式的X.509证书，使用DER ASN.1编码。

2. ASCII (PEM) certificate(s)
包含base64编码过的DER证书，它们以`-----BEGIN CERTIFICATE-----`开头，以`-----END CERTIFICATE-----`结尾。虽然有些程序可以允许多个证书存在一个文件中，但是一般来说一个文件只有一张证书。例如Apache Web服务器要求服务器的证书全部在一个文件里面， 而中间证书一起放在另外一个文件中。

3. Binary (DER) key
包含DER ASN.1编码后的私钥的原始格式。OpenSSL使用他自己传统的方式创建密钥(SSLeay)格式。还有另外一种不常使用的格式叫作PKCS#8(RFC 5208定义的)。OpenSSL 可以使用pkcs8命令进行PKCS#8格式的转换。

4. ASCII (PEM) key
包括base64编码后的DER密钥和一些元数据信息(例如密码的保存算法)。

5. PKCS#7 certificate(s)
RFC 2315定义的一种比较复杂的格式，设计的目的是用于签名和加密数据的传输。一般 常见的是.p7b和.p7c扩展名的文件，并且文件里面可以包括所需的整个证书链。Java的密钥管理工具支持这种格式。