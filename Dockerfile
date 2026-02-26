# Use OpenLiteSpeed (Free)
FROM litespeedtech/openlitespeed:latest

# Install dependencies (Switched to p7zip-full for reliability)
RUN apt-get update && apt-get install -y \
    wget \
    p7zip-full \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/vhosts/localhost/html

# Download PrestaShop 9.0.3
RUN wget -q "https://assets.prestashop3.com/dst/edition/corporate/9.0.3-3.0/prestashop_edition_classic_version_9.0.3-3.0.zip" -O ps.zip

# Extract using 7-Zip (More stable than unzip)
# 1. Extract the outer zip
RUN 7z x ps.zip -y
# 2. Extract the inner prestashop.zip
RUN 7z x prestashop.zip -y
# 3. Move files and cleanup
RUN if [ -d "prestashop" ]; then mv prestashop/* . && rm -rf prestashop; fi && \
    rm -f ps.zip prestashop.zip

# Set permissions
RUN chown -R www-data:www-data /var/www/vhosts/localhost/html && \
    chmod -R 755 /var/www/vhosts/localhost/html

# Copy the auto-install script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
