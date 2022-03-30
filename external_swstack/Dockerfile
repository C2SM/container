# 
# external software stack for HPC COSMO image
# 

FROM nvidia/cuda:10.2-devel-ubuntu18.04 AS devel
ARG nproc=8
ENV DEBIAN_FRONTEND=noninteractive

# Python
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python \
        python3 vim && \
    rm -rf /var/lib/apt/lists/*

# PGI compiler version 20.7
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libnuma1 \
        perl \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P \
    /var/tmp https://developer.download.nvidia.com/hpc-sdk/nvhpc_2020_207_Linux_x86_64_cuda_multi.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/nvhpc_2020_207_Linux_x86_64_cuda_multi.tar.gz -C /var/tmp -z && \
    cd /var/tmp/nvhpc_2020_207_Linux_x86_64_cuda_multi && NVHPC_ACCEPT_EULA=accept NVHPC_INSTALL_DIR=/opt/nvidia/hpc_sdk NVHPC_SILENT=true NVHPC_DEFAULT_CUDA=10.2 ./install && \
    rm -rf /var/tmp/nvhpc_2020_207_Linux_x86_64_cuda_multi /var/tmp/nvhpc_2020_207_Linux_x86_64_cuda_multi.tar.gz
ENV LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/comm_libs/nvshmem/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/comm_libs/nccl/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/math_libs/lib64:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/compilers/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/cuda/lib64:$LD_LIBRARY_PATH \
    MANPATH=/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/compilers/man:$MANPATH \
    PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/comm_libs/nvshmem/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/comm_libs/nccl/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/profilers/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/compilers/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/20.7/cuda/bin:$PATH

ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_VISIBLE_DEVICES=all

## MPICH 3.1.4
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        build-essential \
        ca-certificates \
        automake \
        autoconf \
        libpmi2-0-dev \
        file \
        hwloc \
        libnuma-dev \
        make \
        openssh-client \
        perl \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz \
    && tar xf mpich-3.1.4.tar.gz \
    && cd mpich-3.1.4 \
    && ./configure --enable-fast=all,O3 --prefix=/usr \
    && make -j $(nproc) \
    && make install \
    && ldconfig \
    && cd .. \
    && rm -rf mpich-3.1.4 \
    && rm mpich-3.1.4.tar.gz
ENV LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH \
    PATH=/usr/bin/:$PATH

## CMake version 3.14.5
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://cmake.org/files/v3.14/cmake-3.14.5-Linux-x86_64.sh && \
    /bin/sh /var/tmp/cmake-3.14.5-Linux-x86_64.sh --prefix=/usr/local --skip-license && \
    rm -rf /var/tmp/cmake-3.14.5-Linux-x86_64.sh

# HDF5 version 1.10.1
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        file \
        make \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/hdf5-1.10.1.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/hdf5-1.10.1.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/hdf5-1.10.1 &&  CC=pgcc CXX=pgc++ F77=pgfortran F90=pgfortran FC=pgfortran ./configure --prefix=/usr/local/hdf5 --enable-cxx --enable-fortran && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/hdf5-1.10.1.tar.bz2 /var/tmp/hdf5-1.10.1
ENV HDF5_DIR=/usr/local/hdf5 \
    LD_LIBRARY_PATH=/usr/local/hdf5/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/hdf5/bin:$PATH

# NetCDF version 4.6.1, NetCDF C++ version 4.3.0, NetCDF Fortran
# version 4.4.4
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        file \
        libcurl4-openssl-dev \
        m4 \
        make \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.6.1.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/netcdf-4.6.1.tar.gz -C /var/tmp -z && \
    cd /var/tmp/netcdf-4.6.1 &&  CC=pgcc CPPFLAGS=-I/usr/local/hdf5/include CXX=pgc++ F77=pgfortran F90=pgfortran FC=pgfortran LDFLAGS=-L/usr/local/hdf5/lib ./configure --prefix=/usr/local/netcdf && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/netcdf-4.6.1.tar.gz /var/tmp/netcdf-4.6.1 && \
    mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx4-4.3.0.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/netcdf-cxx4-4.3.0.tar.gz -C /var/tmp -z && \
    cd /var/tmp/netcdf-cxx4-4.3.0 &&  CC=pgcc CPPFLAGS=-I/usr/local/netcdf/include CXX=pgc++ F77=pgfortran F90=pgfortran FC=pgfortran LD_LIBRARY_PATH='/usr/local/netcdf/lib:$LD_LIBRARY_PATH' LDFLAGS=-L/usr/local/netcdf/lib ./configure --prefix=/usr/local/netcdf && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/netcdf-cxx4-4.3.0.tar.gz /var/tmp/netcdf-cxx4-4.3.0 && \
    mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.4.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/netcdf-fortran-4.4.4.tar.gz -C /var/tmp -z && \
    cd /var/tmp/netcdf-fortran-4.4.4 &&  CC=pgcc CPPFLAGS=-I/usr/local/netcdf/include CXX=pgc++ F77=pgfortran F90=pgfortran FC=pgfortran LD_LIBRARY_PATH='/usr/local/netcdf/lib:$LD_LIBRARY_PATH' LDFLAGS=-L/usr/local/netcdf/lib ./configure --prefix=/usr/local/netcdf && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/netcdf-fortran-4.4.4.tar.gz /var/tmp/netcdf-fortran-4.4.4
ENV LD_LIBRARY_PATH=/usr/local/netcdf/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/netcdf/bin:$PATH

# perl 5.16.3 (needed by automake 1.13)
RUN cd /var/tmp && \
    wget https://www.cpan.org/src/5.0/perl-5.16.3.tar.gz && \
    tar xvf perl-5.16.3.tar.gz && \
    cd perl-5.16.3 && \
    sh Configure  -de && \
    make -j$(nproc) && \
    make install

ENV PATH=/usr/local/bin/:$PATH

# automake 1.13
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        autoconf && \
    rm -rf /var/lib/apt/lists/*

RUN cd /var/tmp && \
    wget http://ftp.gnu.org/gnu/automake/automake-1.13.tar.gz && \
    tar xvf automake-1.13.tar.gz && \
    cd automake-1.13 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    rm -rf /var/tmp/automake-1.13.tar.gz
