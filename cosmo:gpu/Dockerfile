# Build stage with Spack pre-installed and ready to be used
FROM c2sm/spack-mpich:3.4.3 as builder
ENV BOOST_SPEC="boost@1.67%gcc +program_options +system"
ENV DYCORE_SPEC="cosmo-dycore@c2sm-master cuda_arch=60 ^cuda%gcc ^$BOOST_SPEC"
ENV COSMO_SPEC="cosmo@c2sm-master%nvhpc cosmo_target=gpu cuda_arch=60 ^$DYCORE_SPEC  ^$MPICH_SPEC"

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
    echo "        prefix: /usr" >> /root/.spack/packages.yaml && \
    echo "  cuda:" >> /root/.spack/packages.yaml && \
    echo "      buildable: false" >> /root/.spack/packages.yaml && \
    echo "      externals:" >> /root/.spack/packages.yaml && \
    echo "      - spec: cuda@11.0.221%gcc" >> /root/.spack/packages.yaml && \
     echo "        prefix: /opt/nvidia/hpc_sdk/Linux_x86_64/21.3/cuda/11.0/" >> /root/.spack/packages.yaml && \
    echo "  cmake:" >> /root/.spack/packages.yaml && \
    echo "      buildable: false" >> /root/.spack/packages.yaml && \
    echo "      externals:" >> /root/.spack/packages.yaml && \
    echo "      - spec: cmake@3.16.3%gcc" >> /root/.spack/packages.yaml && \
     echo "        prefix: /usr " >> /root/.spack/packages.yaml

COPY CudaToolkit_Cmake.patch /opt/spack-c2sm/CudaToolkit_Cmake.patch
RUN cd /opt/spack-c2sm && git apply CudaToolkit_Cmake.patch

RUN --mount=type=ssh spack install --only dependencies $DYCORE_SPEC ^$MPICH_SPEC

RUN --mount=type=ssh spack install -v --only package $DYCORE_SPEC ^$MPICH_SPEC

#RUN --mount=type=ssh spack installcosmo --only dependencies $COSMO_SPEC
#
#RUN --mount=type=ssh spack installcosmo -v --only package $COSMO_SPEC
#
#RUN echo $(spack find --paths cosmo | grep -o -P '/opt/spack-install/.*')/bin/cosmo_cpu > /opt/cosmo
#
## Bare OS image to run the installed executables
#FROM nvcr.io/nvidia/nvhpc:21.3-runtime-cuda11.0-ubuntu20.04
#
#COPY --from=builder /opt/spack-install /opt/spack-install
#COPY --from=builder /opt/cosmo /opt/cosmo
#COPY --from=builder  /etc/ld.so.conf.d/mpich.conf  /etc/ld.so.conf.d/mpich.conf
#
#RUN ln -s $(cat /opt/cosmo) /root/cosmo_gpu
#
## paths cannot be hardcoded in the future
#ENV GRIB_SAMPLES_PATH=/opt/spack-install/container/cosmo-eccodes-definitions/2.19.0.5/nvhpc/6odt5ecgbcadsebb5kst62zuoq5u7jna/cosmoDefinitions/samples
#ENV GRIB_DEFINITION_PATH=/opt/spack-install/container/cosmo-eccodes-definitions/2.19.0.5/nvhpc/6odt5ecgbcadsebb5kst62zuoq5u7jna/cosmoDefinitions/definitions/:/opt/spack-install/container/eccodes/2.19.0/nvhpc/tq2o4mafzz34jhqucwgdrz2s3wzpg5kd/share/eccodes/definitions
#
#RUN ldconfig

#ENTRYPOINT ["/bin/bash", "--rcfile", "/etc/profile", "-l" ,"-c"]
#WORKDIR /root
ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]
