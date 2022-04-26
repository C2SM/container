# Build stage with Spack pre-installed and ready to be used
FROM c2sm/nvhpc:21.3-devel-cuda_multi-cuda11.2-ubuntu20.04-int2lm-mpich-deps

#RUN --mount=type=ssh spack install -v int2lm@c2sm-master%nvhpc ^cmake%gcc

RUN --mount=type=ssh git clone git@github.com:C2SM-RCM/int2lm.git /opt/int2lm && \ 
    cd /opt/int2lm && \
    git checkout c2sm && \
    spack dev-build int2lm@c2sm-master%nvhpc ^cmake%gcc ^mpich@3.4.3 %nvhpc ^libfabric %gcc 

RUN cd /opt/int2lm/test/testsuite/data/ && ./get_data.sh

RUN git clone https://github.com/haampie/libtree.git /opt/libtree && \ 
    cd /opt/libtree && \
    make LDFLAGS=-static

RUN ln -fs /opt/libtree/libtree /usr/bin/libtree 

ENTRYPOINT ["/bin/bash", "/opt/spack/share/spack/docker/entrypoint.bash"]
CMD ["interactive-shell"]

