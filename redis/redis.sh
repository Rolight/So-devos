#!/bin/bash

check_exec_success() {
  # $1 is the content of the variable in quotes e.g. "$FROM_EMAIL"
  # $2 is the error message
  if [[ "$1" != "0" ]]; then
    echo "ERROR: $2 failed"
    echo "$3"
    exit -1
  fi
}

CurDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -a ${CurDir}/envs.sh ]]; then
  source ${CurDir}/envs.sh
fi

# get host ip
HostIP="$(ip route get 1 | awk '{print $NF;exit}')"

# set data dir
RedisData=/data/redis/data

update_images() {
  # pull redis docker image
  docker pull redis:3
  check_exec_success "$?" "pulling 'redis' image"
}

start() {

  update_images

  docker kill redis 2>/dev/null
  docker rm -v redis 2>/dev/null

  docker run -d --name redis \
    -p 6379:6379 \
    -v ${RedisData}:/data \
    --log-opt max-size=10m \
    --log-opt max-file=9 \
    redis:3

  check_exec_success "$?" "start redis container"
}

stop() {
  docker stop redis 2>/dev/null
  docker rm -v redis 2>/dev/null
}


##################
# Start of script
##################

case "$1" in
  start) start ;;
  stop) stop ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage:"
    echo "./redis.sh start|stop|restart"
    exit 1
    ;;
esac

exit 0
