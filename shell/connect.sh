#!/bin/sh

REPO_URL="http://127.0.0.1:22022"

print_help(){
    echo "TODO"
	# echo "Usage: connect -h 192.168.1.1 "
    # echo "-h 表示ssh目标服务器"
    # echo "-u 表示执行远程操作用户"
    # echo "-j 表示脚本执行完成登录ssh目标服务器"
}

PORT=22
USER='root'
PASSWD=''

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

if [ -z ${HOST} ]
then
    echo "==> IP不能为空"
    print_help
    exit 1
fi

function find() {
    # host port user
    result=`curl -s "${REPO_URL}/passwd?host=${1}&port=${2}&user=${3}"`
    if [ -z ${result} ]
    then
        # 找不到密码
        return 0
    else
        DB_PASSWD=${result}
        return 1
    fi
}

function save() {
    # host port user passwd
    curl -X "POST" "${REPO_URL}/save" -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' --data-urlencode "host=${1}" --data-urlencode "port=${2}" --data-urlencode "user=${3}" --data-urlencode "passwd=${4}"
}

DB_PASSWD=''
find ${HOST} ${PORT} ${USER}
# 返回码为1，数据库中存在密码
# 返回码为0，数据库中无登录信息
if [ $? -eq 1 ]
then
    # 如果输入的密码为空，直接使用数据库的密码
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