FROM quay.io/fedora/fedora-silverblue:44

COPY system_files/ /
COPY build_files/install.sh /tmp/install.sh
RUN /tmp/install.sh && rm /tmp/install.sh

RUN bootc container lint
