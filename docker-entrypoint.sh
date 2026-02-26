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
    
    # Fix permissions just in case (OpenLiteSpeed runs as 'lsadm' or 'nobody' depending on build)
    # We map to www-data as that is standard for PrestaShop
    chown -R www-data:www-data /var/www/vhosts/localhost/html
    
    # Run the CLI installer
    # We cd to the directory to ensure relative paths work
    cd /var/www/vhosts/localhost/html
    php install/index_cli.php \
      --domain=localhost \
      --db_server=$DB_SERVER \
      --db_user=$DB_USER \
      --db_password=$DB_PASSWORD \
      --db_name=$DB_NAME \
      --email=$ADMIN_EMAIL \
      --password=$ADMIN_PASSWORD
      
    echo "PrestaShop Installation Complete."
else
    echo "PrestaShop is already installed."
fi

# 3. Start LiteSpeed
echo "Starting LiteSpeed..."
# This is the correct command for OpenLiteSpeed inside the container
/usr/local/lsws/bin/lswsctrl start

# Keep container alive and show logs
tail -f /usr/local/lsws/logs/error.log
