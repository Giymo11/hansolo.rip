#!/bin/bash

docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v ~/hansolo.rip/volumes/proxy/conf.d:/etc/nginx/conf.d \
    -v ~/hansolo.rip/volumes/proxy/vhost.d:/etc/nginx/vhost.d \
    -v ~/hansolo.rip/volumes/proxy/html:/usr/share/nginx/html \
    -v ~/hansolo.rip/volumes/proxy/certs:/etc/nginx/certs:ro \
    nginx:alpine

docker run -d \
    --name nginx-proxy-gen \
    --volumes-from nginx-proxy \
    -v ~/hansolo.rip/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx-proxy -wait 5s:30s -watch /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run -d \
    --name nginx-proxy-letsencrypt \
    -e "NGINX_DOCKER_GEN_CONTAINER=nginx-gen" \
    --volumes-from nginx-proxy \
    -v ~/hansolo.rip/volumes/proxy/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion	

docker run -d \
    --name nginx-static \
    -e "VIRTUAL_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_EMAIL=gizmo.head@yahoo.de" \
    -v ~/hansolo.rip/volumes/static:/usr/share/nginx/html \
    nginx:alpine

# because it looks for the file before the docker-gen even generated it, we start the nginx-proxy again
docker start nginx-proxy
