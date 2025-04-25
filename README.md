# Azure AD Authentication Proxy with Nginx and Let's Encrypt

<div align="center">

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![Azure AD](https://img.shields.io/badge/Azure%20AD-Integrated-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Powered-009639?logo=nginx)](https://www.nginx.com/)
[![Let's Encrypt](https://img.shields.io/badge/Let's%20Encrypt-Secured-003A70?logo=let%27s-encrypt)](https://letsencrypt.org/)

</div>

A Docker-based solution for adding Azure AD authentication to any web application without modifying the application code. Acts as a reverse proxy with an authentication layer.

## Key Features

- 🔒 Seamless Azure AD integration
- 🛡️ SSL encryption via Let's Encrypt (auto-renewal)
- ⚙️ Zero application code changes required
- 🚪 Path-based authentication bypass
- 🐳 Docker Compose deployment
- 🔄 Automatic certificate renewal

## Prerequisites

- Docker and Docker Compose installed
- Azure AD tenant with admin access
- Registered domain name
- Ports 80 and 443 accessible

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/SugiKent/azure-ad-proxy-nginx-letsencrypt.git
cd azure-ad-proxy-nginx-letsencrypt
```

2. Create environment variables file:
```bash
cp .env.example .env
```

3. Edit the `.env` file with appropriate values (see "Configuration" section below)

4. Generate DH parameters (if they don't exist):
```bash
mkdir -p nginx/dhparam
openssl dhparam -out nginx/dhparam/dhparam.pem 2048
```

5. Run the initialization script:
```bash
chmod +x init-letsencrypt.sh
./init-letsencrypt.sh
```

6. Start the services:
```bash
docker-compose up -d
```

## Configuration Guide

### Azure AD Application Registration

1. Register a new application in Azure AD:
   - Go to the [Azure Portal](https://portal.azure.com/)
   - Navigate to **Azure Active Directory** > **App registrations** > **New registration**
   - Enter a name for your application
   - Select the supported account type
   - Set the redirect URI to `https://your-domain.com/oauth2/callback`
   - Enable ID tokens in authentication settings
   - Add required permissions (User.Read, openid, profile)

2. Configure API permissions:
   - Go to **API permissions** and click **Add a permission**
   - Select **Microsoft Graph** > **Application permissions** > **Group** > **Group.Read.All**
   - Click **Add permissions** and grant admin consent if required

3. Create a client secret:
   - Go to **Certificates & secrets** and add a new client secret
   - Note down the client secret value

4. Configure endpoints if needed:
   - For v2.0 endpoints, set `"accessTokenAcceptedVersion": 2` in the **Manifest** page

### Getting Azure AD Configuration Values

You'll need the following values for your `.env` file:

1. **CLIENT_ID**: The Application (client) ID found on the overview page
2. **CLIENT_SECRET**: The value of the client secret created earlier
3. **AZURE_TENANT**: The Directory (tenant) ID found on the overview page

### Generating Cookie Secret

For the `COOKIE_SECRET`, you need a random 32-character string. Generate it with:

```bash
openssl rand -base64 32 | tr -- '+/' '-_'
```

## Customization

### Skip Authentication for Specific Paths

Edit `AUTH_SKIP_PATHS` in your `.env` file:
```ini
AUTH_SKIP_PATHS=/public|/api/health|/static
```

### Customize Nginx Configuration

Modify `nginx/templates/default.conf.template` to configure:
- Custom routing rules
- Additional headers
- Rate limiting

## Backend Network Configuration

This proxy uses Docker networks to connect with your existing backend application. The `.env` file contains the following network-related settings:

```ini
BACKEND_NETWORK=backend
USE_EXTERNAL_NETWORK=true
```

### Using External Networks (Recommended)

1. If your backend application is already running in a separate Docker Compose environment, set its network name as `BACKEND_NETWORK` and keep `USE_EXTERNAL_NETWORK=true`.

2. Create an external network with:
```bash
docker network create backend
```

3. In your backend application's docker-compose.yaml, configure the same network:
```yaml
networks:
  backend:
    external: true
```

### Using Internal Networks

If you're launching your backend application in the same Docker Compose setup, set `USE_EXTERNAL_NETWORK=false` in your `.env` file. This will make the backend network automatically created by docker-compose and not referenced externally.

### Using a Different Network Name

If your backend application uses a different network name (e.g., `app-network`), configure your `.env` file like this:

```ini
BACKEND_NETWORK=app-network
USE_EXTERNAL_NETWORK=true
```

You can specify the backend host using the service name. For example, if your backend service is named `app`:

```ini
BACKEND_HOST=app
BACKEND_PORT=8080
```

## Maintenance

- Certificates are automatically renewed every 60 days
- Check logs: `docker-compose logs -f`
- Update containers: `docker-compose pull && docker-compose up -d`

## Troubleshooting

### Certificate Errors

- Verify your domain points to your server IP
- Ensure port 80 is accessible (needed for Let's Encrypt challenge)
- Check logs: `docker-compose logs certbot`
- If Certbot logs show "EOFError" or interactive prompt issues, issue certificates manually (see below)
- Verify certificates are properly generated: `docker compose exec nginx ls -la /etc/letsencrypt/live/${DOMAIN}/`
- Check certificate validity: `docker compose exec nginx openssl x509 -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -text -noout | grep -A2 "Validity"`

### Manual Let's Encrypt Certificate Issuance

If the automatic Certbot process fails (especially with interactive prompt issues), you can issue certificates manually:

```bash
# Force renewal of existing certificates
docker compose exec certbot certbot certonly --webroot --webroot-path=/var/www/certbot --agree-tos --non-interactive --email your-email@example.com -d yourdomain.com --force-renewal
```

After issuing the certificate, restart Nginx to apply the new certificate:
```bash
docker compose exec nginx nginx -s reload
```

### Authentication Issues

- Verify your Azure AD application registration
- Check that the redirect URI exactly matches
- Ensure the client secret has not expired

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
