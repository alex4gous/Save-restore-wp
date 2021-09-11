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

# vérifier si on est root

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

# On vérifie qu'on est root
if [ "$EUID" -ne 0 ]
  then echo "Vous devez etre root pour lancer le script"
  exit
fi

# On vérifie qu'est ce qui est mis en paramètre
if [ "$serveurftp" = "" ] ; then
	usage
fi

###
### Les fonctions et variables
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

	cd /tmp/
	mysqldump --user=wpuser --password='dbpassword' --databases wpdb > /tmp/dump-BDD-wordpress
	tar -zcf $nom_du_fichier_de_sauvegarde.tar /etc/nginx/ /tmp/dump-BDD-wordpress /var/www/html/ /etc/php/7.3/fpm/php.ini
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; put -O /home/serveurftp/ /tmp/$nom_du_fichier_de_sauvegarde.tar"
	rm /tmp/$nom_du_fichier_de_sauvegarde.tar
}

Rotation_des_Sauvegardes()
{
	#On supprime le 3, on rename le 2->3, puis on rename le 1->2 (pour préparer l'arrivée du 1)
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; rm /home/serveurftp/sauvegarde-3.tar"
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; mv /home/serveurftp/sauvegarde-2.tar /home/serveurftp/sauvegarde-3.tar"
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; mv /home/serveurftp/sauvegarde-1.tar /home/serveurftp/sauvegarde-2.tar"
}

Restoration()
{
	## INSTALLATION DU WORDPRESS
	#On met a jour les paquets - puis on lance le telechargement des paquets que l on veut.
	apt update -y && apt upgrade -y

	#On installe les paquets pour wordpress
	apt-get install nginx mariadb-server mariadb-client php-cgi php-common php-fpm php-pear php-mbstring php-zip php-net-socket php-gd php-xml-util php-gettext php-mysql php-bcmath unzip wget git -y

	#On redémarre php et nginx
	pkill -f nginx
	systemctl start nginx
	systemctl restart php7.0-fpm.service

	#Prération mysql
#	mysql -u root -p -e "CREATE DATABASE wpdb; CREATE USER 'wpuser'@'localhost' identified by 'dbpassword'; GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost'; FLUSH PRIVILEGES; EXIT;"

	## RESTORATION DES FICHIERS DU FTP
	lftp -c "open -u $FTP_USER,$FTP_PASS $serveurftp; get /home/serveurftp/sauvegarde-1.tar"
	mv sauvegarde-1.tar /tmp/sauvegarde-1.tar
	tar xzf /tmp/sauvegarde-1.tar -C /tmp/ # a supprimer surement
	cp -r /tmp/etc/nginx/ /etc/
	cp -r /tmp/var/www/html/ /var/www/
	cp -r /tmp/etc/php/7.3/fpm/php.ini /etc/php/7.0/fpm/php.ini
#	mysql -u wpuser -p dbpassword < dump-BDD-wordpress.sql 

	# change the ownership of the wordpress directory
#	chown -R www-data:www-data /var/www/html/wordpress

	# redémarre les services
#	systemctl restart nginx
#	systemctl restart php7.3-fpm
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
