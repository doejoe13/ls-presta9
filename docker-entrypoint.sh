#!/bin/bash

# 1. Wait for the Database
echo "Checking database connection..."
while ! mysqladmin ping -h"$DB_SERVER" --silent; do
    echo "Waiting for database server..."
    sleep 2
done

# 2. Configure OpenLiteSpeed for the Custom Domain
# We change the default 'localhost' vhost name to your domain
if [ -n "$DOMAIN" ]; then
    echo "Configuring Virtual Host for $DOMAIN..."
    
    # Rename the vhost configuration file
    if [ -f /usr/local/lsws/conf/vhosts/localhost/vhconf.conf ]; then
        # Change the 'name' parameter inside the config file
        sed -i "s/name  localhost/name  ${DOMAIN}/g" /usr/local/lsws/conf/vhosts/localhost/vhconf.conf
        
        # Optional: Create a symlink if you want to access files via domain name folder
        if [ ! -d "/var/www/vhosts/${DOMAIN}" ]; then
            ln -s /var/www/vhosts/localhost /var/www/vhosts/${DOMAIN}
        fi
        echo "Virtual Host configured."
    fi
fi

# 3. Check if PrestaShop is installed
if [ ! -f /var/www/vhosts/localhost/html/app/config/parameters.php ]; then
    echo "PrestaShop not installed. Starting automatic installation..."
    
    INSTALL_DOMAIN="${DOMAIN:-localhost}"
    echo "Installing for domain: $INSTALL_DOMAIN"

    # Fix permissions
    chown -R nobody:nogroup /var/www/vhosts/localhost/html
    
    # Run the CLI installer
    cd /var/www/vhosts/localhost/html
    php install/index_cli.php \
      --domain=$INSTALL_DOMAIN \
      --db_server=$DB_SERVER \
      --db_user=$DB_USER \
      --db_password=$DB_PASSWORD \
      --db_name=$DB_NAME \
      --email=$ADMIN_EMAIL \
      --password=$ADMIN_PASSWORD
      
    # Security: Delete install folder
    echo "Deleting install folder..."
    rm -rf /var/www/vhosts/localhost/html/install
    
    echo "PrestaShop Installation Complete."
else
    echo "PrestaShop is already installed."
fi

# 4. Start LiteSpeed
echo "Starting LiteSpeed..."
# Ensure it stops first if restarting
/usr/local/lsws/bin/lswsctrl stop 2>/dev/null
/usr/local/lsws/bin/lswsctrl start

# Keep container alive
tail -f /usr/local/lsws/logs/error.log
