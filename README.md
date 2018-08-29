# 介绍（macOS Only）
通过connect命令管理所有连接过的SSH机器

# 运行步骤
1. 启动MySQL Docker容器
```bash
docker run --name ssh-connect-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=00000000 -d mysql:5.7.23
```

2. 构建ssh-connect-repo Docker镜像
```bash
mvn package
```

3. 启动ssh-connect-repo Docker容器
```bash
docker run --name repo --link ssh-connect-db:mysql -p 22022:22022 -e DB_PASSWORD=00000000 -d ydrdy/ssh-connect-repo:tag
```

4. 将`script/connect.sh`移动系统的PATH下（配置给脚本路径到PATH）

5. 将`script/repo.conf`移动到`~/.ssh_repo/`下


# 数据库备份
TODO