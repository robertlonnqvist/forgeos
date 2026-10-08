#!/bin/sh

set -eu

# Remove stuff we dont need
dnf5 -y remove \
  firefox \
  firefox-langpacks \
  gnome-software \
  fedora-third-party

dnf5 clean all
rm -rf \
  /run/dnf \
  /var/cache/* \
  /var/lib/dnf \
  /var/log/* \
  /var/tmp/* \
  /tmp/*
