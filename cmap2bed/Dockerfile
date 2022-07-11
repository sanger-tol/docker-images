FROM continuumio/miniconda3

################## MAINTAINER ######################
MAINTAINER Yumi Sims yy5@sanger.ac.uk
################## INSTALLATION ######################

RUN which conda
RUN conda create -n cmap2bed python=3.7


RUN echo "deb http://security.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list
RUN apt-get update -y && apt-get install -y --no-install-recommends libssl1.0.0

ENV PATH=$PATH:/opt/conda/envs/cmap2bed/bin/

RUN mkdir -p scripts
COPY scripts /scripts/


RUN mkdir -p /data && chmod 664 -R /data
RUN chmod 664 /scripts/wrapper.sh


ENTRYPOINT ["/scripts/wrapper.sh"]
CMD ["-t inpiutcmap","-z enzyme"]
