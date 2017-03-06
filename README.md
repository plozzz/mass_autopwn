# Mass autopwn

## Vecteurs d'attaque:
1. USB via emulation Ethernet (PoisonTap)
2. Wifi avec crack auto des cles (wifite custom)
3. Clonage des equipements Bluethoot
4. Clone carte MiFare
5. Reverse Shell

## Scenarios :
```
SI branche a un pc ALORS
  1. poison tap
  5. Reverse Shell
SINON
  SI carte wifi secondaire ALORS
  	2. Wifi avec crack auto des cles
  	5. Reverse Shell
  SI carte MiFare ALORS
    4. Clone carte MiFare
  SINON
    3. clonage equipement Bluethoot
```


## Installation :

Utilisation d'un Raspberry PI Zero W
Systeme : raspbian

Mise a jour :
sudo apt update
sudo apt upgrade
sudo apt install git vim 

changement du mdp par defaut :
sudo passwd pi

## Configuration du wifi :
https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md

sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

network={
    ssid="The_ESSID_from_earlier"
    psk="Your_wifi_password"
}

sudo wpa_cli reconfigure









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