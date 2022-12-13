# ICON-EXCLAIM Containerization:  a path for Continuous Integration and portable high-performance ICON simulations

ICON-EXCLAIM is based on a public release of the ICOsahedral Non-hydrostatic (ICON) model for climate simulations and numerical weather prediction.  
It is being rewritten in the EXCLAIM project to use a workflow written in Python (as opposed to Fortran currently) calling components (or "granules" 
which are also written in Python whose computationally intensive kernels are formulated in a Python-subset domain specific language (DSL) called 
GridTools for Python (GT4Py).  

ICON-EXCLAIM will be deployed on the new "Alps" supercomputer at the Swiss National Supercomputing Centre.  This national flagship platform is split 
into virtual clusters.  Software portability and testing of all granules in the simulation system within a Continuous Integration (CI) framework is 
key.  To this end Containers are key:  these allow us to run the software within an environment based on a particular version of a compiler 
and a well-defined software stack.  The container can be moved to other platforms and run within a container run-time system, e.g., Docker or Sarus, 
and should produce identical (or very similar) results.  Alternatively, one can build containers based on older images of the software stack which
are no longer provided on the target platform.  This allows a model like ICON, whose results are very sensitive to the software stack and compiler 
versions, to run in a stable and predictable manner for extended periods of time, which ensures the reproducibility of scientific results over
a multi-year period.

The Alps CI system also requires that all software tested resides in a container.  Since CI for individual granules and for the ICON model as a 
whole, it is a fundamental requirement to containerize ICON.  ICON is a complex software which relies on source code from multiple repositories 
all over the global.  As such it provides a complex test case for the evolving CI system.  In the subsequent sections we discuss the layout of
the ICON software, the approach taken for its containerization, which include a number of additional repositories.

## Software ecosystem

Many software repositories are required for the ICON-EXCLAIM build and containerization.   


-	github.com/C2SM/container	:  This (public) repository, where the Dockerfiles result.  This is public.  

- github.com/C2SM/spack-c2sm : a public repository which contains a version of the Spack package manager tailored for C2SM users of both COSMO and ICON

-	github.com/C2SM/icon-exclaim :  a private repository where the ICON source resides.  This is accessed through SSH keys defined for registered users.

ICON-EXCLAIM relies on many GIT submodules (sometimes called 'externals') which reside in 

The git submodules:  come from various repositories, some public, some private.  In particular, URLs with the prefix '../..' are within the main ICON repository,  gitlab.dkrz.de:, and thus are all private.  The same SSH keys as ICON apply for these private repositories.

- [submodule "externals/mtime"] url = git@github.com:C2SM/libmtime.git
- [submodule "externals/jsbach"] url = git@github.com:C2SM/jsbach/jsbach.git
- [submodule "externals/yac"]	url = https://gitlab.dkrz.de/dkrz-sw/YAC.git
- [submodule "externals/tixi"] url = git@github.com:C2SM/icon-libraries/libtixi.git
- [submodule "externals/yaxt"] url = https://gitlab.dkrz.de/dkrz-sw/yaxt.git 
- [submodule "externals/rte-rrtmgp"] url = https://github.com/earth-system-radiation/rte-rrtmgp.git
- [submodule "externals/cub"] url = https://github.com/NVlabs/cub.git
- [submodule "externals/omni-xmod-pool"] url = https://github.com/claw-project/omni-xmod-pool.git
- [submodule "externals/cdi"]	url = https://gitlab.dkrz.de/mpim-sw/libcdi.git 
- [submodule "externals/sct"]	url =https://gitlab.dkrz.de/dkrz-sw/sct.git
- [submodule "externals/ecrad"]	url = git@github.com:C2SM/libecrad.git
- [submodule "externals/dace_icon"]	url = git@github.com:C2SM/dace-icon-interface.git
- [submodule "externals/emvorado"]url = git@github.com:C2SM/emvorado-for-icon.git
- [submodule "externals/probtest"]url = git@github.com:C2SM/probtest.git
- [submodule "utils/mkexp"] url = https://git.mpimet.mpg.de/public/mkexp
- [submodule "externals/art"]	url = git@github.com:C2SM/art/art.git
- [submodule "externals/ppm"]	url = git@github.com:C2SM/ppm.git

All the private repositories have been mirrored from their original repositories on github.com:C2SM so that any user who can access the icon-exclaim.git repository can also aceess all submodules.

A future step will be to incorporate the Docker files and the documentation into the icon-exclaim.git repository, such that it can create containers without further clones.  This is a requirement of the CSCS-CI system.

## Spack build


## Container stages

ICON has extensive package dependencies, e.g., LAPACK, BLAS, MPI, NetCDF, HDF5, eccodes libraries.  There is distinct advantage of building the dependencies in ***stages*** so that previously built containers can be 'checkpointed':  this will ensure one need not keep rebuilding 'from scratch'.  After creating as many as 5 stages during development, we settled on two (with two variants of the application container):

- icon-dependencies-mpich : this container contains all the above-mentioned ICON dependencies.  Since these rarely change, this container can usually be reused when the ICON container is built.  This container is agnostic to GPUs.  

- icon-mpich : this container depends on the previous one, and wraps the icon application (and its submodules).  We distinguish icon-mpich from a rarely used (and unsupported) icon-serial variant, which is has no communication and must be run with a single process (possibly with multi-threading).

- icon-mpich-gpu : this container also depends on icon-dependencies-mpich and builds the application container to be run on GPUs.

In other words, a runnable container would require first building icon-dependencies-mpich, and then either icon-mpich or icon-mpich-gpu.  

## Build Instructions

## 






