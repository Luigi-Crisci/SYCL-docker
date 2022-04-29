function usage()
{
	echo "Usage: source manage_hipsycl.sh [install | uninstall]"
}


# Get two arguments and check if they are strings
if [ $# -ne 1 ] 
then
	usage
elif [ $1 == "install" ]
then
	echo "Installing hipsycl..."
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/deps/llvm-13.0.1/lib/
	cd /hipSYCL/build && make install
	echo "Done!"
elif [ $1 == "uninstall" ]
then
	echo "Uninstalling hipsycl..."
	# Check if file "install_manifest.txt" exists
	if [ -f /hipSYCL/build/install_manifest.txt ]
	then
		export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda/bin:/usr/local/cuda/nvvm/bin
		export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64
		xargs rm < /hipSYCL/build/install_manifest.txt
		echo "Done!"
	else
		echo "hipSYCL seems not to be installed"
	fi
else
	usage
fi

cd ~