# syntax=docker/dockerfile:1.2
FROM nvcr.io/nvidia/nvhpc:21.3-devel-cuda_multi-ubuntu20.04
ENV SPACK_PREFIX=/root/c2sm-spack
ENV SPACK_SYSTEM_CONFIG_PATH=/root/c2sm-spack/sysconfigs/unknown
ENV SPACK_ROOT=/root/c2sm-spack/spack

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

# setup spack-c2sm instance
RUN git clone --depth 1 --recurse-submodules --shallow-submodules -b dev_v0.18.1 https://github.com/C2SM/spack-c2sm.git ${SPACK_PREFIX}
RUN cd ${SPACK_PREFIX} && . ./setup-env.sh
RUN echo $SPACK_SYSTEM_CONFIG_PATH

# add Sergey spack package
COPY packages/icon ${SPACK_PREFIX}/packages/icon

RUN mkdir -p $SPACK_ROOT

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

ENTRYPOINT ["/bin/bash", "/root/c2sm-spack/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
