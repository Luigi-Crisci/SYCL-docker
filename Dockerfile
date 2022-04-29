FROM ubuntu:20.04

RUN apt-get -u update \
	&& apt-get -qq upgrade \
	# Setup Kitware repo for the latest cmake available:
	&& apt-get -qq install \
	apt-transport-https ca-certificates gnupg software-properties-common wget \
	&& wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
	| gpg --dearmor - \
	| tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
	&& apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
	&& apt-get -u update \
	&& apt-get -qq upgrade \
	&& apt-get -qq install cmake \
	ca-certificates \
	build-essential \
	gcc-8 \
	g++-8 \
	python \
	ninja-build \
	ccache \
	xz-utils \
	curl \
	git \
	bzip2 \
	lzma \
	xz-utils \
	apt-utils \
	vim

# Install gcc-9/10 and g++-9/10
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
	&& apt update \
	&& apt install -y gcc-9 g++-9

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
	&&  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9

# Install llvm 13 with all dependencies
ADD install_llvm.sh /
RUN chmod +x install_llvm.sh \
	&& ./install_llvm.sh \
	&& rm -rf install_llvm.sh /root/git 

#Install boost dependecies
RUN apt -u update \
	&& apt install -y autotools-dev libicu-dev libbz2-dev libcurl4-openssl-dev libexpat-dev libgmp-dev libmpfr-dev libssl-dev libxml2-dev libz-dev \
	zlib1g-dev libopenmpi-dev \
	libicu-dev \
	python-dev

# Install boost
RUN echo "Installing Boost..." \
	&& wget -q https://boostorg.jfrog.io/artifactory/main/release/1.68.0/source/boost_1_68_0.tar.gz  \
	&& tar -xf boost_1_68_0.tar.gz \
	&& cd boost_1_68_0 \
	&& ./bootstrap.sh --with-libraries=all \
	&& ./b2 -j 8 -q install \ 
	&& cd .. && rm -rf boost_1_68_0.tar.gz boost_1_68_0

# Install Cuda-11.4
RUN echo "Installing Cuda..." \
	&& wget -q https://developer.download.nvidia.com/compute/cuda/11.4.0/local_installers/cuda_11.4.0_470.42.01_linux.run \
	&& chmod +x cuda_11.4.0_470.42.01_linux.run \
	&& ./cuda_11.4.0_470.42.01_linux.run --toolkit --silent --toolkitpath=/usr/local/cuda-11.4 \
	&& rm -rf cuda_11.4.0_470.42.01_linux.run

RUN apt install -y gcc-11 g++-11 \
	&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11 \
	&&  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11 \
	&& update-alternatives --auto gcc \
	&& update-alternatives --auto g++

# Install hipSYCL
RUN echo "Building hipSYCL..." \
	&& git clone https://github.com/illuhad/hipSYCL \
	&& cd hipSYCL \
	&& git checkout \
	&& mkdir build \
	&& cd build \
	&& cmake .. -DCMAKE_BUILD_TYPE=Release -DLLVM_DIR=/root/deps/llvm-13.0.1/lib/cmake/llvm/ \
	-DCLANG_EXECUTABLE_PATH=/root/deps/llvm-13.0.1/bin/clang++ \
	-DCLANG_INCLUDE_PATH=/root/deps/llvm-13.0.1/lib/clang/13.0.1/include/  \
	&& make -j $(grep -c ^processor /proc/cpuinfo) all 

RUN echo "Building DPCPP..." \
	&& wget -q https://github.com/intel/llvm/archive/refs/tags/2021-12.tar.gz \
	&& tar -xzf 2021-12.tar.gz \
	&& cd llvm-2021-12 \
	&& cd buildbot \
	&& python3 configure.py --cuda -t release --cmake-opt='-DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs' \
	&& python3 compile.py -j $(nproc) \
	&& mkdir dpcpp \
	&& mv llvm-2021-12/build/install llvm-2021-12/build/install_manifest* dpcpp \
	&& rm -rf 2021-12.tar.gz llvm-2021-12
# Fix install files
COPY sed_dpcpp.sh /dpcpp/	
RUN  cd dpcpp && chmod +x sed_dpcpp.sh && ./sed_dpcpp.sh && rm sed_dpcpp.sh

ADD manage_hipsycl.sh /root/
ADD manage_dpcpp.sh /root/

ENV PATH=/usr/local/cuda/bin:/usr/local/cuda/nvvm/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64:$LD_LIBRARY_PATH