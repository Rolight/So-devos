# elasticsearch

## build image

```
./build.sh
```

## run container

```
docker run -d -p 9200:9200 -p 9300:9300 \
  -e "ES_HEAP_SIZE=${ESHeapSize}" \
  -v ${ESData}:/usr/share/elasticsearch/data \
  -v ${ESLog}:/usr/share/elasticsearch/logs \
  --net=host \
  --name elasticsearch \
  xxxxx/elasticsearch:2
```
