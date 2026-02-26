#!/bin/bash

# 1. Wait for the Database
echo "Checking database connection..."
while ! mysqladmin ping -h"$DB_SERVER" --silent; do
    echo "Waiting for database server..."
    sleep 2
done

# 2. Configure LiteSpeed for the Custom Domain
# If DOMAIN is set, map it to the localhost files
if [ -n "$DOMAIN" ]; then
    echo "Configuring Virtual Host for $DOMAIN..."
    
    # Add domain to LiteSpeed config (creates /var/www/vhosts/$DOMAIN)
    domainctl.sh --add $DOMAIN
    
    # Link the custom domain folder to the existing localhost files
    # This ensures requests to 'presta.totalplus.eu' serve the files in 'localhost/html'
    if [ ! -d "/var/www/vhosts/$DOMAIN/html" ]; then
        ln -s /var/www/vhosts/localhost/html /var/www/vhosts/$DOMAIN/html
        echo "Linked $DOMAIN to localhost files."
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
/usr/local/lsws/bin/lswsctrl start

# Keep container alive
tail -f /usr/local/lsws/logs/error.log
