#!/usr/bin/env bash

set -e

# Fix for brave to install cleanly
rm -f /opt
mkdir -p /opt/brave.com

# Install rpm fusion for media drivers
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm

# Remove stuff we dont need (Some stuff taken from ublue/main)
dnf -y remove \
  firefox \
  firefox-langpacks \
  gnome-software \
  fedora-third-party

# Install the things we need like brave and support for brew
dnf -y install \
  brave-origin \
  zsh \
  gcc \
  gcc-c++ \
  glibc-devel \
  libxcrypt-compat \
  binutils \
  make \
  intel-media-driver

dnf remove -y rpmfusion-free-release rpmfusion-nonfree-release

dnf clean all
