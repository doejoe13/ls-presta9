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
    
    # Define the installer path (PrestaShop 9 might move it, let's verify)
    INSTALLER="/var/www/vhosts/localhost/html/install/index_cli.php"
    
    # Check if installer exists
    if [ -f "$INSTALLER" ]; then
        php "$INSTALLER" \
          --domain=localhost \
          --db_server=$DB_SERVER \
          --db_user=$DB_USER \
          --db_password=$DB_PASSWORD \
          --db_name=$DB_NAME \
          --email=$ADMIN_EMAIL \
          --password=$ADMIN_PASSWORD
    else
        echo "ERROR: Installer not found at $INSTALLER"
        echo "Listing files to debug:"
        ls -la /var/www/vhosts/localhost/html
    fi
else
    echo "PrestaShop is already installed."
fi

# 3. Start LiteSpeed
echo "Starting LiteSpeed..."
# We use 'start' not 'restart' to avoid the systemd errors you saw
/usr/local/lsws/bin/lswsctrl start

# Keep container alive
tail -f /usr/local/lsws/logs/error.log
