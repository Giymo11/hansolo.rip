docker run -d -p 80:80 -p 443:443 \
    --name nginx \
    #-v ./nginx/conf.d:/etc/nginx/conf.d  \
    -v ./nginx/vhost.d:/etc/nginx/vhost.d \
    -v ./nginx/html:/usr/share/nginx/html \
    -v ./nginx/certs:/etc/nginx/certs:ro \
    nginx

docker run -d \
    --name nginx-gen \
    --volumes-from nginx \
    -v ./nginx/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run -d \
    --name nginx-letsencrypt \
    -e "NGINX_DOCKER_GEN_CONTAINER=nginx-gen" \
    --volumes-from nginx \
    -v ./nginx/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion	

docker run -d \
    --name nginx-static \
    -e "VIRTUAL_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_HOST=hansolo.rip,www.hansolo.rip" \
    -e "LETSENCRYPT_EMAIL=gizmo.head@yahoo.de" \
    -v ./static:/usr/share/nginx/html \
    nginx


