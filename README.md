Build docker image: 

```DOCKER_BUILDKIT=1 docker build --rm --ssh=default --build-arg NGINX_VERSION=1.22 -t nginx-upload-module .```


Run container:


```docker run --rm -it -p 80:80 nginx-upload-module```