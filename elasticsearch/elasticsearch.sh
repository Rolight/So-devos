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

# get host ip
HostIP="$(ip route get 1 | awk '{print $NF;exit}')"

# set data dir
ESData=/data/elasticsearch/data
ESLog=/data/elasticsearch/logs

update_images() {
  # pull elasticsearch docker image
  docker pull daocloud.io/rolight/so-elasticsearch

  check_exec_success "$?" "pulling 'elasticsearch' image"
}

start() {

  update_images

  docker kill elasticsearch 2>/dev/null
  docker rm -v elasticsearch 2>/dev/null

  docker run -d --name elasticsearch \
    -v ${ESData}:/usr/share/elasticsearch/data \
    -v ${ESLog}:/usr/share/elasticsearch/logs \
    --net=host \
    --restart=always \
    --log-opt max-size=10m \
    --log-opt max-file=9 \
    daocloud.io/rolight/so-elasticsearch \
    --cluster.name=so \
    --network.bind_host=0.0.0.0 \
    --network.publish_host=${HostIP}

  check_exec_success "$?" "start elasticsearch container"

}

stop() {
  docker stop elasticsearch 2>/dev/null
  docker rm -v elasticsearch 2>/dev/null
}

destroy() {
  stop
  rm -rf ${ESData}
  rm -rf ${ESLog}
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
    echo "./elasticsearch.sh start|stop|restart"
    echo "./elasticsearch.sh destroy"
    exit 1
    ;;
esac

exit 0
