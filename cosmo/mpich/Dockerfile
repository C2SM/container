# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-ubuntu20.04-spack
ENV MPICH_SPEC="mpich@3.4.3%nvhpc@21.3~argobots~cuda+fortran+hwloc+hydra+libxml2+pci+romio~slurm~two_level_namespace~verbs+wrapperrpath datatype-engine=auto device=ch4 netmod=ofi pmi=pmi ^findutils%gcc"

RUN spack install --fail-fast $MPICH_SPEC

RUN echo $(spack find --paths mpich | grep -o -P '/opt/spack-install/.*')/lib > /etc/ld.so.conf.d/mpich.conf

RUN ldconfig

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
