## Build
#### Docker

```bash
 # start ssh-agent (needed for private GitHub access during build)
 eval $(ssh-agent) > /dev/null
 
 # build image from Dockerfile
 docker build -t $(cat TAG) --ssh default .
 ```
 
 #### Buildah
 add description here
 
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

# Run full-scale experiment
