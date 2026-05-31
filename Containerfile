# Use the official Fedora 44 Silverblue base
FROM quay.io/fedora/fedora-silverblue:44

# Add brave browser repo
# Prepare /opt
# This prevents the "cpio: mkdir failed" error by pre-creating the path
# Cleanup and Install everything in one layer to keep image size down
RUN dnf config-manager \
    addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo && \
    rm -rf /opt && mkdir -p /opt/brave.com && chmod 755 /opt/brave.com && \
    dnf -y remove firefox firefox-langpacks gnome-software && \
    dnf -y install \
        brave-browser \
        zsh \
        gcc \
        gcc-c++ \
        glibc-devel \
        libxcrypt-compat \
        binutils \
        make && \
        dnf clean all

RUN bootc container lint
