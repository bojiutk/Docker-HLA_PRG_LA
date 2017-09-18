FROM ubuntu:17.04

MAINTAINER Bo Ji <bo.ji@wustl.edu>

# Set up for make get-deps
RUN mkdir /app
WORKDIR /app
COPY . /app

VOLUME /app/build
VOLUME /app/release
# Install dependencies and clear the package index
RUN \
    apt-get update -qq \
    && apt-get -y install \
        apt-transport-https \
        git && \
    apt-get update -qq && \
    apt-get -y install \
     libnss-sss \
     cowsay \  
     build-essential \
     pkg-config \
     libbz2-dev \
     git-core \
     cmake \
     g++-4.8 \
     libstdc++6 \
     automake \
     libncurses5-dev \
     autoconf \
     autoconf-archive \
     libtool \
     libboost-dev \
     libdouble-conversion-dev \
     liblz4-dev \
     liblzma-dev \
     libsnappy-dev \
     make \
     picard \
     zlib1g-dev \
     libjemalloc-dev \
     libssl-dev \
     openssl \
     libreadline-dev \
     libicu-dev \
     wget \
     libboost-all-dev \
        --no-install-recommends && \
    apt-get clean all



ENV BOOST_ROOT /usr
ENV SEQTK_ROOT /app/htslib

RUN  git clone https://github.com/samtools/htslib.git && \
     cd /app/htslib  && \
     make && \
     make lib-static && \
     make install
ARG boost_version=1.62.0
ARG boost_dir=boost_1_62_0
ARG boost_sha256_sum=440a59f8bc4023dbe6285c9998b0f7fa288468b889746b1ef00e8b36c559dce1
ENV boost_version ${boost_version}

ARG boost_libs=" \
  --with-atomic \
  --with-chrono \
  --with-date_time \
  --with-filesystem \
  --with-log \
  --with-regex \
  --with-system \
  --with-thread"
RUN wget http://downloads.sourceforge.net/project/boost/boost/${boost_version}/${boost_dir}.tar.gz \
  && echo "${boost_sha256_sum}  ${boost_dir}.tar.gz" | sha256sum -c \
  && pwd \
  && tar xfz /app/${boost_dir}.tar.gz \
  && cd /app/${boost_dir} \
  && ./bootstrap.sh --prefix=/usr \
  && ./b2 -j 4 stage $boost_libs \
  && ./b2 -j 4 install $boost_libs 
  #&& cd .. && rm -rf ${boost_dir} && ldconfig




RUN git clone git://github.com/pezmaster31/bamtools.git && \
    cd /app/bamtools && \
    mkdir build && cd build && cmake .. && make


RUN git clone https://github.com/samtools/samtools.git && \
    cd /app/samtools \
    && make \
    && make install


    
RUN wget http://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.15.tar.bz2 \
    --no-check-certificate \
	&& tar xjf bwa-0.7.15.tar.bz2 \
	&& cd bwa-0.7.15 \
	&& make -j 8 \
	&& mv bwa /usr/bin/ 
	#&& cd .. 
	#&& rm -rf. bwa-*
     


RUN ls && \
    cd /app/HLA-PRG-LA/src && \
    make all 

ENV SHELL /bin/bash

CMD ["/bin/bash"]
