# syntax=docker/dockerfile:1.2
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-icon-mpich-dependencies as builder
ENV SPACK_PREFIX=/root/c2sm-spack
ENV SPACK_SYSTEM_CONFIG_PATH=/root/c2sm-spack/sysconfigs/unknown
ENV SPACK_ROOT=/root/c2sm-spack/spack
ENV ICON_SPEC="icon@container_build%nvhpc +mpi ^netlib-lapack ~external-blas ^$MPICH_SPEC"

# install dummy slurm
RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        slurm \
 && locale-gen en_US.UTF-8 \
 && pip3 install boto3 \
 && rm -rf /var/lib/apt/lists/*

#RUN echo "  slurm:" >> /root/.spack/packages.yaml && \
#    echo "      buildable: false" >> /root/.spack/packages.yaml && \
#    echo "      externals:" >> /root/.spack/packages.yaml && \
#    echo "      - spec: slurm%gcc" >> /root/.spack/packages.yaml && \
#    echo "        prefix: /usr" >> /root/.spack/packages.yaml && \
#    echo "  cuda:" >> /root/.spack/packages.yaml && \
#    echo "      buildable: false" >> /root/.spack/packages.yaml && \
#    echo "      externals:" >> /root/.spack/packages.yaml && \
#    echo "      - spec: cuda@11.0.221%gcc" >> /root/.spack/packages.yaml && \
#     echo "        prefix: /opt/nvidia/hpc_sdk/Linux_x86_64/21.3/cuda/11.0/" >> /root/.spack/packages.yaml && \
#    echo "  cmake:" >> /root/.spack/packages.yaml && \
#    echo "      buildable: false" >> /root/.spack/packages.yaml && \
#    echo "      externals:" >> /root/.spack/packages.yaml && \
#    echo "      - spec: cmake@3.16.3%gcc" >> /root/.spack/packages.yaml && \
#     echo "        prefix: /usr " >> /root/.spack/packages.yaml

RUN --mount=type=ssh spack install --fail-fast $ICON_SPEC

# dump paths to file
RUN echo $(spack find --format='{prefix.bin}' icon)/icon > /opt/icon

# dump spack-env to file
RUN echo $(spack load --sh $ICON_SPEC) > /opt/spack-env

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /root/c2sm-spack/spack/opt /root/c2sm-spack/spack/opt
COPY --from=builder /opt/icon /opt/icon
COPY --from=builder /opt/spack-env /opt/spack-env
COPY --from=builder /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf

RUN ln -s $(cat /opt/icon) /root/icon

# put spack-env into profile 
RUN echo "$(cat opt/spack-env)" >> /etc/profile

RUN ldconfig

ENV PATH=/root:$PATH

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root
