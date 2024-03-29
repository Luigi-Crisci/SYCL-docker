source env.sh

function usage()
{
	echo "Usage: source manage_dpcpp.sh [install | uninstall]"
}

INSTALL_FILE=/usr/local/.dpcpp
if [ $# -ne 1 ] 
then
	usage
elif [ $1 = "install" ]
then
	echo "Installing dpcpp..."
	export PATH=$PATH:/usr/local/bin
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
	if ! [[ -f "$INSTALL_FILE" ]]; then
		cp -r /dpcpp/install/bin/* /usr/local/bin/
		cp -r /dpcpp/install/lib/* /usr/local/lib/
		cp -r /dpcpp/install/include/* /usr/local/include/
		touch $INSTALL_FILE #Set dpcpp as installed
	fi
	echo "Done!"
elif [ $1 = "uninstall" ]
then
	echo "Uninstalling dpcpp..."
	if [[ -f "$INSTALL_FILE" ]]; then
		rm $INSTALL_FILE
		export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda/bin:/usr/local/cuda/nvvm/bin
		export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64
		for file in $(ls /dpcpp/*.txt)
		do
			xargs rm < $file
		done
	fi
	echo "Done!"
else
	usage
fi

cd ~
