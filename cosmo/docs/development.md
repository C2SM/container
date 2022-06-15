# Development
Important information about the development of the Dockerfiles

# Image structure
### [nvidia-spack](../nvidia-spack)
The image is taken mainly from the [official Spack Dockerfile](https://github.com/spack/spack/blob/develop/share/spack/templates/container/bootstrap-base.dockerfile).

It provides:
  * Nvidia Build Tools
  * nvhpc 21.3
  * gcc 8.4.0/9.3.0
  * c2sm-spack instance

Spack-c2sm and the underlying spack version are frozen.
```dockerfile
ENV SPACK_COMMIT=e24e71be6aec4e83b2d7a9023068cab377132bbe
ENV C2SM_SPACK_COMMIT=ccbe8bcdc6e84845f8d50ab627429b5b4494ceeb
```
We do so to ensure reproducability. Additionally *spack v17.0* could not compile *mpich* using nvhpc.
Therefore a more recent version containing fixes is taken.
On top of that, a couple of patches are applied to packages, namely:
  * Eccodes
  * Cosmo
  * Cosmo-Dycore
  * Int2lm
  
```dockerfile
# Eccodes: strip "%gcc" from CMake
COPY patches/ECCODES_CMake_remove_gcc.patch $ROOT/spack-c2sm/ECCODES_CMake_remove_gcc.patch
RUN cd $ROOT/spack-c2sm && git apply ECCODES_CMake_remove_gcc.patch
```
All installed compiler are added to the spack-instance using ```spack compiler find```.
At the very end of the Dockerfile a few common packages are preinstalled and added to the spack-instance
using ```spack external find```.

### [mpich](../mpich)
This image contains an installation of mpich to reduce build-time.
To ensure every subsequent installation with Spack uses the preinstalled mpich,
a variable is set:
```dockerfile
ENV MPICH_SPEC="mpich@3.4.3%nvhpc@21.3~argobots~cuda+fortran+hwloc+hydra+libxml2+pci+romio~slurm~two_level_namespace~verbs+wrapperrpath datatype-engine=auto device=ch4 netmod=ofi pmi=pmi ^findutils%gcc"
```

## Build
#### Docker

```bash
 # start ssh-agent (needed for private GitHub access during build)
 eval $(ssh-agent) > /dev/null
 
 # build image from Dockerfile
 docker build -t $(cat TAG) --ssh default .
 ```
## Fetch image from DockerHub

```bash
module load daint-gpu
module load EasyBuild-custom/cscs 
module load sarus
eb skopeo-1.8.0.eb -rf
module load skopeo/1.8.0
skopeo login docker.io # pass your username and password when asked

# fetch image "cosmo:cpu"
skopeo copy --insecure-policy docker://c2sm/cosmo:cpu docker-archive:cosmo_cpu.tar

# load image from tarfile
sarus load cosmo_cpu.tar c2sm/cosmo:cpu
```

## Run testsuite
```bash
# a custom branch with some testsuite modifications is needed
git clone --branch docker git@github.com:jonasjucker/cosmo.git

cosmo/test/testsuite
./data/get_data.sh

# use sbumit.docker_gpu.slurm for GPU
sbatch submit.docker_cpu.slurm
```
