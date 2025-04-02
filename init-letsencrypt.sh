#!/bin/bash

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Create required directories
mkdir -p ./data/certbot/conf/live/${DOMAIN}
mkdir -p ./data/certbot/www

# Verify domain is set
if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN environment variable is not set"
  exit 1
fi

# Generate temporary self-signed certificate
openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
  -keyout ./data/certbot/conf/live/${DOMAIN}/privkey.pem \
  -out ./data/certbot/conf/live/${DOMAIN}/fullchain.pem \
  -subj "/CN=${DOMAIN}"

# Start containers for certificate issuance
docker compose up -d nginx

# Obtain Let's Encrypt certificate
docker compose run --rm certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email admin@${DOMAIN} --agree-tos --no-eff-email \
  -d ${DOMAIN} -d www.${DOMAIN}

# Reload Nginx to use new certificates
docker compose exec nginx nginx -s reload

echo "SSL certificate setup completed for ${DOMAIN}"