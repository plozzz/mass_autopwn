#Workflow crack wifi & scan

##Scan wifi (Step 1)
-Mode monitor
-Ecoute des réseaux

-Si réseaux WEP
	-Pour chaque réseau WEP
		-Crack WEP & stockage de la clé décryptée

-Si réseaux WPA && réseaux
	-Pour chaque réseau WPA
	-Capture & stockage de la clé chiffrée

-Si au moins une clé (chiffrée ou non a été trouvée) :
	-Pour chaque clé décryptée
		-Connexion au wifi (via interface native)
		-Scan de ports
		-Déconnexion au wifi

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


##Scan de ports (Step 2)
-Nmap IP sur le réseau
-Scan de vulnerabilités
