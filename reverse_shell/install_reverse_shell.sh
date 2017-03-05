#!/bin/bash


function install_client {
	server_ip="192.168.0.1"
	
	apt install stunnel4 autossh
	
	cat > /etc/stunnel4 << EOF
output 	= /var/log/stunnel4/stunnel.log
cert 	= /etc/stunnel/stunnel.pem
key	= /etc/stunnel/stunnel.pem
pid 	= /var/run/stunnel4/stunnel.pid
client  = yes
[ssh]
accept 	= 127.0.0.1:2200 
connect = $server_ip:443
EOF
	echo "Don't forget to upload stunnel.pem from server"
}

function install_server {
	server_ip=`hostname -I | cut -d\  -f1`

	apt install stunnel4
	cd /etc/stunnel/
	openssl genrsa -out key.pem 2048
	openssl req -new -x509 -key key.pem -out cert.pem -days 365
	cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
	chmod 700 /etc/stunnel/stunnel.pem
	cat > /etc/stunnel4 << EOF
output 	= /var/log/stunnel4/stunnel.log
cert 	= /etc/stunnel/stunnel.pem
key	= /etc/stunnel/stunnel.pem
pid 	= /var/run/stunnel4/stunnel.pid
[ssh]
accept 	= 443
connect = $server_ip:22
EOF

}

function usage {
		echo "Usage : $0 [-sch]"
		echo "	-c	install client"
		echo "	-s	installserver"
		echo "	-h 	show this message"
}

while getopts "sch" opt; do
  case $opt in
    c)
		echo "install client"
		install_client
     	;;
    s)
		echo "install server"
		install_server
    	;;
    h)
		usage
		;;
  esac
done