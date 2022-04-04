# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-cuda11.2-ubuntu20.04-int2lm-deps

RUN spack install -v int2lm@c2sm-master%nvhpc ^cmake%gcc

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]

