source env.sh

function usage()
{
	echo "Usage: source manage_hipsycl.sh [install | uninstall]"
}

INSTALL_FILE=/usr/local/.hipsycl
# Get two arguments and check if they are strings
if [ $# -ne 1 ] 
then
	usage
elif [ $1 == "install" ]
then
	echo "Installing hipsycl..."
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/deps/llvm-$llvm_version/lib/
	if ! [[ -f "$INSTALL_FILE" ]]; then
		touch $INSTALL_FILE
		cd /hipSYCL/build && make install
	fi
	echo "Done!"
elif [ $1 == "uninstall" ]
then
	echo "Uninstalling hipsycl..."
	# Check if file "install_manifest.txt" exists
	if [[ -f  "$INSTALL_FILE" ]]
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
