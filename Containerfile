# Use the official Fedora 43 Silverblue base
FROM quay.io/fedora/fedora-silverblue:43

# 1. Remove the stuff I don't need
RUN dnf -y remove firefox firefox-langpacks gnome-software && dnf clean all

# 2. Add brave browser
RUN dnf config-manager addrepo --id=brave-browser \
    --set=name='Brave Browser' \
    --set=baseurl='https://brave-browser-rpm-release.s3.brave.com/$basearch' \
    --set=gpgkey='https://brave-browser-rpm-release.s3.brave.com/brave-core.asc' \
    --set=gpgcheck=1

# 3. Prepare /opt
# This prevents the "cpio: mkdir failed" error by pre-creating the path
RUN rm /opt && mkdir -p /opt/brave.com && chmod 755 /opt/brave.com

# 3. Install brave-browser and my zsh
RUN dnf -y install brave-browser zsh && dnf clean all

RUN bootc container lint
