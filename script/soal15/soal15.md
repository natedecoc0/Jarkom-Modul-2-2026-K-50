## Soal 15

> Rootkit menginstruksikan pembuatan jalur proxy khusus yang berdiri sendiri. Pada penny buat reverse proxy untuk path /eternal yang menyajikan directory /var/www/eternal, dan pastikan path ini dapat mengeksekusi (rendering) file php. Pada abbey, buat jalur /orion yang menyajikan directory /var/www/orion, secara murni statis tanpa perlu rendering php.

### Penjelasan

`/eternal` dan `/orion` adalah path lokal yang berdiri sendiri di Penny dan Abbey, bukan diteruskan ke backend vault/core manapun. Keduanya dikecualikan dari `ProxyPass "/"` (lewat `ProxyPass /eternal !` di Penny, dan `location /orion` terpisah di Abbey) supaya dilayani langsung oleh reverse proxy itu sendiri, sama seperti pola `/admin` di soal 12.

Bedanya, `/eternal` harus bisa eksekusi PHP. Karena Penny adalah Apache (bukan Nginx seperti oblada/molly), PHP dijalankan lewat **PHP-FPM** yang diproxy ke Apache lewat `mod_proxy_fcgi` (`SetHandler "proxy:fcgi://127.0.0.1:9000"` di `<FilesMatch \.php$>`). Pendekatan ini dipilih ketimbang mod_php (modul PHP yang nempel langsung di proses Apache) karena PHP-nya jalan di proses terpisah, jadi lebih stabil dan konsisten dengan pola FastCGI yang sudah dipakai di soal 9-10.

`/orion` di Abbey murni statis, cukup `alias` langsung ke direktori tanpa keterlibatan PHP sama sekali, karena Abbey tidak butuh dan tidak punya PHP terinstal.

### Konfigurasi Penny (`/eternal`)

```bash
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
```

### Konfigurasi Abbey (`/orion`)

```bash
cat > /root/soal15-abbey-orion.sh << 'EOF'
#!/bin/sh
set -e

mkdir -p /var/www/orion
cat > /var/www/orion/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body>
<h1>/orion di Abbey</h1>
<p>Ini halaman statis murni, tidak ada rendering PHP.</p>
</body>
</html>
HTML

cat > /etc/nginx/http.d/proxy-core.conf << 'CONF'
upstream corecluster {
    server 192.236.0.28:80;
    server 192.236.0.29:80;
}

log_format proxy_access '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         'real_ip=$http_x_real_ip fwd=$http_x_forwarded_for';

server {
    listen 80 default_server;
    server_name static.K50.com;

    access_log /var/log/nginx/abbey_access.log proxy_access;

    location /orion {
        alias /var/www/orion/;
        autoindex on;
    }

    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name abbey.K50.com 192.236.0.34;
    return 302 http://static.K50.com$request_uri;
}
CONF

nginx -t
nginx -s reload
EOF
chmod +x /root/soal15-abbey-orion.sh
sh /root/soal15-abbey-orion.sh
```

### Verifikasi

```bash
curl -s http://www.K50.com/eternal/
curl -s http://static.K50.com/orion/
curl -s -o /dev/null -w "%{http_code}\n" http://www.K50.com/admin/
curl -s http://www.K50.com/arsip/laporan.txt
```

Hasil: `/eternal` menampilkan halaman dengan timestamp dan hostname yang ter-render server-side (bukti PHP jalan), `/orion` menampilkan halaman statis, `/admin` tetap 401, dan `/arsip/laporan.txt` tetap terbaca normal.