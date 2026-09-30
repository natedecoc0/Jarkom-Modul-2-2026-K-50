cat > /root/soal13-penny-canonical.sh << 'EOF'
#!/bin/sh
set -e

# Semua config soal 11 (proxy vault) dan soal 12 (basic auth /admin) dipindah
# ke dalam VirtualHost ServerName www.K50.com, supaya bisa dibedakan dari
# akses lewat penny.K50.com atau IP-nya langsung.
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

    ProxyPass "/" "balancer://vaultcluster/"
    ProxyPassReverse "/" "balancer://vaultcluster/"

    RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

    <Directory "/var/www/localhost/htdocs/admin">
        AuthType Basic
        AuthName "Restricted Area - The Mesh"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>
</VirtualHost>

# Akses pakai nama asli penny atau IP-nya langsung dipaksa pindah permanen (301)
# ke nama kanonik www.K50.com.
<VirtualHost *:80>
    ServerName penny.K50.com
    ServerAlias 192.236.0.38
    Redirect permanent "/" "http://www.K50.com/"
</VirtualHost>
CONF

httpd -t
echo "===== config OK ====="
httpd -k graceful
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal13-penny-canonical.sh
sh /root/soal13-penny-canonical.sh