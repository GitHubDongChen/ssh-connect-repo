#!/bin/sh

function script_help(){
	echo "Usage: connect -h host_ip [-p] [-u root] [-P 22]"
  echo "  -h 目标机器IP"
  echo "  -p 手动输入SSH密码，命令执行过程中会提示输入密码"
  echo "  -u SSH用户"
  echo "  -P SSH端口"
}

# 通用消息显示函数
function msg(){
  echo "==> ${1}"
}

# 保存账号密码到仓库
function repo_save() {
  # ${1} host
  # ${2} port
  # ${3} user
  # ${4} passwd
  curl -X "POST" "${REPO_URL}/save" -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' --data-urlencode "host=${1}" --data-urlencode "port=${2}" --data-urlencode "user=${3}" --data-urlencode "passwd=${4}"
}

# 加载配置文件
if [ -e ~/.ssh_repo/repo.conf ]
then
  source ~/.ssh_repo/repo.conf
else
  msg "缺少仓库配置文件[~/.ssh_repo/repo.conf]"
  exit 1
fi

# 设置默认值
PORT=22
USER='root'
PASSWD=''

# 解析输入参数
while getopts h:P:u:p option
do 
    case "$option" in
        h)
            HOST=$OPTARG
            ;;
        P)
            PORT=$OPTARG
			      ;;
        u)
			      USER=$OPTARG
            ;;
        p)
            msg "请输入密码"
            read -s PASSWD
            ;;
        ?)
            script_help
            exit 1
			      ;;
    esac
done

# 参数校验
if [ -z ${HOST} ]
then
    msg "host_ip 不能为空"
    script_help
    exit 4
fi
if [ -z ${PASSWD} ]
then
  msg "输入的密码不能为空"
  exit 4
fi

# 检测仓库是否可用
STATUS_CODE=`curl -o /dev/null -s -w %{http_code} "${REPO_URL}/actuator/health"`
if [ ${STATUS_CODE} -ne 200 ]
then
    msg "仓库无法连接，请检查仓库地址"
    exit 5
fi


DB_PASSWD=`curl -s "${REPO_URL}/passwd?host=${HOST}&port=${PORT}&user=${USER}"`
if [ ${DB_PASSWD} ]
then
    # 如果存在数据库的密码，且输入的密码为空
    if [ -z ${PASSWD} ]
    then
        echo ${DB_PASSWD} | pbcopy
        msg "数据库中找到登录信息"
        msg "密码已经在剪贴板中，可直接粘贴"
    else
        # 如果输入的密码不为空，且输入的密码与数据库中的密码不同，更新数据库的密码
        if [ ${DB_PASSWD} != ${PASSWD} ]
        then
            repo_save ${HOST} ${PORT} ${USER} ${PASSWD}
            msg "登录信息密码变更"
        fi

        echo ${PASSWD} | pbcopy
        msg "密码已经在剪贴板中，可直接粘贴"
    fi
else
    # 如果输入的密码为空，直接退出程序
    if [ -z ${PASSWD} ]
    then
        msg "找不到登录信息"
        exit 1
    fi

    # 新增记录，把当前登录信息保存到数据库中
    repo_save ${HOST} ${PORT} ${USER} ${PASSWD}
    echo ${PASSWD} | pbcopy
    msg "新增登录信息"
    msg "密码已经在剪贴板中，可直接粘贴"
fi

ssh -p ${PORT} ${USER}@${HOST}