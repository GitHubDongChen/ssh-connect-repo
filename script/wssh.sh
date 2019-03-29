#!/bin/sh

# 设置默认值
PORT=22
USER="root"
PASSWD=${pwd}
ALIAS=${a}

# 常量
T='true'
readonly T
F='false'
readonly F

function is_option() {
  # 参数解析函数
  if [[ ${1} == '-'* ]]
  then
      echo ${T}
  else
      echo ${F}
  fi
}

function contains_user() {
  # 参数解析函数
  if [[ ${1} == *'@'* ]]
  then
      echo ${T}
  else
      echo ${F}
  fi
}

function msg(){
  # 通用消息显示函数
  echo "\033[34m==>\033[0m \033[30m${1}\033[0m"
}

function save_to_repo() {
  # 保存账号密码到仓库
  # ${1} host
  # ${2} port
  # ${3} user
  # ${4} passwd
  # ${5} alias
  curl -X "POST" "${REPO_URL}/save" \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
    --data-urlencode "host=${1}" \
    --data-urlencode "port=${2}" \
    --data-urlencode "user=${3}" \
    --data-urlencode "passwd=${4}" \
    --data-urlencode "alias=${5}"
}

function save_to_clipboard() {
  # 保存到剪贴板
  # ${1} text
  echo ${1} | pbcopy
}

# 加载配置文件
if [[ -e ~/.ssh_repo/repo.conf ]]
then
  source ~/.ssh_repo/repo.conf
else
  msg "缺少仓库配置文件[~/.ssh_repo/repo.conf]"
  exit 1
fi

# 检测仓库是否可用
STATUS_CODE=`curl --connect-timeout 5 -o /dev/null -s -w %{http_code} "${REPO_URL}/actuator/health"`
if [[ ${STATUS_CODE} -ne 200 ]]
then
  msg "仓库无法连接，请检查仓库地址:${REPO_URL}"
  ssh $@
  exit 1
fi

# 根据别名查询ssh登录信息
if [[ $# == 1 ]]
then
  SSH_INFO=`curl -s --connect-timeout 5 "${REPO_URL}/alias/${1}"`
  if [[ ${SSH_INFO} ]]
  then
    msg "仓库已找到<${USER}@${HOSTNAME}:${PORT}>登录信息"

    HOSTNAME=`echo ${SSH_INFO} | jq -r .host`
    PORT=`echo ${SSH_INFO} | jq -r .port`
    USER=`echo ${SSH_INFO} | jq -r .user`
    PASSWD=`echo ${SSH_INFO} | jq -r .passwd`
    ALIAS_DB=`echo ${SSH_INFO} | jq -r .alias`

    if [[ ${ALIAS} && ${ALIAS_DB} != ${ALIAS} ]]
    then
      save_to_repo ${HOSTNAME} ${PORT} ${USER} ${PASSWD} ${ALIAS}
      msg "更新别名为<${ALIAS}>"
    fi

    save_to_clipboard ${PASSWD}
    msg "请在剪贴板中获取密码"


    ssh -p ${PORT} ${USER}@${HOSTNAME}
    exit 0
  fi
fi

# 参数解析开始
PORT_EXIST=${F}
USER_EXIST=${F}
SHOULD_BE_OPTION=${T}

for i in "$@"; do
#  echo ${i}
  result=$(is_option ${i})
  # 匹配到option
  if [[ ${result} == ${T} && ${SHOULD_BE_OPTION} == ${T} ]]
  then
    SHOULD_BE_OPTION=${F}

    # 解析端口
    if [[ ${i} == '-p' ]]
    then
      READ_PORT=${T}
    fi

    continue
  fi

  # 匹配到value
  if [[ ${result} == ${F} && ${SHOULD_BE_OPTION} == ${F} ]]
  then
    SHOULD_BE_OPTION=${T}

    if [[ ${READ_PORT} == ${T} ]]
    then
      PORT=${i}
      PORT_EXIST=${T}
    fi

    continue
  fi

  # 匹配到destination
  if [[ $(contains_user ${i}) == ${T} ]]
  then
    USER=${i%@*}
    USER_EXIST=${T}
    HOSTNAME=${i#*@}
  else
    if [[ HOSTNAME_INIT == ${T} ]]
    then
      continue
    fi

    HOSTNAME=${i}
  fi
done
# 参数解析结束

# 查询数据库开始
DB_PASSWD=`curl -s --connect-timeout 5 "${REPO_URL}/passwd?host=${HOSTNAME}&port=${PORT}&user=${USER}"`
if [[ ${DB_PASSWD} ]]
then
  if [[ -z ${PASSWD} ]]
  then # 如果存在数据库的密码，且输入的密码为空
    msg "仓库已找到登录信息"
    save_to_clipboard ${DB_PASSWD}
    msg "请在剪贴板中获取密码"
    if [[ ${ALIAS} ]]
    then
      save_to_repo ${HOSTNAME} ${PORT} ${USER} ${DB_PASSWD} ${ALIAS}
      msg "更新别名为<${ALIAS}>"
    fi
  else
    if [[ ${DB_PASSWD} != ${PASSWD} ]]
    then # 如果输入的密码不为空，且输入的密码与数据库中的密码不同，更新数据库的密码
        save_to_repo ${HOSTNAME} ${PORT} ${USER} ${PASSWD} ${ALIAS}
        msg "登录信息已变更"
    fi

    save_to_clipboard ${PASSWD}
    msg "请在剪贴板中获取密码"
  fi
else
  if [[ -z ${PASSWD} ]]
  then # 如果输入的密码为空，直接退出程序
    msg "未找到登录信息"
    msg "请提供<${USER}@${HOSTNAME}:${PORT}>密码"
    read -s PASSWD
  fi

  # 新增记录，把当前登录信息保存到仓库中
  save_to_repo ${HOSTNAME} ${PORT} ${USER} ${PASSWD} ${ALIAS}
  msg "登录信息以保存"
  save_to_clipboard ${PASSWD}
  msg "请在剪贴板中获取密码"
fi
# 查询数据库结束

if [[ ${PORT_EXIST} == ${T} && ${USER_EXIST} == ${T} ]]
then
  ssh $@
elif [[ ${PORT_EXIST} == ${T} && ${USER_EXIST} == ${F} ]]
then
  ssh -l ${USER} $@
elif [[ ${PORT_EXIST} == ${F} && ${USER_EXIST} == ${T} ]]
then
  ssh -p ${PORT} $@
else
  ssh -p ${PORT} -l ${USER} $@
fi