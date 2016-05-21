#!/bin/bash


docker stop nginx-static nginx-proxy-letsencrypt nginx-proxy-gen nginx-proxy splunk-forwarder splunk
docker rm nginx-static nginx-proxy-letsencrypt nginx-proxy-gen nginx-proxy splunk-forwarder splunk
