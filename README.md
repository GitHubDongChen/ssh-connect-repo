# 介绍
> Mac only

通过connect命令管理所有连接过的SSH机器

# 运行步骤

1. 启动MySQL Docker容器
```bash
docker run --name ssh-connect-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=00000000 -d mysql:5.7.23
```

2. 构建ssh-connect-repo Docker镜像

3. 启动ssh-connect-repo Docker容器
```bash
docker run --name repo --link ssh-connect-db:mysql -p 22022:22022 -e DB_PASSWORD=00000000 -d ydrdy/ssh-connect-repo:tag
```

4. 将`shell/connect.sh`移动系统的PATH下（配置给脚本路径到PATH）

5. 将`script/repo.conf`移动到`~/.ssh_repo/`下


# 数据库备份
TODO

# TODO List
* connect脚本help信息
* MySQL Docker 的数据备份
* ~~Dockerfile 提供 HEALTHCHECK~~

# Change List
## 0.1.3
* 仓库地址不再通过connect脚本配置，而是通过~/.ssh_repo/repo.conf文件配置
* Dockerfile 增加 HEALTHCHECK

## 0.1.2
* 脚本可以通过仓库服务的健康检查接口判断仓库服务是否可用