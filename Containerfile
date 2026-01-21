# Use the official Fedora 43 Silverblue base
FROM quay.io/fedora/fedora-silverblue:43

# 1. REMOVE BLOAT
# In a container build, you use standard dnf commands for removals.
# Note: Fedora 43 uses DNF5 by default, which is faster and more efficient.
RUN dnf -y remove firefox firefox-langpacks gnome-software gnome-tour && \
    dnf clean all

# 2. ADD BRAVE REPOSITORY (RPM)
RUN dnf config-manager addrepo --id=brave-browser \
    --set=name='Brave Browser' \
    --set=baseurl='https://brave-browser-rpm-release.s3.brave.com/$basearch' \
    --set=gpgkey='https://brave-browser-rpm-release.s3.brave.com/brave-core.asc' \
    --set=gpgcheck=1

# 3. PREPARE OPT DIRECTORY
# This prevents the "cpio: mkdir failed" error by pre-creating the path
RUN rm /opt && mkdir -p /opt/brave.com && chmod 755 /opt/brave.com

# 3. INSTALL ALL TOOLS & JAVA SOURCES
# java-latest-openjdk (JDK 25+) is the standard for 2026.
RUN dnf -y install \
    brave-browser fastfetch \
    zsh neovim luarocks gcc-c++ tree-sitter-cli \
    the_silver_searcher ripgrep yubikey-manager wakeonlan \
    java-latest-openjdk-devel java-latest-openjdk-src \
    python3 python3-pip \
    nodejs npm \
    gnome-boxes \
    podman podman-docker \
    bootc && \
    dnf clean all

# --- FONT INSTALLATION BLOCK ---
# 1. Create the system font directory
# 2. Download the official JetBrainsMono zip from Nerd Fonts GitHub
# 3. Extract, clean up, and refresh the system font cache
RUN mkdir -p /usr/share/fonts/jetbrains-mono-nerd && \
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz" -o /tmp/JetBrainsMono.tar.xz && \
    tar -xf /tmp/JetBrainsMono.tar.xz -C /usr/share/fonts/jetbrains-mono-nerd && \
    # Remove everything except the actual font files to keep the image small
    find /usr/share/fonts/jetbrains-mono-nerd -type f ! -name "*.[ot]tf" -delete && \
    rm /tmp/JetBrainsMono.tar.xz && \
    # Register the fonts with the OS
    fc-cache -fv

# 4. ENABLE SERVICES
# Ensure the podman socket is active for rootless/root container management.
RUN systemctl enable podman.socket

# 5. FINAL LINT
# bootc lint verifies the image has required boot components (kernel, etc.)
RUN bootc container lint
