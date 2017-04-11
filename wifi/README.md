# 3 - Wifi avec crack auto des cles (wifite custom)

/!\ Necessite une antenne compatible /!\

Source git://git.kali.org/packages/wifite.git

## Installation des dependence pour hack wifi

```bash
apt install aircrack-ng reaver tshark pyrit build-essential libssl-dev libpcap0.8-dev libdigest-hmac-perl

wget http://www.willhackforsushi.com/code/cowpatty/4.6/cowpatty-4.6.tgz
tar xf cowpatty-4.6.tgz
cd cowpatty-4.6
git checkout debian/4.6-1kali3
make
sudo cp cowpatty /usr/bin
```

## TODO
modifier wifite pour passer en parametre l'interface
mettre en place une selection automatique des reseaux a attaquer
sauvegarder toutes les informations utiles recupere durant l'attaque (MAC Client, SSID, ...)
