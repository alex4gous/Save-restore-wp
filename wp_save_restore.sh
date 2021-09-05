#!/usr/bin/env bash
#-----------------------------------------------
#	Author: FOURGOUS Alexandre
#	Date: 2021-09-02
#	Version: 1.0
#
#	https://github.com/alex4gous/Save-restore-wp
#
#	License: MIT
#-----------------------------------------------

# vérifier si le paquet LFTP est présent

FTP_USER="serveurftp"
FTP_PASS="serveurftp"

usage()
{
	echo "usage: ./wp_save_restore.sh [OPTIONS] -u [user] -p [pass] -h [hostname]"
	echo "options:"
	echo "            -r -f [IP du serveur FTP] Pour lancer la restoration" # A MODIFIER
	echo "            -s -f [IP du serveur FTP] Pour lancer la sauvegarde"

    exit 3
}

if [ "$1" == "--help" ]; then
    usage; exit 0
fi

while getopts f:rs OPTNAME; do
        case "$OPTNAME" in
	f)	serveurftp="$OPTARG";;
        r)	restore="yes";;
        s)	save="yes";;
        *)	usage;;
        esac
done

# On vérifie qu'est ce qui est mis en paramètre
if [ "$serveurftp" = "" ] ; then
	usage
fi

# On vérifie que le paquet LFTP est installé

###
### Les fonctions
###

Installation_paquet()
{
	REQUIRED_PKG="$1"
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	# echo Checking for $REQUIRED_PKG: $PKG_OK
	if [ "" = "$PKG_OK" ]; then
		echo "$REQUIRED_PKG non installé. Setting up $REQUIRED_PKG."
		apt-get --yes -qq install $REQUIRED_PKG
	fi
}

nom_du_fichier_de_sauvegarde="sauvegarde-1"

Sauvegarde()
{
	# On se déplace dans /tmp/
	# On zip les fichiers/dossiers voulu
	# On l'envoi sur le serveur ftp
	# On supprime le fichier temporaire
	# MYSQLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	cd /tmp/
	tar -zcf $nom_du_fichier_de_sauvegarde.tar /tmp/ #et le fichier mysql A MODIFIER
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; put -O /home/serveurftp/ /tmp/$nom_du_fichier_de_sauvegarde.tar"
	rm /tmp/$nom_du_fichier_de_sauvegarde.tar
}

Rotation_des_Sauvegardes()
{
	#On supprime le 3, on rename le 2->3, puis on rename le 1->2 (pour préparer l arrivé du 1)
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; rm /home/serveurftp/sauvegarde-3.tar"
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; mv /home/serveurftp/sauvegarde-2.tar /home/serveurftp/sauvegarde-3.tar"
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; mv /home/serveurftp/sauvegarde-1.tar /home/serveurftp/sauvegarde-2.tar"
}

Restoration()
{
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; get /home/serveurftp/sauvegarde-1.tar"
	mv sauvegarde-1.tar /tmp/sauvegarde-1.tar
	tar xzf /tmp/sauvegarde-1.tar -C /tmp/
	cp -r /tmp/ /root/tmp/
	#on cp les fichiers
	#on cp mysql
}

###
### Préparation
###

Installation_paquet lftp

###
### Application - SAUVEGARDE
###
if [ "$save" = "yes" ] ; then
	Rotation_des_Sauvegardes
	Sauvegarde
fi

###
### Application - RESTORE
###
if [ "$restore" = "yes" ] ; then
	Restoration
fi
