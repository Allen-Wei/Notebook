# Docker 设置时区

原文: [5 ways to change time in Docker container](https://bobcares.com/blog/change-time-in-docker-container/)

总结如下:

```bash
docker run -it --rm -v /etc/timezone:/etc/timezone -v /etc/localtime:/etc/localtime ubuntu date
# 或者
docker run -it --rm -e TZ=Asia/Shanghai centos date
```

Suppose you provide WordPress hosting using Docker containers to customers around the globe. Your customers would want to change time in Docker container to their time zones.

In our role as Server Support Specialists for web hosting companies and infrastructure providers, we provision and manage Docker systems for various business purposes.

Changing time in Docker container configuration is a task we perform as a part of this service. Here, we’ll see the different ways to do that.


## How to change time in Docker container

The time in a Docker container can be changed in 5 ways. To know the current time, the ‘date’ command can be used.

```bash
docker exec -it container-id date
```

To know the timezone configured in a Docker container, the `/etc/timezone` file has to be checked.

```bash
￼docker exec -it container-id cat /etc/timezone
```

### 1. Using date command

The easiest way to change the time in a Docker container is to change the time using `date` command after connecting to the container.

```bash
docker exec -it container-name /bin/bash
date +%T -s "10:00:00"
```
 
Though the time zone change usually reflects immediately, in some cases, the container needs a restart for the time to change.


### 2. Using environment variables

The timezone of a container can be set using an environment variable in the docker container when it is created.

```bash
docker run -e TZ=America/New_York ubuntu date
```

The time zone data package tzdata needs to be installed in the container for setting this timezone variable.

By configuring an NTP server, we ensure that the time zones in the containers are always synced.
 

### 3. Using Dockerfile

In hosting environment or cases which need too many identical containers to be spun up, the easiest way to manage is using Dockerfile.

The Dockerfile contains the basic configuration settings for each container. To change time in Docker container, the changes can be done in the corresponding Dockerfile.

The settings in the Dockerfile would reflect while recreating or adding a new container. And, all commands from the Docker file will be run as the root user. The entry in Dockerfile would look like:

```Dockerfile
RUN echo "Europe/Stockholm" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
```

The installation command for tzdata package would vary based on the OS image that the container is using.

We also update the entry point script of the containers to include the timezone settings. This ensures that the date would be set whenever the container is restarted.


### 4. Using volumes

A major issue with Docker containers is that the data in the container is not persistent over restarts. To work around this, we use Docker data volumes.

Data volumes in Docker machines are shared directories that contains the data specific to containers. The data in volumes are persistent and will not be lost during container recreation.

The directory `/usr/share/zoneinfo` in Docker contains the container time zones available.  The desired time zone from this folder can be copied to `/etc/localtime` file, to set as default time.

This time zone files of the host machine can be set in Docker volume and shared among the containers by configuring it in the Dockerfile as shown.

```Dockerfile
volumes:
- "/etc/timezone:/etc/timezone:ro"
- "/etc/localtime:/etc/localtime:ro"
```

The containers created out of this Dockerfile (_docker-compose.yml_) will have the same timezone as the host OS (as set in `/etc/localtime` file) .


### 5. Using images

Manually changing time zone is not feasible when there are too many containers. To create more Docker instances with the same time zone, we use images.

After setting the desired time zone in a Docker container, we exit it and create a new image from that container using `docker commit`. NTP service is also configured in that image.

```bash
docker commit container-name image-name
```

Using this image, we can create one or more containers with the same time zone. The images are stored in repositories for future use.

## Conclusion

Docker containers are widely used in DevOps and niche web hosting. Today we’ve discussed the various ways how our Docker Support Specialists change time in Docker container in the Docker infrastructure we manage.