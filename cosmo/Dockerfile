# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-mpich as builder
ENV COSMO_SPEC="cosmo@c2sm-master%nvhpc cosmo_target=cpu cuda_arch=60 ~cppdycore ^$MPICH_SPEC"

# install dummy slurm
RUN apt-get -yqq update \
 && apt-get -yqq install --no-install-recommends \
        slurm \
 && locale-gen en_US.UTF-8 \
 && pip3 install boto3 \
 && rm -rf /var/lib/apt/lists/*

RUN echo "  slurm:" >> /root/.spack/packages.yaml && \
    echo "      buildable: false" >> /root/.spack/packages.yaml && \
    echo "      externals:" >> /root/.spack/packages.yaml && \
    echo "      - spec: slurm%gcc" >> /root/.spack/packages.yaml && \
    echo "        prefix: /usr" >> /root/.spack/packages.yaml

# mpich for COSMO-CPU
RUN --mount=type=ssh spack installcosmo --only dependencies $COSMO_SPEC

RUN --mount=type=ssh spack installcosmo -v --only package $COSMO_SPEC

RUN echo $(spack find --paths cosmo | grep -o -P '/opt/spack-install/.*')/bin/cosmo_cpu > /opt/cosmo

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/cosmo /opt/cosmo

RUN ln -s $(cat /opt/cosmo) /root/cosmo_cpu

# paths cannot be hardcoded in the future
ENV GRIB_SAMPLES_PATH=/opt/spack-install/container/cosmo-eccodes-definitions/2.19.0.5/nvhpc/6odt5ecgbcadsebb5kst62zuoq5u7jna/cosmoDefinitions/samples
ENV GRIB_DEFINITION_PATH=/opt/spack-install/container/cosmo-eccodes-definitions/2.19.0.5/nvhpc/6odt5ecgbcadsebb5kst62zuoq5u7jna/cosmoDefinitions/definitions/:/opt/spack-install/container/eccodes/2.19.0/nvhpc/tq2o4mafzz34jhqucwgdrz2s3wzpg5kd/share/eccodes/definitions

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root
