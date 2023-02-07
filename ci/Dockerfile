FROM scratch

ADD apertis.tar.gz /

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

RUN mkdir /scripts
RUN mkdir /sources
COPY chroot/stage1.sh /scripts/chroot-stage1.sh
RUN /scripts/chroot-stage1.sh
