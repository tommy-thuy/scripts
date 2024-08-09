#!/bin/bash

# Update package list
sudo apt-get update

# Install Apache2
sudo apt-get install -y apache2

# Install PHP 8.2 and required extensions for Drupal 10
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-gd php8.2-mbstring php8.2-mysql php8.2-opcache php8.2-readline php8.2-sqlite3 php8.2-xml php8.2-zip php8.2-bcmath libapache2-mod-php8.2 php8.2-apcu

# Enable Apache2 modules
sudo a2enmod php8.2
sudo a2enmod rewrite

# Create a virtual host for Drupal 10
sudo bash -c 'cat > /etc/apache2/sites-available/sif-v2.ourbetterworld.org.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@ourbetterworld.org
    ServerName sif-v2.ourbetterworld.org
	ServerAlias magazine.sif-v2.ourbetterworld.org
	DocumentRoot /var/www/html/docroot
    
    <Directory /var/www/html/docroot/web>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

# Enable the new virtual host
sudo a2ensite sif-v2.ourbetterworld.org.conf

# Install Certbot
sudo apt-get install -y certbot python3-certbot-apache

# Obtain SSL certificate
sudo certbot --apache -d sif-v2.ourbetterworld.org

# Set up a cron job for automatic certificate renewal
sudo bash -c 'echo "0 0,12 * * * root certbot renew --quiet --post-hook \"systemctl reload apache2\"" > /etc/cron.d/certbot-renew'

# Install Git
sudo apt-get install -y git

# REPO_URL="https://github.com/username/repository.git"
# BRANCH_NAME="your-branch"
# GIT_USERNAME="your-username"
# GIT_TOKEN="your-token"

# Clone the specific branch
# sudo git clone --branch $BRANCH_NAME --single-branch https://$GIT_USERNAME:$GIT_TOKEN@$REPO_URL

# Clone the Drupal 10 repository
# sudo git clone https://github.com/your-repo/drupal.git /var/www/html/drupal

# Set up a cron job for pulling the latest code from the repository
# sudo bash -c 'echo "0 0 * * * cd /var/www/html/drupal && git pull origin main" > /etc/cron.d/git-pull'

# Reload Apache2 to apply changes
sudo systemctl reload apache2

# Verify installation
php -v
