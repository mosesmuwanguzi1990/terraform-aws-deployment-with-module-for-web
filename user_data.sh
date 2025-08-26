#!/bin/bash
# Update package lists and upgrade existing packages
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Apache web server
apt-get install apache2 -y

# Enable necessary Apache modules and sites
a2enmod ssl
a2ensite default-ssl.conf

# IMPORTANT: First, add rules to the firewall
ufw allow 'Apache Full'
ufw allow 'OpenSSH'

# THEN, enable the firewall non-interactively
ufw --force enable

# Restart Apache to apply all changes
systemctl restart apache2