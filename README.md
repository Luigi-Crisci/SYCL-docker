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
  - Install Docker Desktop on windows and **DO NOT** install docker on the WSL explicitly.
  - Turn on the Docker WSL2 backend in docker desktop under *settings* -> *general* -> *use the WSL2 based engine*. If your selected distro is also the default one, no other steps are needed. In the other case, you will have to enable the WSL integration under *settings* -> *Resources* -> *WSL integration*

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

## Building a SYCL app

### Knowing your GPU capability
Each Nvidia GPU comes with a specific CUDA capabilities, which you need to specify when building a SYCL app using the CUDA backend.  
While you can easly check the CUDA capabilities for your device by checking your architecture online, [here](https://gist.github.com/Luigi-Crisci/08b8f76355476a68d34737611984bf5c) you can find simple app that queries it for you.

### HipSYCL

HipSYCL uses an environment variable `HIPSYCL_TARGETS=BACKEND:CAPABILITEIS` to select the device to build agains.  
For example, to build an app for a Nvidia RTX 2070, with cuda capabilities 7.5
```bash
HIPSYCL_TARGETS=cuda:sm_75
```
Other backend are: `omp` for cpu code and `hip:ARCH` for amd gpu.  

To compile an app, just use the hipSYCL compiler `syclcc`.   

More info can be found [here](https://github.com/illuhad/hipSYCL).

### DPC++

To build an app using DPC++, you will have to use the clang compiler and select the appropriate triple.
For example, to build a SYCL app for a Nvidia RTX 2070, with cuda capabilities 7.5
```bash
clang++ -fsycl -fsycl-targets=nvptx64-nvidia-cuda -Xsycl-target-backend --offload_arch=sm_75 <FILENAME>
```
where
- *-fsycl* enables the SYCL implementation
- *fsycl-targets=TRIPLE* specifies the target hardware.  

More info can be found [here](https://intel.github.io/llvm-docs/GetStartedGuide.html#run-simple-dpc-application).

### Cmake integration
Both DPC++ and hipSYCL can be used with CMake build system. A sample app that shows how to integrate them can be found [here](https://github.com/Luigi-Crisci/SYCL-cmake-sample-app)
