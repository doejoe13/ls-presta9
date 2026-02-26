FROM litespeedtech/litespeed:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/vhosts/localhost/html

# Download PrestaShop 9.0.3
RUN wget -q "https://assets.prestashop3.com/dst/edition/corporate/9.0.3-3.0/prestashop_edition_classic_version_9.0.3-3.0.zip" -O ps.zip #&& \
RUN unzip ps.zip #&& \
RUN unzip prestashop.zip #&& \
RUN rm ps.zip prestashop.zip

# Set permissions
RUN chown -R www-data:www-data /var/www/vhosts/localhost/html && \
    chmod -R 755 /var/www/vhosts/localhost/html

# --- NEW LINES ---
# Copy the auto-install script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
