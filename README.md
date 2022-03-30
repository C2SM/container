# Container for COSMO-ORG 
This repository summarizes the experiences and difficulties to build and run a container for COSMO-ORG on both, CPU and GPU.
The target machine for that container is Piz Daint at CSCS.

This repository is the result of around 4 weeks of full-time work by Jonas Jucker.
The majority of the time was spent to figure out things for the GPU-version of COSMO.
Many thanks also to the amazing support from Theofilos-Ioannis Manitaras!

## General
The main idea to put an application into a container is to be indepenent from the system the application runs on.
So far this was only suited for non-compute intensive applications. The performance on HPC-systems was not good compared to applications running on the native system,
because critical libraries as MPI are usually tailored to a specific HPC-machine. The application inside the container uses by definition a general MPI-library, so performance is not optimal
on HPC-systems.

To tackle that deficiency, CSCS developed Sarus, a tool to run containers efficiently on HPC-systems. The main idea of Sarus is to replace performance critical
libraries as MPI during runtime with native implementations from the system. The same kind of replacement, but for GPU-related libraries is necessary to run applications
on multiple GPU's.
Because Piz Daint is the main target machine for the containers described in this document, they contain some tweaks or twist needed for Sarus. On another HPC-system some additional components may be required inside the container.

## Reproducability of Results
Exact predictions about the stability of the result from the containerized version of COSMO-ORG with respect to further upgrades of Piz Daint are not possible. 
I discussed this subject with Theofilos-Ioannis Manitaras. His answer was:

*"Regarding your question, having a container independent of the cray programming makes you less prone to problems due to upgrades. In any case, you still rely on the host's mpi and gpu driver to get the best performance. Since your mpich inside the container is among the abi compatible mpi libraries with the host mpi I don't expect any particular problems. You should always be aware though that the portability of containers does not ensure portability of performance."*

Given that answer a containerized version of COSMO-ORG is a valuable option to keep in mind for the future.
## Organization
This repository consist of three different directories, containing Dockerfiles and a TAG-file to build the images:
* [External Software Stack](external_swstack)
* [COSMO for CPU](cosmo_cpu) (no CPP-dyocre)
* [COSMO for GPU](cosmo_gpu) (with CPP-dycore)

Additionaly it contains detailed description of key-aspects or major difficulties
faced during the process of building an running the containers on Piz Daint at CSCS.
This information is contained in the following files:

* [Image Structure](image_structure.md)
   - Description of the underlying structure of the images
   - Explanations and detailed descriptions why certain options were choosen in the Dockerfiles
   - Possible limitations for the future
   - Tweaks necessary to use Sarus on Piz Daint
   
* [Build Images with Docker](build_image.md)
   - How to build the images localy on your computer

* [Test and Run COSMO within the container](test_and_run_container.md)
   - How to run the testuite 
   - How to run simulations within the container
   - Benchmark for native and containerized COSMO-ORG on Piz Daint
