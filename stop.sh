#!/bin/bash

docker stop nginx-proxy
docker stop nginx-proxy-gen
docker stop nginx-proxy-letsencrypt
docker stop nginx-static

docker rm nginx-proxy
docker rm nginx-proxy-gen
docker rm nginx-proxy-letsencrypt
docker rm nginx-static
