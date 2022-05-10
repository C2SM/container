## cosmo-org
Proof-of-concept of a container for COSMO-ORG. All software is built manually.
Versions for CPU and GPU builds.

## nvidia-spack
Base image with all nvidia build tools and the c2sm-spack instance with nvhpc 21.3 and gcc 8.4.0/9.3.0

## mpich
Image on top of [nvidia-spack](nvidia-spack) providing mpich suitable for cosmo and int2lm

## cosmo:cpu
Image on top of [mpich](mpich) providing an executable for COSMO on CPU (Validated on Piz Daint)
