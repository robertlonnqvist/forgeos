# Use the official Fedora 43 Silverblue base
FROM quay.io/fedora/fedora-silverblue:43

# Add brave browser repo
RUN dnf config-manager addrepo --id=brave-browser \
    --set=name='Brave Browser' \
    --set=baseurl='https://brave-browser-rpm-release.s3.brave.com/$basearch' \
    --set=gpgkey='https://brave-browser-rpm-release.s3.brave.com/brave-core.asc' \
    --set=gpgcheck=1

# Prepare /opt
# This prevents the "cpio: mkdir failed" error by pre-creating the path
RUN rm -rf /opt && mkdir -p /opt/brave.com && chmod 755 /opt/brave.com

# Cleanup and Install everything in one layer to keep image size down
RUN dnf -y remove firefox firefox-langpacks gnome-software && \
    dnf -y install \
    brave-browser \
    zsh \
    gcc \
    gcc-c++ \
    glibc-devel \
    libxcrypt-compat \
    make && \
    dnf clean all

RUN bootc container lint
