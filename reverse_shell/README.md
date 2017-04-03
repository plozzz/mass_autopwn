# 5 - Reverse Shell

Encapsulation de la connexion ssh dans un tunnel SSL via stunnel
https://charlesreid1.com/wiki/RaspberryPi/SSH_Stunnel

[Reverse SSH avec stunnel](https://charlesreid1.com/wiki/RaspberryPi/Reverse_SSH_Stunnel)

## Configuration serveur :

```bash
sudo apt install stunnel4
cd /etc/stunnel/
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 365
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
chmod 700 /etc/stunnel/stunnel.pem
vim /etc/stunnel/stunnel.conf
```

Contenu du fichier de conf
```
output = /var/log/stunnel4/stunnel.log
cert=/etc/stunnel/stunnel.pem
key=/etc/stunnel/stunnel.pem
pid=/var/run/stunnel4/stunnel.pid
[ssh]
accept = 443
connect = 127.0.0.1:22
```

Lancement de stunnel4
```bash
stunnel4 /etc/stunnel/stunnel.conf
```

## Configuration client

```bash
sudo apt install stunnel4
cd /etc/stunnel/
scp server_ip:/etc/stunnel/stunnel.pem /etc/stunnel/stunnel.pem
vim /etc/stunnel/stunnel.conf
```

Contenu du fichier de conf
```
output  = /var/log/stunnel4/stunnel.log
cert    = /etc/stunnel/stunnel.pem
key = /etc/stunnel/stunnel.pem
pid     = /var/run/stunnel4/stunnel.pid
client  = yes
[ssh]
accept  = 2200 
connect = 192.168.0.12:443
```

Lancement de stunnel4
```bash
stunnel4 /etc/stunnel/stunnel.conf
```

## Lancement du reverse shell:
### Sur le client
```bash
autossh -R 2201:localhost:22 -p 2200 chris@localhost
```

### Sur le serveur
```
autossh -p 2201 pi@localhost
```
utilisation de autossh pour garder le tunnel alive


## Todo
Encapsulation DNS

Encapsulation IPv6 : https://www.remlab.net/miredo/
