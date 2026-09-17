FROM quay.io/fedora/fedora-silverblue:44

COPY system_files/ /

RUN rm -rf /opt && mkdir -p /opt/brave.com && \
    dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm && \
    dnf -y remove firefox firefox-langpacks gnome-software && \
    dnf -y install \
        brave-origin \
        zsh \
        gcc \
        gcc-c++ \
        glibc-devel \
        libxcrypt-compat \
        binutils \
        make \
        libva \
        libva-utils \
        intel-media-driver && \
    rm -f /etc/yum.repos.d/rpmfusion-*.repo && \
    dnf clean all

RUN bootc container lint
