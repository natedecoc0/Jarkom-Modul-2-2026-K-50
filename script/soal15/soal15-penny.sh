cat > /root/soal15-penny-eternal.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache php85-fpm

mkdir -p /var/www/eternal
cat > /var/www/eternal/index.php << 'PHP'
<!DOCTYPE html>
<html>
<head><title>Eternal</title></head>
<body>
<h1>/eternal di Penny</h1>
<p>PHP berhasil dieksekusi. Waktu server: <?php echo date('Y-m-d H:i:s'); ?></p>
<p>Hostname: <?php echo gethostname(); ?></p>
</body>
</html>
PHP

sed -i "s|^listen = .*|listen = 127.0.0.1:9000|" /etc/php85/php-fpm.d/www.conf
php-fpm85

cat > /etc/apache2/conf.d/proxy-vault.conf << 'CONF'
<VirtualHost *:80>
    ServerName www.K50.com

    <Proxy balancer://vaultcluster>
        BalancerMember http://192.236.0.26:80
        BalancerMember http://192.236.0.27:80
    </Proxy>

    ProxyRequests Off
    ProxyPreserveHost On

    ProxyPass /admin !
    ProxyPass /eternal !

    ProxyPass "/" "balancer://vaultcluster/"
    ProxyPassReverse "/" "balancer://vaultcluster/"

    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

    <Directory "/var/www/localhost/htdocs/admin">
        AuthType Basic
        AuthName "Restricted Area - The Mesh"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    Alias /eternal /var/www/eternal
    <Directory "/var/www/eternal">
        Options +Indexes
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
    </Directory>
    <FilesMatch "\.php$">
        SetHandler "proxy:fcgi://127.0.0.1:9000"
    </FilesMatch>
</VirtualHost>

<VirtualHost *:80>
    ServerName penny.K50.com
    ServerAlias 192.236.0.38
    Redirect permanent "/" "http://www.K50.com/"
</VirtualHost>
CONF

httpd -t
killall httpd 2>/dev/null || true
sleep 1
httpd -k start
EOF
chmod +x /root/soal15-penny-eternal.sh
sh /root/soal15-penny-eternal.sh