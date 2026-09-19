#!/usr/bin/env bash

set -euxo pipefail

FEDORA_MAJOR="$(rpm -E %fedora)"

# Fix for brave to install cleanly
rm -f /opt
mkdir -p /opt/brave.com

# Install brave repo
curl -fsSL https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo -o /etc/yum.repos.d/brave-browser.repo

# Install rpm fusion for media drivers
dnf -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_MAJOR}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_MAJOR}.noarch.rpm"

# Remove stuff we dont need
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
rm -f /etc/yum.repos.d/brave-browser.repo

dnf clean all
rm -rf \
  /run/dnf \
  /var/cache/* \
  /var/lib/dnf \
  /var/log/* \
  /var/tmp/* \
  /tmp/*
