# Build stage with Spack pre-installed and ready to be used
FROM c2sm/spack-mpich:3.4.3 AS builder
ENV INT2LM_SPEC="int2lm@c2sm-master%nvhpc ^$MPICH_SPEC "

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
RUN --mount=type=ssh spack install --fail-fast --only dependencies $INT2LM_SPEC

# install int2lm
RUN --mount=type=ssh spack install --only package $INT2LM_SPEC

# dump path to file
RUN echo $(spack find --paths int2lm | grep -o -P '/opt/spack-install/.*')/bin > /opt/int2lm

# dump spack-env to file
RUN echo $(spack load --sh $INT2LM_SPEC) > /opt/spack-env

# bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

# copy files from original image
COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/int2lm /opt/int2lm
COPY --from=builder /opt/spack-env /opt/spack-env
COPY --from=builder /etc/ld.so.conf.d/mpich.conf /etc/ld.so.conf.d/mpich.conf

# link int2lm executable
RUN ln -s $(cat /opt/int2lm) /root/int2lm

# put spack-env into profile 
RUN echo "$(cat opt/spack-env)" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" , "-c"]
WORKDIR /root

