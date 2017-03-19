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
HostIP="$( python -c "import socket; print(socket.gethostbyname(socket.gethostname()))" )"

# set data dir
RedisData=/data/redis/data

# ES URL
ElasticsearchURL=http://$HostIP:9200

update_images() {
  # pull redis docker image
  docker pull kibana:5.2
  check_exec_success "$?" "pulling 'kibana' image"
}

start() {

  update_images

  docker kill kibana 2>/dev/null
  docker rm -v kibana 2>/dev/null

  docker run -d --name kibana \
    -v ${RedisData}:/data \
    -p 5601:5601 \
    --log-opt max-size=10m \
    --log-opt max-file=9 \
    -e ELASTICSEARCH_URL=${ElasticsearchURL} \
    kibana:5.2

  check_exec_success "$?" "start kibana container"
}

stop() {
  docker stop kibana 2>/dev/null
  docker rm -v kibana 2>/dev/null
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
    echo "./kibana.sh start|stop|restart"
    exit 1
    ;;
esac

exit 0
