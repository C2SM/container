# syntax=docker/dockerfile:1.2
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-icon-mpich-dependencies as builder
ENV ICON_SPEC="icon@container_build%nvhpc +mpi ^netlib-lapack ~external-blas"

RUN --mount=type=ssh \
    . ${SPACK_PREFIX}/spack/share/spack/setup-env.sh && \
    cd /opt/spack-environment && \
    spack env activate . && \
    spack add ${ICON_SPEC} && \
    spack concretize --force && \
    spack install --fail-fast && \
    spack gc -y

# Strip all the binaries
RUN find -L /opt/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip -s

# Modifications to the environment that are necessary to run
RUN . ${SPACK_PREFIX}/spack/share/spack/setup-env.sh && \
    cd /opt/spack-environment && \
    spack env activate --sh -d . >> /etc/profile.d/z10_spack_environment.sh && \
    spack env activate . && \
    echo $(spack find --format='{prefix.lib}' mpich) > /etc/ld.so.conf.d/mpich.conf

# Bare OS image to run the installed executables
FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04

COPY --from=builder /opt/spack-environment /opt/spack-environment
COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/view /opt/view
COPY --from=builder /etc/profile.d/z10_spack_environment.sh /etc/profile.d/z10_spack_environment.sh
COPY --from=builder /etc/ld.so.conf.d/mpich.conf /etc/ld.so.conf.d/mpich.conf

RUN ldconfig

ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l", "-c"]
