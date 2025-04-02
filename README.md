# Azure AD Authentication Proxy with Nginx and Let's Encrypt

A Docker-based solution for adding Azure AD authentication to any web application without modifying the application code. Acts as a reverse proxy with authentication layer.

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

## Installation

1. Clone the repository:
```bash
git clone https://github.com/SugiKent/azure-ad-proxy-nginx-letsencrypt.git
cd azure-ad-proxy-nginx-letsencrypt
```

2. Generate DH parameters (if not already present):
```bash
openssl dhparam -out nginx/dhparam/dhparam.pem 2048
```

## Configuration

1. Edit the `.env` file:
```ini
# Azure AD Settings
CLIENT_ID=your_azure_ad_app_id
CLIENT_SECRET=your_azure_ad_client_secret
AZURE_TENANT=your_azure_tenant_id

# Domain Settings
DOMAIN=yourdomain.com

# Backend Application
BACKEND_HOST=your-backend-service
BACKEND_PORT=8080

# Authentication Exclusions
AUTH_SKIP_PATHS=/public|/static|/healthcheck
```

2. Register your application in Azure AD:
   - Set redirect URI to: `https://yourdomain.com/oauth2/callback`
   - Enable ID tokens in authentication settings
   - Add required permissions (User.Read, openid, profile)

## Setup SSL Certificates

Run the initialization script:
```bash
chmod +x init-letsencrypt.sh
./init-letsencrypt.sh
```

## Usage

Start the services:
```bash
docker-compose up -d
```

## Customization

### Skip Authentication for Specific Paths
Edit `AUTH_SKIP_PATHS` in `.env`:
```ini
AUTH_SKIP_PATHS=/public|/api/health|/static
```

### Modify Nginx Configuration
Edit `nginx/templates/default.conf.template` for:
- Custom routing rules
- Additional headers
- Rate limiting

## Maintenance

- Certificates auto-renew every 60 days
- View logs: `docker-compose logs -f`
- Update containers: `docker-compose pull && docker-compose up -d`

## Troubleshooting

**Certificate errors**:
- Verify domain points to server IP
- Check port 80 is accessible
- View logs: `docker-compose logs certbot`

**Authentication issues**:
- Verify Azure AD app registration
- Check redirect URIs match exactly
- Validate client secret hasn't expired

## License
MIT

## Azure AD Application Registration

### 1. Register the Application

1. Access the [Azure portal](https://portal.azure.com/).
2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**.
3. Enter a name for your application.
4. Select the supported account types.
5. In the **Redirect URI** section, create a new web platform entry (e.g., `https://your-domain.com/oauth2/callback`).

### 2. Configure API Permissions

1. Go to the **API Permissions** page and click **Add a permission**.
2. Select **Microsoft Graph** > **Application permissions** > **Group** > **Group.Read.All**.
3. Click **Add permissions** and, if necessary, grant admin consent.

### 3. Create a Client Secret

1. Go to the **Certificates & secrets** page and add a new client secret.
2. Note down the value of the client secret.

### 4. Configure Endpoints as Needed

1. If using the v2.0 endpoint, set `"accessTokenAcceptedVersion": 2` in the **Manifest** page.

## Obtaining Azure AD Settings Values

To obtain the values for `CLIENT_ID`, `CLIENT_SECRET`, and `AZURE_TENANT`, follow these steps:

1. **CLIENT_ID**: This is the Application (client) ID found on the application's **Overview** page in the Azure portal.
2. **CLIENT_SECRET**: This is the value of the client secret you created in the **Certificates & secrets** page.
3. **AZURE_TENANT**: This is the Directory (tenant) ID found on the application's **Overview** page in the Azure portal.
