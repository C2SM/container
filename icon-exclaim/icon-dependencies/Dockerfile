# syntax=docker/dockerfile:1.2
FROM c2sm/spack-mpich:3.4.3
ENV SPACK_PREFIX=/root/c2sm-spack
ENV SPACK_SYSTEM_CONFIG_PATH=/root/c2sm-spack/sysconfigs/unknown
ENV SPACK_ROOT=/root/c2sm-spack/spack

# Moved from nvidia-spack/Dockerfile
RUN --mount=type=ssh spack install --only dependencies --fail-fast icon@exclaim-master%nvhpc +mpi ^netlib-lapack ~external-blas

WORKDIR /root
SHELL ["docker-shell"]

ENTRYPOINT ["/bin/bash", "/root/c2sm-spack/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
