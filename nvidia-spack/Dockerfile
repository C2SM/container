# syntax=docker/dockerfile:1.2
FROM nvcr.io/nvidia/nvhpc:21.3-devel-cuda_multi-ubuntu20.04
ENV SPACK_COMMIT=e24e71be6aec4e83b2d7a9023068cab377132bbe
ENV C2SM_SPACK_COMMIT=ccbe8bcdc6e84845f8d50ab627429b5b4494ceeb
ENV ROOT=/opt
ENV SPACK_ROOT=$ROOT/spack

RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        file \
        g++ \
        gcc \
        gfortran \
        git \
        gnupg2 \
        iproute2 \
        locales \
        make \
        python3 \
        python3-pip \
        python3-setuptools \
        tcl \
        unzip \
 && locale-gen en_US.UTF-8 \
 && pip3 install boto3 \
 && rm -rf /var/lib/apt/lists/*

 # Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# clone spack
RUN --mount=type=ssh git clone git@github.com:spack/spack.git $ROOT/spack && \
    cd $ROOT/spack && git checkout $SPACK_COMMIT

# clone c2sm-spack
RUN --mount=type=ssh git clone git@github.com:C2SM/spack-c2sm.git $ROOT/spack-c2sm && \
    cd $ROOT/spack-c2sm && git checkout $C2SM_SPACK_COMMIT

# Apply patches for C2SM packages

# Eccodes: strip "%gcc" from CMake
COPY patches/ECCODES_CMake_remove_gcc.patch $ROOT/spack-c2sm/ECCODES_CMake_remove_gcc.patch
RUN cd $ROOT/spack-c2sm && git apply ECCODES_CMake_remove_gcc.patch

# Cosmo: strip "%gcc" from CMake
COPY patches/COSMO_CMake_remove_gcc.patch $ROOT/spack-c2sm/COSMO_CMake_remove_gcc.patch
RUN cd $ROOT/spack-c2sm && git apply COSMO_CMake_remove_gcc.patch

# Int2lm: change lib64 to lib, link to libmpichf90 instead of libmpich
COPY patches/INT2LM_lib64_to_lib.patch $ROOT/spack-c2sm/INT2LM_lib64_to_lib.patch
RUN cd $ROOT/spack-c2sm && git apply INT2LM_lib64_to_lib.patch

# Spack-C2SM: setup config for host "container"
COPY patches/SPACK_C2SM_container_config.patch $ROOT/spack-c2sm/SPACK_C2SM_container_config.patch
RUN cd $ROOT/spack-c2sm && git apply SPACK_C2SM_container_config.patch

# setup spack-c2sm instance
# Note: clone of spack is skipped, because already installed previously
RUN cd $ROOT/spack-c2sm && ./config.py -m container -u OFF -i $ROOT \
    -p $ROOT -s $ROOT -c $ROOT -v develop --no_yaml_copy

# Apply patch for spack
COPY patches/SPACK_url.patch $SPACK_ROOT/SPACK_url.patch
RUN cd $SPACK_ROOT && git apply SPACK_url.patch


RUN mkdir -p $SPACK_ROOT/opt/spack

RUN ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash \
          /usr/local/bin/docker-shell \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash \
          /usr/local/bin/interactive-shell \
 && ln -s $SPACK_ROOT/share/spack/docker/entrypoint.bash \
          /usr/local/bin/spack-env

# Add LANG default to en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir -p /root/.spack \
 && cp $SPACK_ROOT/share/spack/docker/modules.yaml \
        /root/.spack/modules.yaml \
 && rm -rf /root/*.* /run/nologin $SPACK_ROOT/.git


# Add basic stuff needed for C2SM-packages
RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        gcc-8 \
        g++-8 \
        gfortran-8 \
        cmake \
        perl \
 && locale-gen en_US.UTF-8 \
 && pip3 install boto3 \
 && rm -rf /var/lib/apt/lists/*

# [WORKAROUND]
# https://superuser.com/questions/1241548/
#     xubuntu-16-04-ttyname-failed-inappropriate-ioctl-for-device#1253889
RUN [ -f ~/.profile ]                                               \
 && sed -i 's/mesg n/( tty -s \&\& mesg n || true )/g' ~/.profile \
 || true

WORKDIR /root
SHELL ["docker-shell"]

# TODO: add a command to Spack that (re)creates the package cache
RUN spack spec hdf5+mpi

RUN spack compiler find

RUN spack external find --not-buildable cmake perl python

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
