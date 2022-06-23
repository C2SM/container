## Build
#### Docker

```bash
 # start ssh-agent (needed for private GitHub access during build)
 eval $(ssh-agent) > /dev/null
 
 # build image from Dockerfile
 docker build -t $(cat TAG) --ssh default .
 ```
 
 #### Buildah
 The basic commands to build an image with Sarus is:
 ```bash
# start ssh-agent
eval $(ssh-agent) > /dev/null
 buildah bud -t $(cat TAG) --ssh=default --format=docker .
 ```
 Due to the root privileges needed to build an image additional steps are required.
 Please have a look at the [example buildah script](../buildah.slurm).
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

## Run full-scale experiment
Only the executable is taken from the container. Therefore all other files like namelists or input data
are provided on the filesystem.
By using the `--mount=type=bind`option of Sarus the files are exposed to the container:

```bash
# sarus stores the image here
docker_image=/load/c2sm/cosmo:gpu

srun -u --ntasks-per-node=1 -n 8 -C gpu sarus run --mpi \                                                        
       --mount=type=bind,src=$PWD,target=$PWD \                                                                  
       --workdir=$PWD \                                                                                          
       $docker_image 'export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libcuda.so" && /root/cosmo_gpu'
```
`LD_PRELOAD` sets the correct cuda-runtime and needs to be executed before calling the binary of cosmo.

For more information have a look at the [sarus example runscript](../submit.docker.slurm).
