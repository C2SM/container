# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-spack AS builder
ENV INT2LM_SPEC="int2lm@c2sm-master%nvhpc ~parallel ^hdf5@1.12.2%nvhpc@21.3 ~mpi ^netcdf-c ~mpi "

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

# install int2lm dependencies
RUN --mount=type=ssh spack install --only dependencies $INT2LM_SPEC

# install int2lm
RUN --mount=type=ssh spack install -v --only package $INT2LM_SPEC

# dump paths to file
RUN echo $(spack find --paths int2lm | grep -o -P '/opt/spack-install/.*')/bin > /opt/int2lm
RUN echo $(spack find --paths cosmo-eccodes-definitions | grep -o -P "/opt/spack-install/.*") > /opt/cosmo-eccodes-definitions
RUN echo $(spack find --paths eccodes | grep -o -P "/opt/spack-install/.*") > /opt/eccodes

# bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

# copy files from original image
COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/int2lm /opt/int2lm
COPY --from=builder /opt/cosmo-eccodes-definitions /opt/cosmo-eccodes-definitions
COPY --from=builder /opt/eccodes /opt/eccodes
COPY --from=builder /etc/ld.so.conf.d/mpich.conf /etc/ld.so.conf.d/mpich.conf

# link int2lm executable
RUN ln -s $(cat /opt/int2lm) /root/int2lm

# GRIB definition paths
RUN echo "export GRIB_SAMPLES_PATH=$(cat /opt/cosmo-eccodes-definitions)/cosmoDefinitions/samples" >> /etc/profile
RUN echo "export GRIB_DEFINITION_PATH=$(cat /opt/cosmo-eccodes-definitions)/cosmoDefinitions/definitions/:$(cat /opt/eccodes)/share/eccodes/definitions" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" , "-c"]
WORKDIR /root

