#!/bin/bash

docker pull elasticsearch:2
docker tag elasticsearch:2 do.17bdc.com/elasticsearch:2
docker push do.17bdc.com/elasticsearch:2

docker build -t do.17bdc.com/shanbay/elasticsearch:2 .
docker push do.17bdc.com/shanbay/elasticsearch:2
