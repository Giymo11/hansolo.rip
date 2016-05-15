#!/bin/bash

docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v $(pwd)/volumes/nginx/certs:/etc/nginx/certs:ro \
    -v $(pwd)/volumes/nginx/vhost.d:/etc/nginx/vhost.d \
    -v $(pwd)/volumes/nginx/html:/usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy

docker run -d \
    --name nginx-proxy-letsencrypt \
    -v $(pwd)/volumes/nginx/certs:/etc/nginx/certs:rw \
    --volumes-from nginx-proxy \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion

docker run -d \
    --name nginx-static \
    -e "VIRTUAL_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_EMAIL=gizmo.head@yahoo.de" \
    -v $(pwd)/volumes/static:/usr/share/nginx/html \
    nginx
