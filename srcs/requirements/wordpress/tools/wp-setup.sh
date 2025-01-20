#!/bin/sh

# Attendre que MariaDB soit prêt
while ! mysqladmin ping -h mariadb --silent; do
    sleep 1
done

# Télécharger WordPress si ce n'est pas déjà fait
if [ ! -f /var/www/html/wp-config.php ]; then
    # S'assurer que le répertoire est vide
    rm -rf /var/www/html/*
    
    cd /var/www/html
    
    # Utiliser php82 pour wp-cli
    /usr/bin/php82 /usr/local/bin/wp core download --allow-root

    # Créer la configuration WordPress
    /usr/bin/php82 /usr/local/bin/wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root

    # Installer WordPress
    /usr/bin/php82 /usr/local/bin/wp core install \
        --url=https://gbruscan.42.fr \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    # Créer un utilisateur supplémentaire
    /usr/bin/php82 /usr/local/bin/wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    # S'assurer que les permissions sont correctes
    chown -R www-data:www-data /var/www/html
fi

# Démarrer PHP-FPM
exec /usr/sbin/php-fpm82 -F
