# syntax=docker/dockerfile:1.2
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-icon-mpich-dependencies
ENV SPACK_PREFIX=/root/c2sm-spack
ENV SPACK_SYSTEM_CONFIG_PATH=/root/c2sm-spack/sysconfigs/unknown
ENV SPACK_ROOT=/root/c2sm-spack/spack

RUN --mount=type=ssh spack install --fail-fast icon@exclaim-master%nvhpc +mpi ^netlib-lapack ~external-blas

# dump paths to file
RUN echo $(spack find --paths icon | grep -o -P "/root/c2sm-spack/spack/opt/.*")/bin/icon > /opt/icon

# dump spack-env to file
RUN echo $(spack load --sh icon) > /opt/spack-env

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-install /opt/spack-install
COPY --from=builder /opt/cosmo /opt/cosmo
COPY --from=builder /opt/spack-env /opt/spack-env
COPY --from=builder  /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf

RUN ln -s $(cat /opt/cosmo) /root/cosmo_gpu

# put spack-env into profile 
RUN echo "$(cat opt/spack-env)" >> /etc/profile

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
WORKDIR /root


WORKDIR /root
SHELL ["docker-shell"]

ENTRYPOINT ["/bin/bash", "/root/c2sm-spack/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
