## nvidia-spack
Base image with all nvidia build tools and the c2sm-spack instance with nvhpc 21.3 and gcc 8.4.0/9.3.0

## mpich
Image on top of [nvidia-spack](nvidia-spack) providing mpich suitable for cosmo and int2lm

## cosmo:cpu
Image on top of [mpich](mpich) providing an executable for COSMO on CPU (Validated on Piz Daint)

## cosmo:gpu
Image on top of [mpich](mpich) providing an executable for COSMO on GPU (Validated on Piz Daint)

## int2lm
Image on top of [mpich](mpich) providing an executable for INT2LM (Validated on Piz Daint)
