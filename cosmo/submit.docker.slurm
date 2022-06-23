#!/bin/bash -l
#SBATCH	--constraint=gpu
#SBATCH	--job-name="testsuite"
#SBATCH	--nodes=8
#SBATCH	--account=g110
#SBATCH	--time=00:05:00
#SBATCH	--gres=gpu:1
#SBATCH	-p normal
#SBATCH --output=slurm.log
echo "====================================================="
echo " JOB OUTPUT BEGINS "
echo "====================================================="

module load daint-gpu
module load craype-accel-nvidia60
module load sarus

echo "====================================================="
echo " GPU TESTS "
echo "====================================================="
export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=536870912
export OMP_NUM_THREADS=1

# Set this to avoid segmentation faults
ulimit -s unlimited
ulimit -a

export MV2_ENABLE_AFFINITY=0
export MV2_USE_CUDA=1
export MPICH_RDMA_ENABLED_CUDA=1
export MPICH_G2G_PIPELINE=256
export CRAY_TCMALLOC_MEMFS_FORCE=1
export MPICH_ENV_DISPLAY=1
export MPICH_VERSION_DISPLAY=1

docker_image=load/c2sm/cosmo:gpu

mkdir -p output

echo "====================================================="
echo "============== JOB OUTPUT BEGINS ===================="
echo "====================================================="

echo '********** Start Run ********* '
echo "Start time: `date +%s` s"
srun -u --ntasks-per-node=1 -n 8 -C gpu sarus run --mpi \
       --mount=type=bind,src=$PWD,target=$PWD \
       --workdir=$PWD \
       $docker_image 'export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libcuda.so" && /root/cosmo_gpu' >& run.out
echo "End time: `date +%s` s"
echo '********** End Run ********* '

echo "====================================================="
echo "============== JOB OUTPUT ENDS ===================="
echo "====================================================="
