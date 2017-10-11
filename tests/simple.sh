#!/bin/bash

echo "POST:   /api/images"
curl -i -X POST \
  http://10.0.2.2:3003/api/images \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{"name":"test","timestamp":1000000,"width":1920,"height":1080}'

echo "POST:   /api/images"
curl -i -X POST \
  http://10.0.2.2:3003/api/images \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{"name":"test","timestamp":1000000,"width":1920,"height":1080}'

echo "GET:    /api/images"
curl -i -X GET \
  http://10.0.2.2:3003/api/images/ \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json'

echo "GET:    /api/images/1"
curl -i -X GET \
  http://10.0.2.2:3003/api/images/1 \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json'

echo "DELETE: /api/images/1"
curl -i -X DELETE \
  http://10.0.2.2:3003/api/images/1 \
  -H 'cache-control: no-cache'

echo "DELETE: /api/images"
curl -i -X DELETE http://10.0.2.2:3003/api/images
