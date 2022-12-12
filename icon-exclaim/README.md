# ICON-EXCLAIM Containerization:  a path for Continuous Integration and portable high-performance simulations in the future

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

The git submodules:  come from various repositories, some public, some private.  In particular, URLs with the prefix '../..' are within the main ICON repository,  gitlab.dkrz.de:, and thus are all private.

- [submodule "externals/mtime"] url = ../../icon-libraries/libmtime.git
- [submodule "externals/jsbach"] url = ../../jsbach/jsbach.git
- [submodule "externals/yac"]	url = ../../dkrz-sw/YAC.git
- [submodule "externals/tixi"] url = ../../icon-libraries/libtixi.git
- [submodule "externals/yaxt"] url = ../../dkrz-sw/yaxt.git
- [submodule "externals/rte-rrtmgp"] url = https://github.com/earth-system-radiation/rte-rrtmgp.git
- [submodule "externals/cub"] url = https://github.com/NVlabs/cub.git
- [submodule "externals/omni-xmod-pool"] url = https://github.com/claw-project/omni-xmod-pool.git
- [submodule "externals/cdi"]	url = ../../mpim-sw/libcdi.git
- [submodule "externals/sct"]	url = ../../dkrz-sw/sct.git
- [submodule "externals/ecrad"]	url = ../../dwd-sw/libecrad.git
- [submodule "externals/dace_icon"]	url = ../../dwd-sw/dace-icon-interface.git
- [submodule "externals/emvorado"]url = ../../dwd-sw/emvorado-for-icon.git
- [submodule "externals/probtest"]url = ../../cscs-sw/probtest.git
- [submodule "utils/mkexp"] url = https://git.mpimet.mpg.de/public/mkexp
- [submodule "externals/art"]	url = ../../art/art.git
- [submodule "externals/ppm"]	url = ../../jahns/ppm.git

