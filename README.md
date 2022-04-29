# SYCL-docker

A simple self-contained container with SYCL  
Contains:
- hipSYCL (latest nightly)
  - LLVM 13.0.1 (hipSYCL deps)
- DPC++ (release 2021-12)
- CUDA 11.4

## Build
A pre built image can be found in DockerHub. To get it, type
```bash
docker pull luigicrisci/sycl_cuda11.4
```

If you want to build the image by yourself, type
```bash
docker build -t <NAME> .
```
and docker will create an image called \<NAME\>.

The image requires ~22GB, so make sure to have enough space

## Execute a container with GPU support
### Prerequisites
#### CUDA
A detailed guide on how to enable CUDA support for containers can be found [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#linux-distributions)  
- **Windows Users**:
  - Only Windows 10 Inside preview and Windows 11 are supported
  -  To run CUDA, you will need a working **WSL 2** installation. If you already have a WSL 1 installation, you can upgrade it by typing `wsl --set-version <Distro> 2`  
Any linux distribution listed in the nvidia guide should work, but Ubuntu 20.04 is preferred. Note that nvidia driver on Windows already contains the one for WSL, so **DO NOT** install the Nvidia driver on WSL as conflicts will arise. 

### Run the container
To run the container, type
```bash
docker run -it --gpus=all --name <CONTAINER_NAME> <IMAGE_NAME>
```
where 
- *-it* creates an interactive shell on the container
- *--gpus=all* add all the gpu found in the system to the container

## Select backend
hipSYCL and DPC++ have different headers files, so it is better to not enable them togheter
In the container you will find two files in your $HOME folder, `manage_dpcpp.sh` and `manage_hipsycl.sh`, which can install and uninstall the corresponding backend.  

E.g. to install hipsycl
```bash
source manage_hipsycl.sh install
```
and to uninstall it
```bash
source manage_hipsycl.sh uninstall
```
Do NOT enable both backend togheter as it could brick the container (Not tested, feel free to make a try)
