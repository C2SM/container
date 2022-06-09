#!/bin/bash -l
#SBATCH --constraint=gpu
#SBATCH --job-name="container"
#SBATCH --nodes=1
#SBATCH --output=container.out
#SBATCH --time=01:00:00
#SBATCH --account=g110

module load daint-gpu
module load Buildah/1.26.1

target=cpu
archive_local_dir="/dev/shm/${USER}"
archive_name="cosmo_${target}_3.4.3.tar"

# start ssh-agent and add github identity
eval $(ssh-agent) > /dev/null
ssh-add ~/.ssh/id_ed25519_github

# build container image
cd cosmo:${target}
tag=$(cat TAG)
buildah bud -t ${tag} --ssh=default --format=docker .
cd -

# Archive to locally mounted ext4 partition
buildah push ${tag} docker-archive:${archive_local_dir}/${archive_name}

# Transfer to persisting location
rsync -av ${archive_local_dir}/${archive_name} .
