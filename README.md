#**Ce script sert à sauvegarder et à restaurer un site wordpress via un serveur ftp.**

# Save-restore-wp

- Basé sur le tutoriel d'installation d'une site WORDPRESS: https://www.rosehosting.com/blog/how-to-install-wordpress-with-nginx-on-debian-10/
- Et pour le serveur FTP: https://www.ionos.fr/digitalguide/serveur/configuration/configurer-un-serveur-ftp-sous-debian-avec-proftpd/

## A renseigner dans le script:
- Le nom et mdp de l'utilisateur du serveur ftp (non automatisé)
- Le nom et mdp pour mysql (non automatisé)

## Améliorations à apporter:
 - Passer le script en anglais
 - créer un fichier de configuration et l'appeler dans le script (pour les variables de type: mdp mysql, etc...)
 - automatiser le nombre de jour de sauvegarde
 - Modifier directement le fichier php au lieu de le réimporter
 - chiffrer/déchiffrer les sauvegardes
 - 
