# syntax=docker/dockerfile:experimental
ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION} as build

RUN apt-get update && \
    apt-get install -y \
        openssh-client \
        git \
        wget \
        libxml2 \
        libxslt1-dev \
        libpcre3 \
        libpcre3-dev \
        zlib1g \
        zlib1g-dev \
        openssl \
        libssl-dev \
        libtool \
        automake \
        gcc \
        g++ \
        make && \
    rm -rf /var/cache/apt

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    tar -C /usr/src -xzvf nginx-${NGINX_VERSION}.tar.gz

RUN mkdir -p -m 0600 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    
WORKDIR /src/ngx_devel_kit
RUN --mount=type=ssh git clone git@github.com:simpl/ngx_devel_kit .

WORKDIR /src/set-misc-nginx-module
RUN --mount=type=ssh git clone git@github.com:openresty/set-misc-nginx-module.git .

WORKDIR /usr/src/nginx-${NGINX_VERSION}
RUN NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    ./configure --with-compat --with-http_ssl_module --add-dynamic-module=/src/ngx_devel_kit --add-dynamic-module=/src/set-misc-nginx-module ${NGINX_ARGS} && \
    make modules

FROM nginx:${NGINX_VERSION}

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_set_misc_module.so /usr/src/nginx-${NGINX_VERSION}/objs/ndk_http_module.so /usr/lib/nginx/modules/