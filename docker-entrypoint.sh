#!/bin/bash

# 1. Wait for the Database to be ready
echo "Checking database connection..."
while ! mysqladmin ping -h"$DB_SERVER" --silent; do
    echo "Waiting for database server..."
    sleep 2
done

# 2. Check if PrestaShop is already installed
# We check if the config file exists
if [ ! -f /var/www/vhosts/localhost/html/app/config/parameters.php ]; then
    echo "PrestaShop not installed. Starting automatic installation..."

    # Run the CLI installer
    php /var/www/vhosts/localhost/html/install/index_cli.php \
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

# 3. Start the LiteSpeed Web Server
# This keeps the container running
echo "Starting LiteSpeed..."
/usr/local/lsws/bin/lswsctrl start
tail -f /usr/local/lsws/logs/error.log
