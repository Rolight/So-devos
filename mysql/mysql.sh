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

# set data dir
MyData=/data/mysql/data
MyLog=/data/mysql/logs

update_images() {
  # pull mysql docker image
  docker pull mysql

  check_exec_success "$?" "pulling 'mysql' image"
}

start() {

  update_images

  docker kill mysql 2>/dev/null
  docker rm -v mysql 2>/dev/null

  docker run -d --name mysql \
    -v ${MyData}:/var/lib/mysql \
    -v ${MyLog}:/var/log/mysql \
    --net=host \
    --log-opt max-size=10m \
    --log-opt max-file=9 \
    -e MYSQL_ROOT_PASSWORD=toor333666 \
    -e MYSQL_DATABASE=So \
    -e MYSQL_USER=rolight \
    -e MYSQL_PASSWORD=loulinhui \
    mysql

  check_exec_success "$?" "start mysql container"

}

stop() {
  docker stop mysql 2>/dev/null
  docker rm -v mysql 2>/dev/null
}

destroy() {
  stop
  rm -rf ${MyData}
  rm -rf ${MyLog}
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
  destroy) destroy ;;
  *)
    echo "Usage:"
    echo "./mysql.sh start|stop|restart"
    echo "./mysql.sh destroy"
    exit 1
    ;;
esac

exit 0
