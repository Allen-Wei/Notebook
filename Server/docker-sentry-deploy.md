# Sentry 部署

参考 [Sentry Doc](https://github.com/docker-library/docs/tree/master/sentry).

## 初始化并设置账号密码

```bash
docker run -d --name sentry-redis redis
docker run -d --name sentry-postgres -e POSTGRES_PASSWORD=secret -e POSTGRES_USER=sentry postgres
# 可以执行以下命令获取key
# docker run --rm sentry config generate-secret-key
docker run -it --rm -e SENTRY_SECRET_KEY='mg_wqo&ziiaou_8#-=_3_d(8!y5o=8=_-d78qqytuie)xfkns5' --link sentry-postgres:postgres --link sentry-redis:redis sentry upgrade
```

## 启动
```bash
# 也可以使用 -P 随机分配端口号
docker run -d --name my-sentry -e SENTRY_SECRET_KEY='mg_wqo&ziiaou_8#-=_3_d(8!y5o=8=_-d78qqytuie)xfkns5' --link sentry-redis:redis --link sentry-postgres:postgres -p 8080:9000 sentry
docker run -d --name sentry-cron -e SENTRY_SECRET_KEY='mg_wqo&ziiaou_8#-=_3_d(8!y5o=8=_-d78qqytuie)xfkns5' --link sentry-postgres:postgres --link sentry-redis:redis sentry run cron
docker run -d --name sentry-worker-1 -e SENTRY_SECRET_KEY='mg_wqo&ziiaou_8#-=_3_d(8!y5o=8=_-d78qqytuie)xfkns5' --link sentry-postgres:postgres --link sentry-redis:redis sentry run worker

```

现在就可以访问 `http://localhost:8080` 了.