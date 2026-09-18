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
    google-noto-sans-cjk-vf-fonts \
    default-fonts-cjk-sans \
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
    make

# Intel graphics
dnf -y install intel-media-driver
# AMD graphics
#dnf -y install mesa-va-drivers mesa-va-drivers-freeworld
# Nvidia graphics
#dnf -y --setopt=tsflags=noscripts install akmod-nvidia-open xorg-x11-drv-nvidia-cuda libva-nvidia-driver

dnf clean all

rm -f /etc/yum.repos.d/rpmfusion-*.repo
