# Build stage with Spack pre-installed and ready to be used
FROM docker.io/c2sm/spack-mpich:3.4.3 AS builder
# Use COSMO features branch with the OASIS coupler
#4cosmo ENV COSMO_SPEC="cosmo@c2sm-features%nvhpc cosmo_target=cpu cuda_arch=60 +oasis ~cppdycore ^$MPICH_SPEC"
ENV ROMS_SPEC="roms-ethz@master%nvhpc +oasis ^$MPICH_SPEC"

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

# copy UP Spack repo (Fix of OASIS also needad for cosmo+oasis)
COPY up-spack-repo/ /up-spack-repo/
# add it to spack
RUN spack repo add /up-spack-repo

# install COSMO dependencies
#4cosmo RUN --mount=type=ssh spack installcosmo --only dependencies $COSMO_SPEC


# install COSMO
#4cosmo RUN --mount=type=ssh spack installcosmo -v --only package $COSMO_SPEC

# install ROMS dependencies
#RUN --mount=type=ssh spack install --only dependencies $ROMS_SPEC
# install
#RUN --mount=type=ssh spack install -v --only package $ROMS_SPEC
RUN spack install -v $ROMS_SPEC



# dump paths to file
#4cosmo RUN echo $(spack find --paths cosmo | grep -o -P "/opt/spack-install/.*")/bin/cosmo_cpu > /opt/cosmo
RUN echo $(spack find --paths roms-ethz | grep -o -P "/opt/spack-install/.*")/bin/roms > /opt/roms

# dump spack-env to file
#4cosmo RUN echo $(spack load --sh $COSMO_SPEC) > /opt/spack-env
RUN echo $(spack load --sh $ROMS-SPEC) >> /opt/spack-env

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
#4cosmo COPY --from=builder /opt/cosmo /opt/cosmo
COPY --from=builder /opt/roms /opt/roms
COPY --from=builder /opt/spack-env /opt/spack-env
COPY --from=builder  /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf

# link COSMO executable
#4cosmo RUN ln -s $(cat /opt/cosmo) /root/cosmo_cpu
RUN ln -s $(cat /opt/roms) /root/roms

# put spack-env into profile 
RUN echo "$(cat opt/spack-env)" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root
