#!/bin/sh

function script_help(){
	echo "Usage: connect -h host_ip [-p] [-u root] [-P 22] 或者 connect host_ip"
  echo "  -h 目标机器IP"
  echo "  -p 手动输入SSH密码，命令执行过程中会提示输入密码"
  echo "  -u SSH用户"
  echo "  -P SSH端口"
}

# 通用消息显示函数
function msg(){
  echo "** ${1} **"
}

# 保存账号密码到仓库
function save_to_repo() {
  # ${1} host
  # ${2} port
  # ${3} user
  # ${4} passwd
  curl -X "POST" "${REPO_URL}/save" \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
    --data-urlencode "host=${1}" \
    --data-urlencode "port=${2}" \
    --data-urlencode "user=${3}" \
    --data-urlencode "passwd=${4}"
}

function save_to_clipboard() {
  # ${1} text
  echo ${1} | pbcopy
  msg "请在剪贴板中获取密码"
}

# 加载配置文件
if [[ -e ~/.ssh_repo/repo.conf ]]
then
  source ~/.ssh_repo/repo.conf
else
  msg "缺少仓库配置文件[~/.ssh_repo/repo.conf]"
  exit 1
fi

# 设置默认值
PORT=22
USER="root"
PASSWD=""
IS_INPUT=0

if [[ $# -gt 1 ]]
then
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
        IS_INPUT=1
        msg "请提供密码"
        read -s PASSWD
        ;;
      ?)
        script_help
        exit 1
        ;;
    esac
  done
else
  HOST=$1
fi

# 参数校验
if [[ -z ${HOST} ]]
then
  msg "请提供host_ip"
  script_help
  exit 4
fi
if [[ -z "${PASSWD}" && ${IS_INPUT} -eq 1 ]]
then
  msg "密码不能为空"
  exit 4
fi

# 检测仓库是否可用
STATUS_CODE=`curl --connect-timeout 5 -o /dev/null -s -w %{http_code} "${REPO_URL}/actuator/health"`
if [[ ${STATUS_CODE} -ne 200 ]]
then
  msg "仓库无法连接，请检查仓库地址"
  exit 5
fi


DB_PASSWD=`curl -s "${REPO_URL}/passwd?host=${HOST}&port=${PORT}&user=${USER}"`
if [[ ${DB_PASSWD} ]]
then
  # 如果存在数据库的密码，且输入的密码为空
  if [[ -z ${PASSWD} ]]
  then
    msg "仓库已找到登录信息"
    save_to_clipboard ${DB_PASSWD}
  else
    # 如果输入的密码不为空，且输入的密码与数据库中的密码不同，更新数据库的密码
    if [[ ${DB_PASSWD} != ${PASSWD} ]]
    then
        save_to_repo ${HOST} ${PORT} ${USER} ${PASSWD}
        msg "登录信息已变更"
    fi

    save_to_clipboard ${PASSWD}
  fi
else
  # 如果输入的密码为空，直接退出程序
  if [[ -z ${PASSWD} ]]
  then
    msg "未找到登录信息"
    msg "请提供密码"
    read -s PASSWD
  fi

  # 新增记录，把当前登录信息保存到仓库中
  save_to_repo ${HOST} ${PORT} ${USER} ${PASSWD}
  msg "登录信息以保存"
  save_to_clipboard ${PASSWD}
fi

ssh -p ${PORT} ${USER}@${HOST}