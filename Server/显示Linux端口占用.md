On Linux, you must be root or the owner of the process to get the information you desire. As such, for processes running as another user, prepending sudo is most of what you need. In addition to that, on modern Linux systems, ss is tool to use to do this:

```bash
$ sudo ss -lptn 'sport = :80'

State   Local Address:Port  Peer Address:Port              
LISTEN  127.0.0.1:80        *:*                users:(("nginx",pid=125004,fd=12))
LISTEN  ::1:80              :::*               users:(("nginx",pid=125004,fd=11))
```

You can also use the same invocation you're currently using, but remember to sudo:

```bash
$ sudo netstat -nlp | grep :80
tcp  0  0  0.0.0.0:80  0.0.0.0:*  LISTEN  125004/nginx
```

You can also use lsof:

```bash
$ sudo lsof -n -i :80 | grep LISTEN
nginx   125004 nginx    3u  IPv4   6645      0t0  TCP 0.0.0.0:80 (LISTEN)
```