# Test Container
The results of COSMO are tested with the regular testsuite. Besides the container image, the [fork](https://github.com/jonasjucker/cosmo/tree/docker)
of Jonas Jucker is needed as repository to run the testsuite in. One needs the modified mpicmd in the testsuite as well as the testlist *testlist_gpu_noasyncio.xml*.

The modification of the mpicmd takes place in *ts_testcase.py*:

**Original Code**
```python
run_cmd=run_cmd + ' ./' + self.executable + ' ' + self.options.args + ' ' + redirect_output
```

**Modified Code**
```python
sarus_cmd=(" bash -c 'export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcuda.so; export MPICH_RDMA_ENABLED_CUDA=1;") 
self.executable=("cosmo")
run_cmd=run_cmd + sarus_cmd +  ' ' + self.executable + "'" + ' ' + self.options.args + ' ' + redirect_output

```
For the CPU version of the container the original testuite can be uses as well.

## COSMO (CPU)
Run the following commands in the directory *cosmo/test/testsuite*:
```bash
 touch cosmo_cpu && \
 ./src/testsuite.py -n 12 -v 1 --color -f --tolerance=TOLERANCE_dp \
 --testlist=testlist_mch.xml -o testsuite.out --mpicmd=' srun -u \
 --ntasks-per-node=12 -n &NTASKS -C gpu -p debug \
  sarus run --mpi --mount=type=bind,src=$PWD/../../../,target=$PWD/../../../ \
  --workdir=$PWD juckerj/cosmo:cpu'
```

```bash
/src/testsuite.py -n 12 -v 1 --color -f --tolerance=TOLERANCE_dp \
 --testlist=testlist_dwd.xml -o testsuite.out --mpicmd=' srun -u \
 --ntasks-per-node=12 -n &NTASKS -C gpu -p debug \
  sarus run --mpi --mount=type=bind,src=$PWD/../../../,target=$PWD/../../../ \
  --workdir=$PWD juckerj/cosmo:cpu'
  ```
  
## COSMO (GPU)
Run the following commands in the directory *cosmo/test/testsuite*:
```bash
export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=536870912
export MPICH_G2G_PIPELINE=256
ulimit -s unlimited
ulimit -a

 touch cosmo_gpu && \
 ./src/testsuite.py -n 2 -v 1 --nprocio=0 --color -f --tolerance=TOLERANCE_dp \
 --testlist=testlist_gpu_noasyncio.xml -o testsuite.out \
 --mpicmd='srun -u --ntasks-per-node=1 -n &NTASKS -C gpu -t5 -p debug sarus run --mpi \
 --mount=type=bind,src=$PWD/../../../,target=$PWD/../../../ \
 --workdir=$PWD juckerj/cosmo:gpu'

```
### Results Testsuite for GPU
The results for the testsuite are promising, altough many test do no fully validate.
An exemplary [testsuite.out](testsuite.out) shows, that only very few variables differ (between 4 to 9 values in total).
That there is a fundamental bug in the containerized version is rather unlikely, since all important fields like T,U,V or others are within
tolerances. More likely the error come from the newer PGI version 20.7 that is not by any user of COSMO-ORG yet.

Unfortunately the results of the testsuite are dependent on the number of nodes. Generally running on 1 node is fine, leading to the results 
shown above. The results for higher number of nodes are very shaky and not always reproducable. It could be that we see again the random crashes
of COSMO-ORG on Piz Daint!
Theo is able to run on 3 nodes, leading to identical results as for 1 node.
Why he can do that is not clear.

Experiments on full-scale (Cosmo-2e) for benchmarking showed, that configurations that crash in the testsuite can run fine with other 
settings or vice versa.

# Run container for experiments

## COSMO (CPU)
Run the following command in a sandbox containing all INPUT namelists and all input data.
The results of the simulation will be written at this location too.
```bash
srun -n $NUMBER_OF_PROC -C gpu sarus run --mpi \
--mount=type=bind,src=$PWD,target=$PWD --workdir=$PWD \
juckerj/cosmo:cpu cosmo
```

## COSMO (GPU)
Run the following command in a sandbox containing all INPUT namelists and all input data.
The results of the simulation will be written at this location too.  
*LD_PRELOAD* is set to the Cuda-Driver on the compute nodes itself, *MPICH_RDMA_CUDA* enables direct
communication between two GPU's. For detailed information about multi-GPU runs on Piz Daint, please read
the section [NVIDIA-GPUDirect](https://sarus.readthedocs.io/en/stable/cookbook/gpu/gpudirect.html?highlight=MPICH#nvidia-gpudirect-rdma)
of the official documentation.
```bash
srun -n $NUMBER_OF_PROC -C gpu sarus run --mpi \
--mount=type=bind,src=$PWD,target=$PWD --workdir=$PWD \
juckerj/cosmo:gpu bash -c 'export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libcuda.so; export MPICH_RDMA_ENABLED_CUDA=1; cosmo'
```
## Benchmark
For benchmarking the [official benchmark Jenkins-plan](http://jenkins-mch.cscs.ch/view/cosmo/job/COSMO-ORG_performance_benchmark_daily/) of MeteoSwiss used.
It consists of a **4 hour forecast with Cosmo-2e**. Due to the differnet architecture of Piz Daint the following namelist parameters had to be adapted:  
**CPU**  
nproma=-1 -> 16  
nprocx=2  -> 12  
nprocy=2  -> 8  
lasyncio=true -> false  
lprefetchio=true -> false 

**GPU**  
nprocx=2  -> 4  
nprocy=2  -> 2  
nprocio=2 -> 0  
lasyncio=true -> false  
lprefetchio=true -> false  

**The benchmarks are only meant to estimate the overhead introduced by the container!**

|  CPU        | run 1   | run 2   | run 3  | average   |
|-------------|---------|---------|--------|-----------|
|  container  |19m 18s  |20 m 29s |19m 20s |**19m 41s**|
|  native     |19m 13s  |19m 8s   |19m 6s  |**19m 9s** |

|  GPU        | run 1   | run 2   | run 3  | average   |
|-------------|---------|---------|--------|-----------|
|  container  |2m 10s   |2m 6s    |2m 10s  |**2m 8s**|
|  native     |2m 12s   |2m 9s    |2m 9s   |**2m 10s** |
