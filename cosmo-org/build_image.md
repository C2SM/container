# Build Image
The images are built from Dockerfiles using [Docker](https://www.docker.com/) on a MacBook. There are other options to build
images on HPC-sytems directly like [Buildah](https://user.cscs.ch/tools/containers/buildah/) on Piz Daint.
For now, the potential of Buildah is not investigated, but for a Continous INtegration Framework like Jenkins, this could be a valuable option.

To build the images below, a significant amount of memory is needed, therefore ensure to allow Docker to allocate enough memory.
On the MacBook Docker uses **4 CPU's** and up to **14 GB of memory** during the build-process

## Build Images from Dockerfile

### External Software Stack
To build the image, execute the following commands in your Terminal:

```bash
cd container-C2SM/external_swstack
docker build -t $(cat TAG) .
```

### Cosmo (CPU and GPU)
To access the private GitHub repositories, the ssh-keys are used to clone them directly inside the container. Therefore make sure your keys are correctly passed 
as build-arguments to *docker build* as shown below.
 ```bash
 cd container-C2SM/cosmo_cpu # or cosmo_gpu for the GPU-version
 docker build -t $(cat TAG) . --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"
 ```

## Pull Images from Dockerhub

### External Software Stack
This image is public, pull it by executing the following command:
```bash
 docker pull juckerj/external_swstack:cuda10.2 # replace docker with sarus on Piz Daint
 ```
 
 ### Cosmo (CPU and GPU)
 These images are private. Contact me in case you want to be added as a collaborator.
 To download execute the following command:
 ```bash
 sarus pull --login juckerj/cosmo:cpu # or gpu
 ```
