
FROM ubuntu:18.04 AS irods_base

ARG IRODS_VERSION=4.2.11-1~bionic
ARG DEBIAN_FRONTEND=noninteractive
ADD https://packages.irods.org/irods-signing-key.asc /tmp
RUN apt-get -y update \
    && apt-get -y install ca-certificates gnupg \
    && apt-key add /tmp/irods-signing-key.asc \
    && echo "deb [arch=amd64] https://packages.irods.org/apt/ bionic main" > /etc/apt/sources.list.d/renci-irods.list \
    && apt-get -y update \
    && apt-get -y install libjansson4 perl-modules libjson-perl liblist-allutils-perl \
    && apt-get -y install irods-runtime=$IRODS_VERSION \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*


FROM irods_base AS builder

ARG BATON_VERSION=3.2.0
ARG BATON_ARCHIVE_NAME=baton-$BATON_VERSION.tar.gz
ARG IRODS_VERSION=4.2.11-1~bionic
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp
ADD https://github.com/wtsi-npg/baton/releases/download/$BATON_VERSION/$BATON_ARCHIVE_NAME .
RUN tar xzf $BATON_ARCHIVE_NAME
WORKDIR baton-$BATON_VERSION

RUN apt-get -y update
RUN apt-get install -y build-essential libjansson-dev file python-sphinx
RUN apt-get install -y irods-dev=$IRODS_VERSION
RUN ./configure CPPFLAGS="-I/usr/include/irods" LDFLAGS="-L/usr/lib/irods/externals"
RUN make install


FROM irods_base AS runtime

COPY --from=builder /usr/local /usr/local/
RUN ldconfig /usr/local/lib/
CMD ["/usr/local/bin/baton"]
