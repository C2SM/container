# Build
```bash
 docker build -t $(cat TAG) --ssh default .
 ```
# Fetch image from DockerHub

```
module load daint-gpu
module load EasyBuild-custom/cscs 
module load sarus
eb skopeo-1.8.0.eb -rf
module load skopeo/1.8.0
skopeo login docker.io # pass your username and password when asked
skopeo copy --insecure-policy docker://c2sm/cosmo:gpu docker-archive:cosmo_gpu.tar
sarus load cosmo_gpu.tar c2sm/cosmo:gpu
```

# Run on Piz Daint
1. ```git clone --branch docker git@github.com:jonasjucker/cosmo.git```
2. Go to folder ```cosmo/test/testsuite```
3. ```./data/get_data.sh```
4. ```sbatch submit.docker_gpu.slurm```

# Performance
A comparison of performances between a native build and the container can be seen on the Jenkins-plan
[container_benchmark](https://jenkins-mch.cscs.ch/job/container_benchmark/)
