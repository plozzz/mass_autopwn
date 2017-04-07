#!/bin/bash

function usage {
	echo "Usage: $0 [-c <config_file>] [-b]"
	echo -e "\t-c load a specific config file"
	echo -e "\t-b restore initial device configuration"
}

function get_opt {
	while getopts ":bc:" opt; do
		case $opt in
    		c)
      			if [ -e $OPTARG ]; then
      				CONFIF_FILE=$OPTARG
      			else
      				echo "Config file not found"
      			fi
      			;;
      		b)
				RESTORE=true
				;;
    		\?)
      			echo "Invalid option: -$OPTARG" >&2
      			usage
      			;;
      	    :)
      			echo "Option -$OPTARG requires an argument." >&2
      			usage
      			exit 1
      		;;
  		esac
	done
}

function is_root {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root" 1>&2
	   exit 1
	fi
}


function install_dep {
	apt update
	apt -y upgrade
	apt -y install vim git
}

function backup {
	mkdir -p $MASS_AUTOPWN_DIR"/backup/"
	cp /boot/config.txt $MASS_AUTOPWN_DIR"backup/"
	cp /etc/modules $MASS_AUTOPWN_DIR"backup/"
	cp /etc/rc.local $MASS_AUTOPWN_DIR"backup/"
}

function restore {
	cp $MASS_AUTOPWN_DIR"backup/config.txt" /boot/config.txt
	cp $MASS_AUTOPWN_DIR"backup/modules" /etc/modules
	rm -f /etc/network/interfaces.d/massautopwn
}

function init_modules {
	echo "dtoverlay=dwc2" | tee -a /boot/config.txt
	echo "dwc2" | tee -a /etc/modules
	echo "g_multi" | sudo tee -a /etc/modules
	echo "libcomposite" | sudo tee -a /etc/modules
}

function init_network {
	cp $MASS_AUTOPWN_DIR"interfaces" /etc/network/interfaces.d/massautopwn
}

function init {
	init_modules
	init_network

	if [ $AUTORUN ]; else
		echo $MASS_AUTOPWN_DIR"launcher.sh" | tee -a /etc/rc.local
	fi
}

function load_config {
	if [ $CONFIF_FILE ]; then
		echo "Load "$CONFIF_FILE" config file"
		source $CONFIF_FILE
	else
		PATH=$(dirname $0)
		if [ -e $PATH"/config" ]; then
			echo "Load "$PATH"/config default config file"
			source $PATH"/config"
		else
			echo "No default file found"
		fi
	fi
}

function main {
	is_root
	get_opt $*
	if [ $RESTORE ]; then
		restore
		echo "Restore finish"
	else
		if [ $INSTALL_DEP ]; then
			install_dep
		fi
		load_config
		#backup
		#init
	fi
}

main $*