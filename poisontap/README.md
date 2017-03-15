# POISON TAP

Utilisation de HackPI:

https://github.com/wismna/HackPi
git clone https://github.com/wismna/HackPi

Pour ne pas perdre le wifi, ne pas oublier rajouter la configuration dans le fichier : /etc/network/interfaces

```
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

Desactiver l'animation du poisontap
'''bash
vim target_injected_xhtmljs.html

var cacheIframe = 0;
'''