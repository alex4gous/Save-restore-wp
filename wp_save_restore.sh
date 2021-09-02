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

while getopts f:rs OPTNAME; do # A MODIFIER
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

###
### Les fonctions
###

timestamp=`date +"%s"`
nom_du_fichier_de_sauvegarde="sauvegarde"$timestamp

Sauvegarde()
{
	cd /root/
	tar -zcf $nom_du_fichier_de_sauvegarde.tar /root/
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; put -O /home/serveurftp/ /root/$nom_du_fichier_de_sauvegarde.tar"
	rm /root/$nom_du_fichier_de_sauvegarde.tar
}

Restoration()
{
	echo "Restoration from $serveurftp"
}

###
### Application - SAUVEGARDE
###
if [ "$save" = "yes" ] ; then
	Sauvegarde
fi

###
### Application - RESTORE
###
if [ "$restore" = "yes" ] ; then
	Restoration
fi
