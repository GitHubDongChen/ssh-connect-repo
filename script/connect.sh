#!/bin/sh

# 默认请求的仓库地址
REPO_URL="http://127.0.0.1:22021"

print_help(){
    echo "TODO"
	# echo "Usage: connect -h 192.168.1.1 "
    # echo "-h 表示ssh目标服务器"
    # echo "-u 表示执行远程操作用户"
    # echo "-j 表示脚本执行完成登录ssh目标服务器"
}

# 通用打印函数
print(){
  echo "==> ${1}"
}

# 保存账号密码到仓库
function save() {
    # ${1}=host
    # ${2}=port
    # ${3}=user
    # ${4}=passwd
    curl -X "POST" "${REPO_URL}/save" -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' --data-urlencode "host=${1}" --data-urlencode "port=${2}" --data-urlencode "user=${3}" --data-urlencode "passwd=${4}"
}

# 设置默认值
PORT=22
USER='root'
PASSWD=''

# 解析输入参数
while getopts h:P:u:p: option
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
            PASSWD=$OPTARG
            ;;
        ?)
            print_help
            exit 1
			      ;;
    esac
done

# 参数校验
if [ -z ${HOST} ]
then
    print "IP不能为空"
    print_help
    exit 1
fi

# 检测仓库是否可用
STATUS_CODE=`curl -o /dev/null -s -w %{http_code} "${REPO_URL}/actuator/health"`
if [ ${STATUS_CODE} -ne 200 ]
then
    print "仓库无法连接，请检查仓库地址"
    exit 5
fi


DB_PASSWD=`curl -s "${REPO_URL}/passwd?host=${HOST}&port=${PORT}&user=${PASSWD}"`
if [ ${DB_PASSWD} ]
then
    # 如果存在数据库的密码，且输入的密码为空
    if [ -z ${PASSWD} ]
    then
        echo ${DB_PASSWD} | pbcopy
        echo "==> 数据库中找到登录信息"
        echo "==> 密码已经在剪贴板中，可直接粘贴"
    else
        # 如果输入的密码不为空，且输入的密码与数据库中的密码不同，更新数据库的密码
        if [ ${DB_PASSWD} != ${PASSWD} ]
        then
            save ${HOST} ${PORT} ${USER} ${PASSWD}
            echo "==> 登录信息密码变更"
        fi

        echo ${PASSWD} | pbcopy
        echo "==> 密码已经在剪贴板中，可直接粘贴"
    fi
else
    # 如果输入的密码为空，直接退出程序
    if [ -z ${PASSWD} ]
    then
        echo "==> 找不到登录信息"
        exit 1
    fi

    # 新增记录，把当前登录信息保存到数据库中
    save ${HOST} ${PORT} ${USER} ${PASSWD}
    echo ${PASSWD} | pbcopy
    echo "==> 新增登录信息"
    echo "==> 密码已经在剪贴板中，可直接粘贴"
fi

ssh -p ${PORT} ${USER}@${HOST}