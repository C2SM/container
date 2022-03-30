# 
# HPC COSMO image
FROM juckerj/external_swstack:cuda10.2

ARG nproc=8
ARG ssh_prv_key
ARG ssh_pub_key

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git && \
    rm -rf /var/lib/apt/lists/*

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub

# libgrib1
RUN git clone git@github.com:C2SM-RCM/libgrib1.git /var/tmp/libgrib1 && \
    cp -r /var/tmp/libgrib1/libgrib1_cosmo /usr/local/libgrib1
RUN cd /usr/local/libgrib1/source && \
    make clean -f Makefile.kesch.pgi -j$(nproc) && \
    make -f Makefile.kesch.pgi -j$(nproc) && \
    cp /usr/local/libgrib1/source/lib* /usr/local/libgrib1/. && \
    rm -rf /var/tmp/libgrib1

# libjasper 
RUN git clone git@github.com:C2SM-RCM/libjasper.git /var/tmp/libjasper && \
    cd /var/tmp/libjasper && \
    export libjasper_install=/usr/local/libjasper/ && \
    ./install.sh && \
    rm -rf /var/tmp/libjasper

# ECCODES 2.14
RUN mkdir -p /var/tmp/tar && wget -P /var/tmp/tar https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.14.1-Source.tar.gz && \
    cd /var/tmp/tar && tar xpzf eccodes-2.14.1-Source.tar.gz && rm eccodes-2.14.1-Source.tar.gz && \
    cp -r eccodes-2.14.1-Source /var/tmp/eccodes && rm -r /var/tmp/tar && \
    cd /var/tmp/ && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/eccodes \
    -DENABLE_JPG_LIBJASPER=ON -DCMAKE_Fortran_COMPILER=pgfortran ../eccodes && \
    make -j $(nproc) && \
    ctest && \
    make install && \
    rm -rf /var/tmp/eccodes
ENV LD_LIBRARY_PATH=/usr/local/eccodes/lib:$LD_LIBRARY_PATH  

# eccodes-cosmo-resources
RUN git clone git@github.com:COSMO-ORG/eccodes-cosmo-resources.git \
    /usr/local/eccodes/eccodes-cosmo-resources && \
    cd /usr/local/eccodes/eccodes-cosmo-resources && \
    git checkout 15f3a862d0349f4fc332e383c69acbed71b7804d
    
ENV GRIB_DEFINITION_PATH=/usr/local/eccodes/eccodes-cosmo-resources/definitions:/usr/local/eccodes/share/eccodes/definitions/
ENV GRIB_SAMPLES_PATH=/usr/local/eccodes/eccodes-cosmo-resources/samples/
ENV PATH=/usr/local/eccodes/bin/:$PATH

# COSMO-ORG without dycore 
RUN git clone --branch docker git@github.com:jonasjucker/cosmo.git /usr/local/cosmo && \
    cd /usr/local/cosmo/cosmo/ACC && cp Options.docker.pgi.cpu Options && \
    export INSTALL_DIR=/usr/local/ && make -j$(nproc) && \
    ldconfig

ENV COSMO_HOME=/usr/local/cosmo
ENV PATH=$PATH:/usr/local/cosmo/cosmo/ACC

WORKDIR /data

