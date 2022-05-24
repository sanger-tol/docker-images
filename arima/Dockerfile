FROM continuumio/miniconda3:4.10.3p0-alpine


ARG TAG=0.001

USER root

RUN apk update && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install -y samtools=1.14 perl && \
    ln -s /opt/conda/bin/perl /usr/bin/

# copy two Perl scripts modified from https://github.com/ArimaGenomics/mapping_pipeline
COPY --chmod=0755 filter_five_end.pl /usr/local/bin/
COPY --chmod=0755 two_read_bam_combiner.pl /usr/local/bin/


RUN adduser --disabled-password --gecos '' alpine && mkdir -p /home/alpine
USER    alpine
WORKDIR /home/alpine
