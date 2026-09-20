#!/usr/bin/env bash

set -euxo pipefail

# Fix for brave to install cleanly
rm -f /opt
mkdir -p /opt/brave.com

# Install brave repo
curl -fsSL https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo -o /etc/yum.repos.d/brave-browser.repo

dnf5 config-manager addrepo --from-repofile="https://negativo17.org/repos/fedora-multimedia.repo"
dnf5 config-manager setopt fedora-multimedia.priority=90

# See https://github.com/ublue-os/main/blob/main/build_files/install.sh
OVERRIDES=(
  "intel-gmmlib"
  "intel-mediasdk"
  "intel-vpl-gpu-rt"
  "libheif"
  "libva"
  "libva-intel-media-driver"
  "mesa-dri-drivers"
  "mesa-filesystem"
  "mesa-libEGL"
  "mesa-libGL"
  "mesa-libgbm"
  "mesa-va-drivers"
  "mesa-vulkan-drivers"
)

dnf5 distro-sync --skip-unavailable -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf5 versionlock add "${OVERRIDES[@]}"

# Remove stuff we dont need
dnf5 -y remove \
  firefox \
  firefox-langpacks \
  gnome-software \
  fedora-third-party

# Install the things we need like brave and support for brew
dnf5 -y install \
  brave-origin \
  zsh \
  gcc \
  gcc-c++ \
  glibc-devel \
  libxcrypt-compat \
  binutils \
  make \
  intel-media-driver

rm -f /etc/yum.repos.d/brave-browser.repo

dnf5 clean all
rm -rf \
  /run/dnf \
  /var/cache/* \
  /var/lib/dnf \
  /var/log/* \
  /var/tmp/* \
  /tmp/*
