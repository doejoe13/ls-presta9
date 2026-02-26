#!/bin/bash

# 1. Wait for the Database
echo "Checking database connection..."
while ! mysqladmin ping -h"$DB_SERVER" --silent; do
    echo "Waiting for database server..."
    sleep 2
done

# 2. Check if PrestaShop is installed
if [ ! -f /var/www/vhosts/localhost/html/app/config/parameters.php ]; then
    echo "PrestaShop not installed. Starting automatic installation..."
    
    # FIX: Use the DOMAIN variable passed from Dockploy
    # If DOMAIN is not set, fallback to localhost
    INSTALL_DOMAIN="${DOMAIN}"
    
    echo "Installing for domain: $INSTALL_DOMAIN"

    # Fix permissions so the installer can rename the admin folder
    # We run this as root before the installer runs
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

# 3. Start LiteSpeed
echo "Starting LiteSpeed..."
/usr/local/lsws/bin/lswsctrl start

# Keep container alive
tail -f /usr/local/lsws/logs/error.log
