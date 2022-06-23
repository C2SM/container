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
skopeo copy --insecure-policy docker://c2sm/cosmo:cpu docker-archive:cosmo_cpu.tar
sarus load cosmo_cpu.tar c2sm/cosmo:cpu
```

# Run on Piz Daint
1. ```git clone --branch docker git@github.com:jonasjucker/cosmo.git```
2. Go to folder ```cosmo/test/testsuite```
3. ```./data/get_data.sh```
4. ```sbatch submit.docker_cpu.slurm```
