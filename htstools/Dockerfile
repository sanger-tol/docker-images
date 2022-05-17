ARG  ubuntu_version=18.04
FROM ubuntu:${ubuntu_version}

USER root

# ubuntu18 as no irods packages available for later versions yet
# gnuplot for plot-bamstats
# python/matplotlib/texlive for plot-vcfstats

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        locales \
        build-essential \
        curl \
        git \
        libbz2-dev \
        libcurl4-openssl-dev \
        libgsl0-dev \
        liblzma-dev \
        libncurses5-dev \
        libperl-dev \
        libssl-dev \
        zlib1g-dev \
        gnuplot \
        python3-matplotlib \
        python3-numpy \
        texlive-latex-base \
        texlive-fonts-recommended \
        texlive-fonts-extra \
        texlive-latex-extra \
        libsodium-dev \
        autoconf \
        automake \
        lsb-release \
    && sed -i '/^#.* en_GB.UTF-8 /s/^#//' /etc/locale.gen && locale-gen && update-locale LC_ALL="en_GB.UTF-8" \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ARG htsversion=1.15.1
ARG samversion=1.15.1
ARG bcfversion=1.15.1
ARG libdeflateversion=1.10

RUN curl -L https://packages.irods.org/irods-signing-key.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    apt-get install -y irods-dev irods-externals-* irods-auth-plugin-krb && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L https://github.com/ebiggers/libdeflate/archive/v${libdeflateversion}.tar.gz | tar xz && \
    (cd libdeflate-${libdeflateversion} && make install) && \
    curl -L https://github.com/samtools/htslib/releases/download/${htsversion}/htslib-${htsversion}.tar.bz2 | tar xj && \
    (cd htslib-${htsversion} && ./configure --with-libdeflate --enable-plugins --with-plugin-path='$(libexecdir)/htslib:/usr/libexec/htslib' && make install) && \
    ldconfig && \
    curl -L https://github.com/samtools/samtools/releases/download/${samversion}/samtools-${samversion}.tar.bz2 | tar xj && \
    (cd samtools-${samversion} && ./configure --with-htslib=system && make install) && \
    curl -L https://github.com/samtools/bcftools/releases/download/${bcfversion}/bcftools-${bcfversion}.tar.bz2 | tar xj && \
    (cd bcftools-${bcfversion} && ./configure --enable-libgsl --enable-perl-filters --with-htslib=system && make install) && \
    git clone --depth 1 https://github.com/samtools/htslib-plugins.git && \
    (cd htslib-plugins && sed -i 's/init_client_api_table/load_client_api_plugins/g' hfile_irods.c && make install) && \
    git clone --depth 1 https://github.com/samtools/htslib-crypt4gh.git && \
    (cd htslib-crypt4gh && autoheader && autoconf -Wno-syntax && ./configure --with-htslib=system && cp config.h include/ && make install) && \
    rm -rf /tmp/*

RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu
USER    ubuntu
WORKDIR /home/ubuntu