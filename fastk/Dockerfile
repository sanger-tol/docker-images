FROM r-base

RUN apt-get update && apt-get install -y \
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
        libsodium-dev \
        autoconf \
        automake \
        lsb-release \
    && sed -i '/^#.* en_GB.UTF-8 /s/^#//' /etc/locale.gen && locale-gen && update-locale LC_ALL="en_GB.UTF-8" \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone https://github.com/thegenemyers/FASTK.git && \
    (cd FASTK &&    \
    make && make DEST_DIR=/usr/local/bin install) && \
    git clone https://github.com/thegenemyers/MERQURY.FK.git && \
    (cd MERQURY.FK && \
    make && make DEST_DIR=/usr/local/bin install) && \
    git clone https://github.com/thegenemyers/GENESCOPE.FK.git && \
    (cd GENESCOPE.FK && \
    Rscript -e 'install.packages("argparse", dependencies=TRUE)' && \
    Rscript -e 'install.packages("minpack.lm", dependencies=TRUE)' && \
    Rscript -e 'install.packages("ggplot2", dependencies=TRUE)' && \
    Rscript -e 'install.packages("scales", dependencies=TRUE)' && \
    Rscript -e 'install.packages("viridis", dependencies=TRUE)' && \
    Rscript -e 'install.packages("cowplot", dependencies=TRUE)' && \
    Rscript -e 'install.packages(".", repos=NULL, type="source")' && \
    cp GeneScopeFK.R /home/docker/GeneScopeFK.R) && \
    rm -rf /tmp/*

WORKDIR /home/docker/

ENTRYPOINT ["Rscript", "/home/docker/GeneScopeFK.R"]
