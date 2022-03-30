# Image Structure
The images/containers for COSMO-ORG are built in two steps, adding three images on top of each other.
The first two images are shared by both CPU and GPU versions. The final images are separated, because for GPU one needs
the Gridtools-library. The final images, containing some very COSMO-specific packages and COSMO itself, require access to some private GitHub repositories.

### Base Image (shared)
As a base image we use an official CUDA image from NVIDIA.
On Piz Daint the newest version supported is 10.2.
Therefore we use **nvidia/cuda:10.2-devel-ubuntu18.04**

### External Software Stack (shared)
On top of the CUDA image we install a whole bunch of libraries from source in order to compile COSMO-ORG on both CPU and GPU.  
   * PGI 20.7 
   * MPICH 3.1.4  
   * HDF5 1.10.1  
   * NetCDF 4.6.1
   * NetCDF C++ 4.3.0
   * NetCDF Fortran 4.4.4  
   * Perl 5.16.3  
   * Automake 1.13
   
##### PGI 20.7 
PGI 20.7 is installed with the HPC-development-toolkit from NVIDIA. We do so, because this is the only option the get a free version
of the PGI. By passing *NVHPC_DEFAULT_CUDA=10.2* to the install-script, we ensure that the same CUDA-version from the base image is installed. So the container then has two seperate CUDA instances installed, which one is used to compile COSMO-ORG in the end is not clear. The community version of PGI is valid for around a year, the package needs to be dowloaded from the NVIDIA webpage. A change in the distribution-policy of NVIDIA could well make this key-component of the images **unavailable**.

##### MPICH 3.1.4
The default MPI-library of COSMO-ORG is OpenMPI. Sarus does not support the native-MPI hook with OpenMPI, therefore we use MPICH.
More detailed descriptions about the MPI-hook of Sarus can be found in the [official documentation](https://sarus.readthedocs.io/en/stable/config/mpi-hook.html).
It is very important, that the MPI-library is installed at a **standard location** inside the containers, if not, Sarus cannot find it and the MPI-hook does not work.  
In our containers, the MPI-library is install at */usr*. It is alo required to run *ldconfig* after installation of the MPI-library in order to use the native-MPI hook.

##### OpenMPI (instead of MPICH)
In case one wants to use the OpenMPI-library instead, it needs to be configured with *libpmi2*. By passing these options  
to the configure-script OpenMPI is configured correctly: 
* --with-pmi=/usr 
* --with-pmi-libdir=/usr/lib/x86_64-linux-gnu  
* CFLAGS=-I/usr/include/slurm  


More information about how to launch an OpenMPI-application with Sarus can be found in the section [Running MPI applications without the native MPI hook](https://sarus.readthedocs.io/en/stable/user/user_guide.html#running-mpi-applications-without-the-native-mpi-hook) of the official documentation.
Note that this only works for CPU, multinode GPU-support of Sarus needs the MPICH-library for all cases.

### COSMO (CPU)
This image contains all COSMO-specific packages, most of them are private.
* Libgrib1
* Libjasper
* Eccodes 2.14.1
* Eccodes-cosmo-resources
* COSMO-ORG

##### COSMO-ORG
The COSMO-ORG used in this container is a [fork](https://github.com/jonasjucker/cosmo/tree/docker) of Jonas Jucker. Branch *docker* is the one to use.
No modifications took place in the code itself, rather some adjustements in the Options-files used to build as well as in the testsuite to launch the container using Sarus smoothly took place. The results of simulation do not differ from the original repository of COSMO-ORG.  
As for the MPI-libraries, after succesful compilation of COSMO-ORG *ldconfig* is run in order to ensure correct function of the native-MPI hook of Sarus.
The resulting binary **cosmo** is added to PATH.

**The executable suited for CPU is compiled without the Gridtools-Dycore**

### COSMO (GPU)
This images contains all COSMO-specific packages, most of them are private.
* Libgrib1
* Libjasper
* Eccodes 2.14.1
* Eccodes-cosmo-resources
* Boost 1.67.0
* Gridtools
* Serialbox
* COSMO-ORG

##### Boost
The installation of the Boost-libraries was tricky and caused some problems, that only could be solved with a little hack:
Cmake, as used by Gridtools does not properly recognize the libraries located at */usr/local/boost* inside the container, although the
path is passed via  
* -DBOOST_ROOT=/usr/local/boost  
to Cmake. A workaround by installing Boost via *apt-get install* does work for Cmake. For some reason a couple of MPI-header files are installed too.
These files then are used for an unknown reason inside the Dycore, but not compatible with the ABI-number of the MPI-library of Piz Daint. The native-MPI hook of Sarus can only be used across ABI-compliant MPI-libraries.

The final solution to this problem is, to install a small portion of the Boost-libraries via *apt-get install*, namely **libboost-serialization1.65-dev** as a dummy to satisfy Cmake of Gridtools.
The actual Boost-libraries used in the Dycore are those located at */usr/local/boost*.

##### COSMO-ORG
The COSMO-ORG used in this container is a [fork](https://github.com/jonasjucker/cosmo/tree/docker) of Jonas Jucker. Branch *docker* is the one to use.
No modifications took place in the code itself, rather some adjustements in the Options-files used to build as well as in the testsuite to launch the container using Sarus smoothly took place. The results of simulation do not differ from the original repository of COSMO-ORG.  
As for the MPI-libraries, after succesful compilation of COSMO-ORG *ldconfig* is run in order to ensure correct function of the native-MPI hook of Sarus.
The resulting binary **cosmo** is added to PATH.

**The executable suited for GPU is compiled with the Gridtools-Dycore**
