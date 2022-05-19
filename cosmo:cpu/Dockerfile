# Build stage with Spack pre-installed and ready to be used
FROM c2sm/spack-mpich:3.4.3 AS builder
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

# CMake spec needs to be without "%gcc"
COPY ECCODES_CMake_remove_gcc.patch /opt/spack-c2sm/ECCODES_CMake_remove_gcc.patch
RUN cd /opt/spack-c2sm && git apply ECCODES_CMake_remove_gcc.patch

# install COSMO dependencies
RUN --mount=type=ssh spack installcosmo --only dependencies $COSMO_SPEC

# install COSMO
RUN --mount=type=ssh spack installcosmo -v --only package $COSMO_SPEC

# dump paths to file
RUN echo $(spack find --paths cosmo | grep -o -P "/opt/spack-install/.*")/bin/cosmo_cpu > /opt/cosmo
RUN echo $(spack find --paths cosmo-eccodes-definitions | grep -o -P "/opt/spack-install/.*") > /opt/cosmo-eccodes-definitions
RUN echo $(spack find --paths eccodes | grep -o -P "/opt/spack-install/.*") > /opt/eccodes

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/cosmo /opt/cosmo
COPY --from=builder /opt/cosmo-eccodes-definitions /opt/cosmo-eccodes-definitions
COPY --from=builder /opt/eccodes /opt/eccodes
COPY --from=builder  /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf

# link COSMO executable
RUN ln -s $(cat /opt/cosmo) /root/cosmo_cpu

# GRIB definition paths
RUN echo "export GRIB_SAMPLES_PATH=$(cat /opt/cosmo-eccodes-definitions)/cosmoDefinitions/samples" >> /etc/profile
RUN echo "export GRIB_DEFINITION_PATH=$(cat /opt/cosmo-eccodes-definitions)/cosmoDefinitions/definitions/:$(cat /opt/eccodes)/share/eccodes/definitions" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root
