# hansolo.rip

This project aims to explore what goes into setting up a small development server.

This far, it does the following:
- Serve a simple, static website via [*nginx*](http://nginx.org/)
- Proxy via another *nginx* instance, enabling:
  - routing subdomains
  - https everywhere
  - load balancing
  - h2 (HTTP 2.0) even for backends not supporting that yet
- SSL/TLS via [*letsencrypt*](https://letsencrypt.org/)
- Encapsulate different services in [*docker*](https://www.docker.com/) containers
- Deployable with a single script, using 250-400MB RAM
- A logging, statistics and visualization solution via [*Splunk*](https://www.splunk.com)
  - I did take a look at the ELK stack, but that would not even run under 2GB RAM.

Future plans:
- a mail server
- gitlab
- postgres
- some dynamic JVM server (tomcat, blaze, etc)
- kafka
