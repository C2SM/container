# Container Images:
1.  roms:  Standalone forced roms
2.  roms_oc:  roms container for oasis-coupled ROMSOC
3.  cosmo_r:  cosmo container for oasis-coupled ROMSOC
4.  romsoc_cpu:  container containing both roms and cosmo (CPU) parts of ROMSOC

# Build
```bash
#  using docker
docker build -t $(cat TAG) --ssh default .
# using buildah (writing build log to file)
buildah bud --logfile buildah.log -t $(cat TAG) --ssh=default --format=docker .
 ```
# Fetch image from DockerHub

```
module load daint-gpu
module load EasyBuild-custom/cscs 
module load sarus
eb skopeo-1.8.0.eb -rf
module load skopeo/1.8.0
skopeo login docker.io # pass your username and password when asked
# needs adjustment: skopeo copy --insecure-policy docker://c2sm/cosmo:cpu docker-archive:cosmo_cpu.tar
# needs adjustment: sarus load cosmo_cpu.tar c2sm/cosmo:cpu
```

# Run on Piz Daint (needs adjustments)
1. ```git clone --branch docker git@github.com:jonasjucker/cosmo.git```
2. Go to folder ```cosmo/test/testsuite```
3. ```./data/get_data.sh```
4. ```sbatch submit.docker_cpu.slurm```
