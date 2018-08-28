# 运行步骤

1. 启动MySQL Docker容器
```bash
docker run --name ssh-connect-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=00000000 -d mysql:5.7.23
```

2. 在数据库中新建一个库，名为ssh-connect-db

2. 构建ssh-connect-repo Docker镜像

3. 启动ssh-connect-repo Docker容器
```bash
docker run --name ssh-connect-repo --link ssh-connect-db:mysql -p 22022:22022 -d ydrdy/ssh-connect-repo:tag
```

4. 移动connect命令行工具到系统


# 数据库备份
TODO

# TODO List
* connect脚本help信息