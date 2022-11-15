# syntax=docker/dockerfile:1.2
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-spack_0.18
ENV SPACK_PREFIX=/root/c2sm-spack
ENV SPACK_SYSTEM_CONFIG_PATH=/root/c2sm-spack/sysconfigs/unknown
ENV SPACK_ROOT=/root/c2sm-spack/spack

RUN --mount=type=ssh spack install --fail-fast --only dependencies icon@2.6.4%nvhpc ~mpi ^hdf5@1.12.2%gcc@9.3.0 ~mpi
RUN --mount=type=ssh spack install icon@2.6.4%nvhpc ~mpi ^hdf5@1.12.2%gcc@9.3.0 ~mpi

WORKDIR /root
SHELL ["docker-shell"]

ENTRYPOINT ["/bin/bash", "/root/c2sm-spack/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
