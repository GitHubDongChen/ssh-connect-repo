# 介绍（macOS Only）
通过connect命令管理所有连接过的SSH机器

# 运行步骤
1. 启动MongoDB Docker容器
```bash
docker run -p 27017:27017 --name ssh-connect-mongodb -d mongo:4
```

2. 构建ssh-connect-repo Docker镜像
```bash
mvn package
```

3. 启动ssh-connect-repo Docker容器
```bash
docker run --name repo --link ssh-connect-mongodb:mongodb -p 22022:22022 -d ydrdy/ssh-connect-repo:tag
```

4. 将`script/sshw.sh`移动系统的PATH下（配置给脚本路径到PATH）

5. 将`script/repo.conf`移动到`~/.ssh_repo/`下

# `sshw`使用教程
```bash
# 建立新连接
sshw root@10.10.10.10 -p 22
# 可简化为
sshw 10.10.10.10

# 建立连接并添加别名
a=my_alias sshw 10.10.10.10

# 更新已有别名
a=new_alias sshw my_alias

# 指定连接密码
pwd=passwd sshw root@10.10.10.10

# 其他使用方法可以参考ssh命令
```

# 数据库备份
TODO