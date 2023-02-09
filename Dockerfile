FROM docker.io/library/ubuntu:22.04 as base

ENV DEBIAN_FRONTEND "noninteractive"
ENV TZ "UTC"
RUN echo 'Dpkg::Progress-Fancy "0";' > /etc/apt/apt.conf.d/99progressbar

# This stage is mostly to import and unpack the dists in a docker-friendly fashion
FROM base as dists

RUN apt -qq update && apt install -qq -y bzip2

WORKDIR /tmp/trafficserver
COPY ./trafficserver/trafficserver-dist.tar.gz /tmp/trafficserver/trafficserver.tar.gz
RUN find . && tar xf trafficserver.tar.gz && rm -v trafficserver.tar.gz

FROM base

LABEL Name="Apache Traffic Server"
LABEL Vendor="MangaDex"

RUN apt -qq update && \
    apt -qq -y --no-install-recommends install \
      apt-utils \
      apt-transport-https \
      ca-certificates \
      openssl && \
    sed -i -e 's/http\:/https\:/g' /etc/apt/sources.list && \
    apt -qq update && \
    apt -qq -y --no-install-recommends install \
      ca-certificates \
      curl \
      dnsutils \
      hwloc \
      lua5.4 \
      liblua5.4-0 \
      libncursesw6 \
      procps && \
    apt -qq -y --purge autoremove && \
    apt -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/*

COPY --chown=root:root --from=dists /tmp/trafficserver /

# The script is all kinds of broken and should typically not be used
# keep it if ever useful, but have it renamed
RUN mv -fv /usr/bin/trafficserver /usr/bin/trafficserver.orig.sh

RUN groupadd -r -g 999 mangadex && \
    useradd -u 999 -r -g 999 mangadex && \
    usermod -a -G tty mangadex

# Until https://github.com/apache/trafficserver/issues/8955 is fixed, pull the old nginx docker tricks
RUN ln -sv /dev/stderr /var/log/trafficserver/manager.log && \
    ln -sv /dev/stderr /var/log/trafficserver/diags.log && \
    ln -sv /dev/stderr /var/log/trafficserver/error.log && \
    ln -sv /dev/stdout /var/log/trafficserver/traffic.log

RUN chown -v -R mangadex:mangadex \
      /run/trafficserver \
      /var/cache/trafficserver \
      /var/log/trafficserver

USER mangadex
WORKDIR /tmp

RUN traffic_server --version
CMD ["/usr/bin/traffic_manager"]
