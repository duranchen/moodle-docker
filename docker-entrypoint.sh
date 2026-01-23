#!/bin/bash
set -e

echo "Starting Moodle PHP-FPM with Nginx container..."

mkdir -p /var/log/supervisor /var/run/php-fpm /var/cache/nginx

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

if [ ! -f /var/www/html/health.php ]; then
    cat > /var/www/html/health.php << 'INNER_EOF'
<?php
echo "OK";
?>
INNER_EOF
    chown www-data:www-data /var/www/html/health.php
fi

exec "$@"
