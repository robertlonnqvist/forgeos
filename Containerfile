ARG FEDORA_VERSION=44
FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_VERSION}

ARG FEDORA_VERSION
LABEL org.opencontainers.image.title="forgeos" \
      org.opencontainers.image.description="Custom Fedora Silverblue / bootc image" \
      org.opencontainers.image.source="https://github.com/robertlonnqvist/forgeos"

COPY system_files/ /
COPY build_files/install.sh /install.sh
RUN /install.sh && rm -f /install.sh

RUN bootc container lint
