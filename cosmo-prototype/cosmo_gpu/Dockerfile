# 
# HPC COSMO image

FROM juckerj/external_swstack:cuda10.2
ARG nproc=4
ARG ssh_prv_key
ARG ssh_pub_key
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git && \
    rm -rf /var/lib/apt/lists/*

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# libgrib1
RUN git clone git@github.com:C2SM-RCM/libgrib1.git /var/tmp/libgrib1 && \
    cp -r /var/tmp/libgrib1/libgrib1_cosmo /usr/local/libgrib1
RUN cd /usr/local/libgrib1/source && \
    make clean -f Makefile.kesch.pgi -j$(nproc) && \
    make -f Makefile.kesch.pgi -j$(nproc) && \
    cp /usr/local/libgrib1/source/lib* /usr/local/libgrib1/. && \
    rm -rf /var/tmp/libgrib1

# libjasper 
RUN git clone git@github.com:C2SM-RCM/libjasper.git /var/tmp/libjasper && \
    cd /var/tmp/libjasper && \
    export libjasper_install=/usr/local/libjasper/ && \
    ./install.sh && \
    rm -rf /var/tmp/libjasper

# ECCODES 2.14
RUN mkdir -p /var/tmp/tar && wget -P /var/tmp/tar https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.14.1-Source.tar.gz && \
    cd /var/tmp/tar && tar xpzf eccodes-2.14.1-Source.tar.gz && rm eccodes-2.14.1-Source.tar.gz && \
    cp -r eccodes-2.14.1-Source /var/tmp/eccodes && rm -r /var/tmp/tar && \
    cd /var/tmp/ && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/eccodes \
    -DENABLE_JPG_LIBJASPER=ON -DCMAKE_Fortran_COMPILER=pgfortran ../eccodes && \
    make -j $(nproc) && \
    ctest && \
    make install && \
    rm -rf /var/tmp/eccodes
ENV LD_LIBRARY_PATH=/usr/local/eccodes/lib:$LD_LIBRARY_PATH  

# eccodes-cosmo-resources
RUN git clone git@github.com:COSMO-ORG/eccodes-cosmo-resources.git \
    /usr/local/eccodes/eccodes-cosmo-resources && \
    cd /usr/local/eccodes/eccodes-cosmo-resources && \
    git checkout 15f3a862d0349f4fc332e383c69acbed71b7804d
    
ENV GRIB_DEFINITION_PATH=/usr/local/eccodes/eccodes-cosmo-resources/definitions:/usr/local/eccodes/share/eccodes/definitions/
ENV GRIB_SAMPLES_PATH=/usr/local/eccodes/eccodes-cosmo-resources/samples/
ENV PATH=/usr/local/eccodes/bin/:$PATH

# Boost version 1.67.0
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        python3 \
        python3-numpy \
        python3-nose \
        bzip2 \
        libbz2-dev \
        tar \
        wget \
        zlib1g-dev \
        python-dev \
        libxml2-dev \
        libxslt-dev \
        git && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/boost_1_67_0.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/boost_1_67_0 && \
    ./bootstrap.sh --prefix=/usr/local/boost && \
    ./b2 -j$(nproc) -q install && \
    rm -rf /var/tmp/boost_1_67_0.tar.bz2 /var/tmp/boost_1_67_0
ENV LD_LIBRARY_PATH=/usr/local/boost/lib:$LD_LIBRARY_PATH

# Gritool Dycore 2.0
# Dummy libboost installation is needed, else the CMAKE does not find Boost, altough it is install in /usr/local/boost
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libboost-serialization1.65-dev  && \
    rm -rf /var/lib/apt/lists/*

RUN git clone git@github.com:GridTools/gridtools.git /var/tmp/gridtools && \
    cd /var/tmp/gridtools && git checkout 8101c64
ENV CXX=/usr/bin/g++ CC=/usr/bin/gcc FC=/usr/bin/gfortran CUDACXX=/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/compilers/bin/nvcc CUDAHOSTCXX=/usr/bin/g++
RUN cd /var/tmp/gridtools && \
    mkdir build && cd build && \
    cmake -DCUDAToolkit_INCLUDE_DIR=/usr/local/cuda/include \
    -DCUDA_CUDART=/usr/local/cuda/lib64/ \
    -DCMAKE_INSTALL_PREFIX=/usr/local/gridtools \
    -DBOOST_ROOT=/usr/local/boost \
    -DBOOST_INCLUDEDIR=/usr/local/boost/include/boost \
    ../.  && \
    make -j$(nproc) && \
    make install

# Serialbox
RUN git clone git@github.com:GridTools/serialbox.git /var/tmp/serialbox && \
    cd /var/tmp/serialbox && mkdir build && cd build && \
    cmake ../. \
    -DCMAKE_INSTALL_PREFIX=/usr/local/serialbox \
    -DSERIALBOX_ENABLE_FORTRAN=true \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DBOOST_ROOT=/usr/local/boost \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON && \
    make -j$(nproc) && \
    make install
#
## COSMO-ORG 
RUN git clone --branch docker git@github.com:jonasjucker/cosmo.git /usr/local/cosmo 

RUN cd /usr/local/cosmo/dycore && mkdir dycore_build && cd dycore_build && \
    cmake ../. -DCMAKE_BUILD_TYPE=Release \
    -DGridTools_DIR=/usr/local/gridtools/lib/cmake/GridTools/ \
    -DDYCORE_TARGET_ARCHITECTURE=gpu \
    -DCMAKE_INSTALL_PREFIX=/usr/local/cosmo/dycore/install_release \
    -DCUDA_CUDART=/usr/local/cuda/lib64 \
    -DCUDAToolkit_INCLUDE_DIR=/usr/local/cuda/include/ \
    -DCUDA_ARCH=sm_60 \
    -DSerialbox_DIR=/usr/local/serialbox/cmake/ \
    -DGT_ENABLE_BINDINGS_GENERATION=ON \
    -DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
    -DBOOST_ROOT=/usr/local/boost

#DYCORE
RUN cd /usr/local/cosmo/dycore/dycore_build && make -j$(nproc)
RUN cd /usr/local/cosmo/dycore/dycore_build && make install
ENV INSTALL_DIR=/usr/local DYCORE_DIR=/usr/local/cosmo/dycore/install_release/ 
ENV GRIDTOOLS_DIR=/usr/local/gridtools/ DYCOREGT=$DYCORE_DIR DYCOREGT_DIR=$DYCORE_DIR

#COSMO
RUN cd /usr/local/cosmo/cosmo/ACC && cp Options.docker.pgi.gpu Options && \
    make CPP_GT_DYCORE=1 -j $(nproc)

ENV COSMO_HOME=/usr/local/cosmo
ENV PATH=$PATH:/usr/local/cosmo/cosmo/ACC

WORKDIR /data
