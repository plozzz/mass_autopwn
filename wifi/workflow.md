# Workflow crack wifi & scan de ports
## Scan wifi (Step 1)
Mise en mode écoute de l'antenne wifi 

	-Mode monitor
	-Ecoute des réseaux

Début de l'attaque

	-Si réseaux WEP
        -Pour chaque réseau WEP
                -Crack WEP & stockage de la clé décryptée

	-Si réseaux WPA
        -Pour chaque réseau WPA
        -Capture & stockage de la clé chiffrée


	-Si au moins une clé (chiffrée ou non a été trouvée) :
        -Pour chaque clé décryptée
                -Connexion au wifi (via interface native)
                -Scan de ports
                Déconnexion au wifi
                
        -Pour chaque clé chiffrée
                -Tentative de décrypter la clé sur un dictionnaire (petit dictionnaire)
                        -Si clé décrypté
                                -Connexion au wifi (via interface native)
                                -Scan de ports
                                -Déconnexion au wifi
                        -Sinon
                                - Si connection avec le c&c envoit de la clé chiffré
                                - Sinon déplacement de la clé chiffrée dans un répertoire spécifique

	-Sinon si réseaux WPS
        -Pour chaque réseau WPS
                -Hack WPS & scan


## Scan de ports (Step 2)
Partie à définir (qualys, metasploit, scripts nse)

	-Nmap IP sur le réseau
	-Scan de vulnerabilités

