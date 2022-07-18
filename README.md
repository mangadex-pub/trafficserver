# Apache Traffic Server

Mainline build scripts for Apache Traffic Server.

Mainly motivated by the absence of official Docker images, and the current
difficulty of fitting ATS' multi-process model with Docker.

**PROJECT STATUS: ALPHA**. We are barely starting to use those images ourselves
and recommend against anyone else doing so at the moment, until we have more
confidence in them ourselves.

[[_TOC_]]

## Quickstart

```shell
docker run -it \
    -v /path/to/etc/trafficserver:/etc/trafficserver:ro \
    -p "8080:8080" \
    registry.gitlab.com/mangadex-pub/trafficserver:9.1.2-bullseye
```

The following ATS versions are available:

- 9.1.2
- 9.2.x (development branch)

## How to make logging work

You need to use a 9.2.x line image. And it seems prone to issues atm,
see: https://github.com/apache/trafficserver/issues/8955

ATS' choices when it comes to log handling are ~~very irritating~~ rather old
school. As such, to obtain a decent "container-native" result (ie all logs being
sent to the container's stdout/stderr streams) you should add the following
lines in `records.config`:

```text
CONFIG proxy.node.config.manager_log_filename STRING stderr
CONFIG proxy.config.diags.logfile.filename    STRING stderr
CONFIG proxy.config.error.logfile.filename    STRING stderr
```

Additionally, it seems that using stdout doesn't work correctly for redirection
in a non-interactive situation like when using docker-compose. Hence the stderr.

Note that this being supported at all is a feature only from ATS 9.2, which is
currently not a stable release of ATS. (hence the 9.2.x branch base
in [Makefile](trafficserver/Makefile)).

It's still not quite perfect but at least it makes logs work half-decently.

## Non-root image

The image starts with user `mangadex (999:999)` and changing this requires
extending the image or mounting tmpfs directories, due to runtime directory
requirements of ATS.

See [Dockerfile](Dockerfile) and specifically this line:

```docker
RUN chown -v mangadex:mangadex /run/trafficserver /var/cache/trafficserver /var/log/trafficserver
```

## Immutable root filesystem

This image is made so an immutable filesystem can be used. You need to provide
tmpfs mounts for the following directories (using stock ATS configuration):

- /run/trafficserver:exec,uid=999,gid=999
- /var/log/trafficserver,uid=999,gid=999

In principle, if you follow
the [How to make logging work](#how-to-make-logging-work) section, you can drop
the `/var/log/trafficserver` tmpfs.
