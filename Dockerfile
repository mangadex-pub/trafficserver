FROM docker.io/library/debian:bullseye as base

ENV DEBIAN_FRONTEND "noninteractive"
ENV TZ "UTC"
RUN echo 'Dpkg::Progress-Fancy "0";' > /etc/apt/apt.conf.d/99progressbar

# This stage is mostly to import and unpack the dists in a docker-friendly fashion
FROM base as dists

RUN apt -qq update && apt install -qq -y bzip2

WORKDIR /tmp/trafficserver
COPY ./trafficserver/trafficserver-dist.tar.gz /tmp/trafficserver/trafficserver.tar.gz
RUN ls -alh && tar xf trafficserver.tar.gz && rm -v trafficserver.tar.gz

FROM base

LABEL Name="Apache Traffic Server"
LABEL Vendor="MangaDex"
MAINTAINER MangaDex <opensource@mangadex.org>

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
      debian-archive-keyring \
      hwloc \
      lua5.4 \
      liblua5.4-0 \
      libncursesw6 && \
    apt -qq -y --purge autoremove && \
    apt -qq -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /var/log/*

COPY --chown=root:root --from=dists /tmp/trafficserver /

ENV LD_LIBRARY_PATH "/usr/local/lib"
RUN traffic_server --version

RUN groupadd -r -g 999 mangadex && \
    useradd -u 999 -r -g 999 mangadex

USER mangadex
WORKDIR /tmp

ENV STDOUTLOG="/dev/stdout" \
    STDERRLOG="/dev/stderr" \
    TM_PIDFILE="/tmp/trafficserver_manager.lock" \
    TS_PIDFILE="/tmp/trafficserver_server.lock"

CMD ["/usr/local/bin/traffic_server"]
