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
skopeo copy --insecure-policy docker://c2sm/cosmo:int2lm docker-archive:int2lm.tar
sarus load int2lm.tar c2sm/cosmo:int2lm
```

# Run on Piz Daint
1. ```git clone --branch docker git@github.com:mjaehn/int2lm.git```
2. Go to folder ```int2lm/test/testsuite```
3. ```./data/get_data.sh```
4. ```sbatch submit.docker.slurm```
