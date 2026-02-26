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
    
    # Run the CLI installer
    cd /var/www/vhosts/localhost/html
    php install/index_cli.php \
      --domain=localhost \
      --db_server=$DB_SERVER \
      --db_user=$DB_USER \
      --db_password=$DB_PASSWORD \
      --db_name=$DB_NAME \
      --email=$ADMIN_EMAIL \
      --password=$ADMIN_PASSWORD
      
    # FIX: Delete install folder for security
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
