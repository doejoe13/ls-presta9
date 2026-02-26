# Use OpenLiteSpeed (Free)
FROM litespeedtech/openlitespeed:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    p7zip-full \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/vhosts/localhost/html

# --- OPTIMIZATION ---
# 1. Give ownership of the folder to www-data
RUN chown www-data:www-data /var/www/vhosts/localhost/html

# 2. Switch to www-data user (Files created now will be owned by www-data automatically)
USER www-data

# Download and Extract (Now runs as www-data)
RUN wget -q "https://assets.prestashop3.com/dst/edition/corporate/9.0.3-3.0/prestashop_edition_classic_version_9.0.3-3.0.zip" -O ps.zip && \
    7z x ps.zip -y && \
    7z x prestashop.zip -y && \
    if [ -d "prestashop" ]; then mv prestashop/* . && rm -rf prestashop; fi && \
    rm -f ps.zip prestashop.zip

# 3. Switch back to root for the rest of the setup
USER root
# --------------------

# Copy the auto-install script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
