FROM quay.io/fedora/fedora-kinoite:44

RUN printf "[brave-browser]\nname=Brave Browser\nbaseurl=https://brave-browser-rpm-release.s3.brave.com/\$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc\n" > /etc/yum.repos.d/brave-browser.repo && \
    dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm && \
    rm -rf /opt && mkdir -p /opt/brave.com && chmod 755 /opt/brave.com && \
    mkdir -p /etc/NetworkManager/conf.d && \
    echo -e "[device]\nwifi.backend=iwd" > /etc/NetworkManager/conf.d/wifi-iwd.conf && \
    dnf -y remove firefox firefox-langpacks discover && \
    dnf -y swap wpa_supplicant iwd && \
    dnf -y install \
        kernel \
        kernel-devel \
        brave-origin \
        solaar \
        zsh \
        gcc \
        gcc-c++ \
        glibc-devel \
        libxcrypt-compat \
        binutils \
        make \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda && \
        dnf clean all && \
        systemctl enable iwd

RUN bootc container lint
