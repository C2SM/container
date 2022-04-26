# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-spack-develop

RUN --mount=type=ssh spack install --fail-fast --only dependencies int2lm@c2sm-master%nvhpc ^cmake%gcc ^mpich@3.4.3 %nvhpc ^libfabric %gcc 

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]

