# Use OpenLiteSpeed (Free)
FROM litespeedtech/openlitespeed:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    p7zip-full \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/vhosts/localhost/html

# 1. Set ownership to 'nobody' (OpenLiteSpeed default user)
RUN chown nobody:nogroup /var/www/vhosts/localhost/html

# 2. Switch to 'nobody' to download/unzip (Ensures correct permissions)
USER nobody

# Download and Extract
RUN wget -q "https://assets.prestashop3.com/dst/edition/corporate/9.0.3-3.0/prestashop_edition_classic_version_9.0.3-3.0.zip" -O ps.zip && \
    7z x ps.zip -y && \
    7z x prestashop.zip -y && \
    if [ -d "prestashop" ]; then mv prestashop/* . && rm -rf prestashop; fi && \
    rm -f ps.zip prestashop.zip

# 3. Switch back to root
USER root

# Copy the auto-install script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
