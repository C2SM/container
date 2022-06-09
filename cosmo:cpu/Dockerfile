# syntax=docker/dockerfile:1.4.0
# Build stage with Spack pre-installed and ready to be used
FROM docker.io/c2sm/spack-mpich:3.4.3 AS builder
ENV COSMO_SPEC="cosmo@c2sm-master%nvhpc cosmo_target=cpu cuda_arch=60 ~cppdycore ^$MPICH_SPEC"

# install dummy slurm
RUN <<EOT bash
  apt-get -yqq update
  apt-get -yqq install --no-install-recommends slurm
  locale-gen en_US.UTF-8
  pip3 install boto3
  rm -rf /var/lib/apt/lists/*
EOT

COPY <<EOF /tmp/packages_append.yaml
  slurm:
      buildable: false
      externals:
      - spec: slurm%gcc
        prefix: /usr
EOF
RUN cat /tmp/packages_append.yaml >> /root/.spack/packages.yaml && rm -f /tmp/packages_append.yaml

# install COSMO dependencies
RUN --mount=type=ssh spack installcosmo --only dependencies $COSMO_SPEC

# install COSMO
RUN --mount=type=ssh spack installcosmo -v --only package $COSMO_SPEC

# dump paths to file
RUN echo $(spack find --paths cosmo | grep -o -P "/opt/spack-install/.*")/bin/cosmo_cpu > /opt/cosmo

# dump spack-env to file
RUN echo $(spack load --sh $COSMO_SPEC) > /opt/spack-env

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/cosmo /opt/cosmo
COPY --from=builder /opt/spack-env /opt/spack-env
COPY --from=builder /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf

# link COSMO executable
RUN ln -s $(cat /opt/cosmo) /root/cosmo_cpu

# put spack-env into profile 
RUN echo "$(cat opt/spack-env)" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root
