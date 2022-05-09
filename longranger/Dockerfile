FROM ubuntu:20.04

ARG TAG=2.2.2
ARG NAME=longranger-$TAG
ARG SRC_FILE=$NAME.tar.gz
ARG SRC_PATH=https://tolit.cog.sanger.ac.uk/software/$SRC_FILE
ARG DEST=/opt

LABEL base_image="ubuntu:20.04"
LABEL software="longranger"
LABEL software.version="$TAG"
LABEL about.summary="10X genomics aligner"
LABEL about.home="https://support.10xgenomics.com/genome-exome/software/pipelines/latest/what-is-long-ranger"
LABEL about.documentation="https://support.10xgenomics.com/genome-exome/software/pipelines/latest/algorithms/overview"
LABEL about.license_file="https://support.10xgenomics.com/genome-exome/software/downloads/latest"
LABEL about.license="10x Genomics End User Software License Agreement"
LABEL extra.identifiers.biotools="longranger"
LABEL about.tags="Genomics"
LABEL extra.binaries="longranger"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y wget \
    && wget -P /tmp $SRC_PATH \
    && mkdir -p $DEST \
    && tar -x -C $DEST -f /tmp/$SRC_FILE \
    && ln -s $DEST/$NAME/longranger /usr/local/bin/ \
    && rm /tmp/$SRC_FILE \
    && apt-get purge -y --auto-remove wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

