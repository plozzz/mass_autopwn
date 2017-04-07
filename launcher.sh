#!/bin/bash

function is_connected {
	for INTERFACE in $(ls /sys/class/net/ | grep -v lo); do
  		echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
    		echo $INTERFACE" is online"
  			ONLINE=1; 
		fi
	done

	if ! [ $ONLINE ]; then
		echo "Not Online"
		exit 1
	fi

	exit 0
}


function create_usb {
	cd /sys/kernel/config/usb_gadget/
	mkdir -p massautopwn
	cd massautopwn
	
	OS=`cat /home/pi/os.txt`
	HOST="48:6f:73:74:50:43" # HOST PC
	SELF0="42:61:64:55:53:42" # BAD USB 1
	SELF1="42:61:64:55:53:43" # BAD USB 2
	
	echo 0x04b3 > idVendor
	echo 0x4010 > idProduct
	
	echo 0x0100 > bcdDevice # v1.0.0
	mkdir -p strings/0x409
	echo "badc0deddeadbeef" > strings/0x409/serialnumber
	echo "Manufacturer" > strings/0x409/manufacturer
	echo "Product" > strings/0x409/product
	
	if [ "$OS" != "MacOs" ]; then
		# Config 1: RNDIS
		mkdir -p configs/c.1/strings/0x409
		echo "0x80" > configs/c.1/bmAttributes
		echo 250 > configs/c.1/MaxPower
		echo "Config 1: RNDIS network" > configs/c.1/strings/0x409/configuration
	
		echo "1" > os_desc/use
		echo "0xcd" > os_desc/b_vendor_code
		echo "MSFT100" > os_desc/qw_sign
	
		mkdir -p functions/rndis.usb0
		echo $SELF0 > functions/rndis.usb0/dev_addr
		echo $HOST > functions/rndis.usb0/host_addr
		echo "RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
		echo "5162001" > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id
	fi
	
	# Config 2: CDC ECM
	mkdir -p configs/c.2/strings/0x409
	echo "Config 2: ECM network" > configs/c.2/strings/0x409/configuration
	echo 250 > configs/c.2/MaxPower
	
	mkdir -p functions/ecm.usb0
	# first byte of address must be even
	echo $HOST > functions/ecm.usb0/host_addr
	echo $SELF1 > functions/ecm.usb0/dev_addr
	
	# Create the CDC ACM function
	mkdir -p functions/acm.gs0
	
	# Link everything and bind the USB device
	if [ "$OS" != "MacOs" ]; then
		ln -s configs/c.1 os_desc
		ln -s functions/rndis.usb0 configs/c.1
	fi
	
	ln -s functions/ecm.usb0 configs/c.2
	ln -s functions/acm.gs0 configs/c.2
	# End functions
	ls /sys/class/udc > UDC
}

function launch_network {
	#ifup br0
	#ifconfig br0 up
	ip link set dev br0 up
	sysctl -w net.ipv4.ip_forward=1
}

function enable_serial {
	systemctl enable getty@ttyGS0.service
}

function main {
	create_usb
	launch_network
	enable_serial
}

main