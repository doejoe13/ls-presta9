# CHANGED: Use OpenLiteSpeed (Free, no license required)
FROM litespeedtech/openlitespeed:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/vhosts/localhost/html

# Download and Unzip PrestaShop 9.0.3
RUN wget -q "https://assets.prestashop3.com/dst/edition/corporate/9.0.3-3.0/prestashop_edition_classic_version_9.0.3-3.0.zip" -O ps.zip && \
    unzip ps.zip && \
    unzip prestashop.zip && \
    # FIX: Move files from nested 'prestashop' folder to current directory
    if [ -d "prestashop" ]; then mv prestashop/* . && rm -rf prestashop; fi && \
    rm ps.zip prestashop.zip

# Set permissions
RUN chown -R www-data:www-data /var/www/vhosts/localhost/html && \
    chmod -R 755 /var/www/vhosts/localhost/html

# Copy the auto-install script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
