## 访问 Docker Desktop for Mac/Windows 里的 MobyLinux 虚拟机文件

[原文](https://nickjanetakis.com/blog/docker-tip-70-gain-access-to-the-mobylinux-vm-on-windows-or-macos)

This tip applies to anyone running Docker for Windows or Docker for Mac.

__Access the MobyLinux VM’s file system__:

```bash
# Run this from your regular terminal on Windows / MacOS:
docker container run --rm -it -v /:/host alpine

# Once you're in the container that we just ran, run this:
chroot /host
```

And BLAMO, you’re inside of the MobyLinux VM’s file system.

Now if you run `ls -la` you’ll see all sorts of things, such as your mounts. In [Docker Tip #69](https://nickjanetakis.com/blog/docker-tip-69-avoid-running-out-of-disk-space-from-container-logs) I talked about protecting against Docker’s container logs from eating up all of your disk space. This was how I figured how much space was being used on my Windows system.

I ran `du -chs /var/lib/docker/containers/*/*json.log` inside of the container we’re in now, which tallies up the total disk space used by all container logs.

By the way, you can press `CTRL + D` twice to exit the container. Once to exit what chroot `/root` did, which was to change the root directory to point to the MobyLinux VM instead of Alpine, and again to exit the Alpine session.