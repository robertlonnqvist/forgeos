#!/usr/bin/env bash

set -e

# Fix for brave to install cleanly
rm -f /opt
mkdir -p /opt/brave.com

# MATCH UBLUE: Disable the problematic history archive repo right away
# This prevents dnf distro-sync from breaking on older Mesa references later.
dnf config-manager disable updates-archive

# Add Negativo17 Multimedia Repository and elevate priority
dnf config-manager addrepo --from-repofile="https://negativo17.org/repos/fedora-multimedia.repo"
dnf config-manager setopt fedora-multimedia.priority=90

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
    make

# =========================================================================
# UNIVERSAL BLUE GRAPHICS SYNC ARRAY (For Intel & AMD)
# =========================================================================
# Swaps stock graphics with unlocked Negativo17 files seamlessly.
# =========================================================================
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

dnf distro-sync --skip-unavailable -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf versionlock add "${OVERRIDES[@]}"

dnf clean all

rm -f /etc/yum.repos.d/rpmfusion-*.repo
