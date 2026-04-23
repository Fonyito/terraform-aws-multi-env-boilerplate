#!/bin/bash
# ==============================================================================
# WordPress Installation Script
# ==============================================================================
# This script installs and configures WordPress on Amazon Linux 2023
# with EFS for shared storage and RDS MySQL for database
# ==============================================================================

set -e

# Update system
yum update -y

# Install Apache, PHP 8.1, and required extensions
yum install -y httpd php php-mysqlnd php-fpm php-json php-gd php-mbstring php-xml php-opcache amazon-efs-utils

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Mount EFS
mkdir -p /var/www/html
mount -t efs -o tls ${efs_id}:/ /var/www/html

# Add EFS to fstab for automatic mounting on reboot
echo "${efs_id}:/ /var/www/html efs _netdev,tls 0 0" >> /etc/fstab

# Download and install WordPress (only if not already installed)
if [ ! -f /var/www/html/wp-config.php ]; then
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    
    # Create wp-config.php
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    # Configure database connection
    sed -i "s/database_name_here/${db_name}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${db_user}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${db_password}/" /var/www/html/wp-config.php
    sed -i "s/localhost/${db_host}/" /var/www/html/wp-config.php
    
    # Generate unique salts
    SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    STRING='put your unique phrase here'
    printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php
fi

# Set correct permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart httpd

# Configure PHP
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php.ini

# Restart Apache to apply PHP changes
systemctl restart httpd

echo "WordPress installation completed successfully!"
