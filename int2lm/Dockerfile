# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-mpich
ENV INT2LM_SPEC="int2lm@c2sm-master%nvhpc ^cmake%gcc"

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

# install libtree
RUN git clone https://github.com/haampie/libtree.git /opt/libtree && \ 
    cd /opt/libtree && \
    make LDFLAGS=-static

RUN ln -fs /opt/libtree/libtree /usr/bin/libtree 

# install int2lm
RUN --mount=type=ssh spack install --only dependencies $INT2LM_SPEC

RUN --mount=type=ssh spack install -v --only package $INT2LM_SPEC

RUN echo $(spack find --paths int2lm | grep -o -P '/opt/spack-install/.*')/bin/int2lm > /opt/int2lm

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/int2lm /opt/int2lm
COPY --from=builder /etc/ld.so.conf.d/mpich.conf /etc/ld.so.conf.d/mpich.conf

RUN ln -s $(cat /opt/int2lm) /root/int2lm

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]

