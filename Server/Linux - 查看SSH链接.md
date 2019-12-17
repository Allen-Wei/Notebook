# 查看SSH链接 

Ref: [6 commands to check and list active SSH connections in Linux](https://www.golinuxcloud.com/list-check-active-ssh-connections-linux/)

## Using `ss` command

`ss` is used to dump socket statistics. It allows showing information similar to netstat. It can display more TCP and state information than other tools. We will use grep function to only get the list of active SSH sessions on our local host

```tty
[root@node3 ~]# ss | grep -i ssh
tcp    ESTAB      0      0      10.0.2.32:ssh                  10.0.2.31:37802
tcp    ESTAB      0      64     10.0.2.32:ssh                  10.0.2.2:49966
tcp    ESTAB      0      0      10.0.2.32:ssh                  10.0.2.30:56088
```

From the above example we know that there are three hosts which are currently connected to our node3. We have active SSH connections from _10.0.2.31_, _10.0.2.30_ and _10.0.2.2_


## Using `last` command

`last` searches back through the file `/var/log/wtmp` (or the file designated by the `-f` flag) and displays a list of all users logged in (and out) since that file was created. Names of users and tty’s can be given, in which case last will show only those entries matching the arguments.

Using this command you can also get the information about the user using which the SSH connection was created between server and client. So below we know the connection from 10.0.2.31 is done using `deepak` user, while for other two hosts, `root` user was used for connecting to node3.

```tty
[root@node3 ~]# last -a | grep -i still
deepak   pts/1        Fri May 31 16:58   still logged in    10.0.2.31
root     pts/2        Fri May 31 16:50   still logged in    10.0.2.30
root     pts/0        Fri May 31 09:17   still logged in    10.0.2.2
```

Here I am grepping for a string “still” to get all the patterns with “still logged in“. So now we know we have three active SSH connections from _10.0.2.31_, _10.0.2.30_ and _10.0.2.2_

 

## Using `who` command

who is used to show who is logged on on your Linux host. This tool can also give this information

```tty 
[root@node3 ~]# who
root     pts/0        2019-05-31 09:17 (10.0.2.2)
root     pts/1        2019-05-31 16:47 (10.0.2.31)
root     pts/2        2019-05-31 16:50 (10.0.2.30)
```

Using this command we also get similar information as from last command. Now you get the user details used for connecting to node3 from source host, also we have terminal information on which the session is still active.

We generally hear terminal as tty but here we see terminal is referenced as pts, but now:
What is the difference between tty and pts?
How to disable or enable individual tty terminal console in Linux?

## Using `w` command

`w` displays information about the users currently on the machine, and their processes. This gives more information than who and last command and also serves our purpose to get the list of active SSH connections. Additionally it also gives us the information of the running process on those sessions.

Using `w` command you will also get the idle time details, i.e. for how long the session is idle. If the SSH session is idle for long period then it is a security breach and it is recommended that such idle SSH session must be killed, you can configure your Linux host to automatically kill such idle SSH session.

```tty
[root@node3 ~]# w
 17:01:41 up  7:44,  3 users,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    10.0.2.2         09:17    9:41   0.31s  0.00s less -s
deepak   pts/1    10.0.2.31        16:58    3:06   0.03s  0.03s -bash
root     pts/2    10.0.2.30        16:50    5.00s  0.07s  0.02s w
``` 

## Using `netstat` command

Similar to ss we have netstat command to show active ssh sessions. Actually we can also say that ss is the new version of netstat. Here we can see all the ESTABLISHED SSH sessions from remote hosts to our localhost node3. it is also possible that one or some of these active ssh connections are in hung state so you can configure your host to automatically disconnect or kill these hung or unresponsive ssh sessions in Linux.

```tty
[root@node3 ~]# netstat -tnpa | grep 'ESTABLISHED.*sshd'
tcp        0      0 10.0.2.32:22            10.0.2.31:37806         ESTABLISHED 10295/sshd: deepak
tcp        0      0 10.0.2.32:22            10.0.2.2:49966          ESTABLISHED 4329/sshd: root@pts
tcp        0      0 10.0.2.32:22            10.0.2.30:56088         ESTABLISHED 10125/sshd: root@pt
```

ALSO READ:

[How to disconnect idle ssh session or keep idle ssh session active in Linux](https://www.golinuxcloud.com/disconnect-idle-ssh-session-tcpkeepaliv-linux/)
 

## Using `ps` command

Now to show active ssh sessions, ps command may not give you accurate results like other commands we discussed in this article but it can give you some more additional information i.e. PID of the SSHD process which are currently active and connected.

```tty
> ps auxwww | grep sshd: | grep -v grep
root      4329  0.0  0.1 154648  5512 ?        Ss   09:17   0:00 sshd: root@pts/0
root     10125  0.0  0.1 154648  5532 ?        Ss   16:50   0:00 sshd: root@pts/2
root     10295  0.0  0.1 154648  5480 ?        Ss   16:58   0:00 sshd: deepak [priv]
deepak   10301  0.0  0.0 156732  2964 ?        S    16:58   0:00 sshd: deepak@pts/1
```

## Check ssh connection history
To get the ssh connection history you can always check your SSHD logs for more information on connected or disconnected SSH session. Now the sshd log file may vary from distribution to distribution. On my RHEL 7.4 my sshd logs are stored inside `/var/log/sshd`

Lastly I hope the steps from the article to check active SSH connections and ssh connection history in Linux was helpful. So, let me know your suggestions and feedback using the comment section.