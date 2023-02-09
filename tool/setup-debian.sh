#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt -qq update
apt -qq -y --no-install-recommends install apt-utils apt-transport-https ca-certificates
apt -qq -y --no-install-recommends install \
      build-essential \
      bzip2 \
      ca-certificates \
      curl \
      debian-archive-keyring \
      flex \
      git \
      gnupg2 \
      hwloc \
      libfl-dev \
      libhwloc-dev \
      liblua5.4-dev \
      libpcre++-dev \
      libreadline-dev \
      libssl-dev \
      libsystemd-dev \
      libtool \
      pkg-config \
      tar \
      zlib1g-dev
