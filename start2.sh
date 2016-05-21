#!/bin/bash





docker run --name vsplunk \
    -v $(pwd)/volumes/splunk/etc:/opt/splunk/etc \
    -v $(pwd)/volumes/splunk/var:/opt/splunk/var \
    busybox

docker run --hostname splunk \
    --name splunk \
    --volumes-from=vsplunk \
    -e SPLUNK_START_ARGS="--accept-license --answer-yes --no-prompt" \
    -e "VIRTUAL_HOST=splunk.hansolo.rip" \
    -e "VIRTUAL_PORT=8000" \
    -e "LETSENCRYPT_HOST=splunk.hansolo.rip" \
    -e "LETSENCRYPT_EMAIL=gizmo.head@yahoo.de" \
    -d outcoldman/docker-stats-splunk:latest

docker run -d \
    --hostname splunk-forwarder \
    --name splunk-forwarder \
    --link=splunk \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -e "SPLUNK_FORWARD_SERVER=splunk:9997" \
    -p 127.0.0.1:1514:1514/udp \
    -d outcoldman/docker-stats-splunk-forwarder:latest

sleep 1
docker exec -t splunk-forwarder /sbin/entrypoint.sh splunk add udp 1514 -sourcetype syslog -auth admin:changeme


docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    --log-driver=syslog \
    --log-opt syslog-address=udp://127.0.0.1:1514 \
    --log-opt tag="{{.ImageName}}/{{.Name}}/{{.ID}}" \
    -v ~/hansolo.rip/volumes/proxy/conf.d:/etc/nginx/conf.d \
    -v ~/hansolo.rip/volumes/proxy/vhost.d:/etc/nginx/vhost.d \
    -v ~/hansolo.rip/volumes/proxy/html:/usr/share/nginx/html \
    -v ~/hansolo.rip/volumes/proxy/certs:/etc/nginx/certs:ro \
    nginx:alpine

docker run -d \
    --name nginx-proxy-gen \
    --log-driver=syslog \
    --log-opt syslog-address=udp://127.0.0.1:1514 \
    --log-opt tag="{{.ImageName}}/{{.Name}}/{{.ID}}" \
    --volumes-from nginx-proxy \
    -v ~/hansolo.rip/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx-proxy -wait 5s:30s -watch /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run -d \
    --name nginx-proxy-letsencrypt \
    --log-driver=syslog \
    --log-opt syslog-address=udp://127.0.0.1:1514 \
    --log-opt tag="{{.ImageName}}/{{.Name}}/{{.ID}}" \
    -e "NGINX_DOCKER_GEN_CONTAINER=nginx-gen" \
    --volumes-from nginx-proxy \
    -v ~/hansolo.rip/volumes/proxy/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion


docker start nginx-proxy

docker run -d \
    --name nginx-static \
    --log-driver=syslog \
    --log-opt syslog-address=udp://127.0.0.1:1514 \
    --log-opt tag="{{.ImageName}}/{{.Name}}/{{.ID}}" \
    -e "VIRTUAL_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_EMAIL=gizmo.head@yahoo.de" \
    -v ~/hansolo.rip/volumes/static:/usr/share/nginx/html \
    nginx:alpine 


