#!/bin/bash

function is_root
{
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root" 1>&2
	   exit 1
	fi
}

function backup {
	mkdir $MASS_AUTOPWN_DIR"/backup/"
	cp /boot/config.txt $MASS_AUTOPWN_DIR"backup/"
	cp /etc/modules $MASS_AUTOPWN_DIR"backup/"
}

function restore {
	cp $MASS_AUTOPWN_DIR"backup/config.txt" /boot/config.txt
	cp $MASS_AUTOPWN_DIR"backup/modules" /etc/modules

	sed -i -e 's/options g_multi file=\/dev\/mmcblk0p1 stall=0//g' /etc/modules.d/usbgadget.config

	if [ "$(wc -l /etc/modules.d/usbgadget.config)" == 0 ]; then
		rm /etc/modules.d/usbgadget.config
	fi	
}

function init {
	echo "dtoverlay=dwc2" | tee -a /boot/config.txt
	echo "dwc2" | tee -a /etc/modules

# Allows you to configure 2 from Ethernet, Mass storage and Serial
# In addition to the above modules, a few other (less useful) modules are included.
# You can only pick one of the above modules to use at a time
	echo $MODULE | tee -a /etc/modules

	echo "options g_multi file=/dev/mmcblk0p1 stall=0" | tee -a /etc/modules.d/usbgadget.config


	echo $MASS_AUTOPWN_DIR"launcher.sh" | tee -a /etc/rc.local
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

function main {
	is_root
	get_opt $*
	if [ $RESTORE ]; then
		restore
		echo "Restore finish"
	else
		load_config
		#backup
		#init
	fi
}

main $*