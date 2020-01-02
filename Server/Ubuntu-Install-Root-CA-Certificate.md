# Ubuntu 系统安装根证书

原文来自: [How To Add DPI-SSL CA Certificate On Ubuntu OS?](https://www.sonicwall.com/support/knowledge-base/how-to-add-dpi-ssl-ca-certificate-on-ubuntu-os/171225202320465/)


1. 下载证书到本地, 如果证书是 `.cer` 格式, 可以使用以下命令转成 `.crt` 格式: 

```bash
$ openssl x509 –inform DER -in rootCA.cer –out rootCA.crt
```

2. 在目录`/usr/share/ca-certificates`下创建任意名称子目录(比如这里使用`extra`):

```bash
$ mkdir /usr/share/ca-certificates/extra
```

3. 拷贝文件到 `/usr/share/ca-certificates/extra` 和 `/usr/share/ca-certificate/mozilla`
4. 使用命令`dpkg-reconfigure ca-certificates`, 重新配置证书:
    * 选择 `Yes`
    * 按空格选中刚才新增的证书: `extra/rootCA.crt` 和 `mozilla/rootCA.crt`
    * 按 _Tab_ 切到 `Ok`并确认
5. 执行命令 `update-ca-certificates` 更新CA证书
6. 检查文件 `/etc/ca-certificates.conf`, 确保刚才新增的两条记录前没有`!`符号
7. Firefox / Chrome 在Ubuntu系统上有自己的证书数据库, 使用以下命令更新Chrome证书数据库:

```bash
$ certutil –d sql:$HOME/.pki/nssdb –A –t “C,,” –n “Description Name” -i /usr/share/ca-certificates/extra/rootCA.crt
```

8. 验证证书被添加到Chrome证书数据库:

```bash
$ certutil -L -d sql:${HOME}/.pki/nssdb
```

然后重启Chrome浏览器, 访问 `chrome://settings/certificates` , 切换到 `Authorities` Tab即可看到新增的证书.