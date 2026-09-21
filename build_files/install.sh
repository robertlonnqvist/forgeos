#!/usr/bin/env bash

set -euxo pipefail

# Remove stuff we dont need
dnf5 -y remove \
  firefox \
  firefox-langpacks \
  gnome-software \
  fedora-third-party

# Install the things we need
dnf5 -y install \
  distrobox \
  zsh \
  gcc \
  gcc-c++ \
  glibc-devel \
  libxcrypt-compat \
  binutils \
  make

dnf5 clean all
rm -rf \
  /run/dnf \
  /var/cache/* \
  /var/lib/dnf \
  /var/log/* \
  /var/tmp/* \
  /tmp/*
