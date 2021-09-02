#!/usr/bin/env bash
#-----------------------------------------------
#	Author: FOURGOUS Alexandre
#	Date: 2021-09-02
#	Version: 1.0
#
#	https://github.com/alex4gous
#
#	License: MIT
#-----------------------------------------------

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

while getopts 2:W:C:w:c:u:p:h:iUv OPTNAME; do # A MODIFIER
        case "$OPTNAME" in
		f)	serveurftp="$OPTARG";;
		h)	usage;;
        r)	restore="yes";;
        s)	save="yes";;
        *)	usage;;
        esac
done

# On vérifie qu'est ce qui est mis en paramètre
if [ "serveurftp" = "" ] ; then
	usage
else
	echo "Hello"

###
### Les fonctions
###

Sauvegarde()
{
	echo "Sauvegarde"
}

Restoration()
{
	echo "Restoration"
}

###
### Application - SAUVEGARDE
###
if [ "save" = "yes" ] ; then
	Sauvegarde

###
### Application - RESTORE
###
if [ "restore" = "yes" ] ; then
	Restoration