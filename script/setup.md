# Setup Konfigurasi Awal — Baseline Soal 1-10
### Shadow Net Operation — Kelompok K-50

Dijalankan sebelum demo live soal 11-18. Urutan eksekusi: **prab → tedd → alpha → obladi → desmond → oblada → molly → abbey → penny**.

---

## 1. Prab (DNS Master)

```bash
cat > /root/setup-prab.sh << 'EOF'
#!/bin/sh
set -e

echo "prab" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.18    prab.K50.com prab
EOT
hostname -F /etc/hostname

apk add --no-cache bind bind-tools curl

mkdir -p /var/bind/pri /var/bind/sec

cat > /etc/bind/named.conf << 'CONF'
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";

    listen-on port 53 { any; };
    listen-on-v6 { none; };

    allow-query { any; };
    recursion yes;
    allow-recursion { 127.0.0.1; 192.236.0.0/26; };

    forwarders { 192.168.122.1; };
    forward first;
    dnssec-validation no;

    notify yes;
    allow-transfer { 192.236.0.19; };
};

zone "K50.com" IN {
    type master;
    file "pri/K50.com.zone";
    notify yes;
    also-notify { 192.236.0.19; };
    allow-transfer { 192.236.0.19; };
};

zone "0.236.192.in-addr.arpa" IN {
    type master;
    file "pri/0.236.192.in-addr.arpa.zone";
    notify yes;
    also-notify { 192.236.0.19; };
    allow-transfer { 192.236.0.19; };
};
CONF

cat > /var/bind/pri/K50.com.zone << 'ZONE'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100201      ; Serial
                        3600
                        900
                        1209600
                        300 )

@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.
@       IN      A       192.236.0.38

prab    IN      A       192.236.0.18
tedd    IN      A       192.236.0.19
rootkit IN      A       192.236.0.1

alpha   IN      A       192.236.0.2
beta    IN      A       192.236.0.3
gamma   IN      A       192.236.0.4
delta   IN      A       192.236.0.10
epsilon IN      A       192.236.0.11

abbey   IN      A       192.236.0.34
penny   IN      A       192.236.0.38

obladi  IN      A       192.236.0.26
desmond IN      A       192.236.0.27
oblada  IN      A       192.236.0.28
molly   IN      A       192.236.0.29

vault   IN      A       192.236.0.26
vault   IN      A       192.236.0.27
core    IN      A       192.236.0.28
core    IN      A       192.236.0.29

www     IN      CNAME   penny.K50.com.
static  IN      CNAME   abbey.K50.com.
ZONE

cat > /var/bind/pri/0.236.192.in-addr.arpa.zone << 'ZONE'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100201
                        3600
                        900
                        1209600
                        300 )

@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.

34      IN      PTR     abbey.K50.com.
38      IN      PTR     penny.K50.com.
26      IN      PTR     obladi.K50.com.
27      IN      PTR     desmond.K50.com.
28      IN      PTR     oblada.K50.com.
29      IN      PTR     molly.K50.com.
ZONE

chown -R named:named /var/bind/pri /var/bind/sec
chmod 644 /var/bind/pri/K50.com.zone /var/bind/pri/0.236.192.in-addr.arpa.zone

named-checkconf /etc/bind/named.conf && echo "named.conf OK"
named-checkzone K50.com /var/bind/pri/K50.com.zone
named-checkzone 0.236.192.in-addr.arpa /var/bind/pri/0.236.192.in-addr.arpa.zone

mkdir -p /var/run/named
chown named:named /var/run/named
pkill named 2>/dev/null || true
sleep 1
named -u named -c /etc/bind/named.conf
sleep 2

echo "=== VERIFIKASI PRAB ==="
ps | grep [n]amed
netstat -ulnp | grep :53
dig @127.0.0.1 K50.com A +noall +answer
dig @127.0.0.1 K50.com SOA +short
EOF
chmod +x /root/setup-prab.sh
sh /root/setup-prab.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI PRAB ===
 1234 root      0:00 named -u named -c /etc/bind/named.conf
udp        0      0 0.0.0.0:53              0.0.0.0:*
K50.com.                3600    IN      A       192.236.0.38
2026100201
```

---

## 2. Tedd (DNS Slave)

```bash
cat > /root/setup-tedd.sh << 'EOF'
#!/bin/sh
set -e

echo "tedd" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.19    tedd.K50.com tedd
EOT
hostname -F /etc/hostname

apk add --no-cache bind bind-tools curl

mkdir -p /var/bind/pri /var/bind/sec

cat > /etc/bind/named.conf << 'CONF'
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";

    listen-on port 53 { any; };
    listen-on-v6 { none; };

    allow-query { any; };
    recursion yes;
    allow-recursion { 127.0.0.1; 192.236.0.0/26; };

    forwarders { 192.168.122.1; };
    forward first;
    dnssec-validation no;

    masterfile-format text;
    allow-transfer { none; };
};

zone "K50.com" IN {
    type secondary;
    file "sec/K50.com.zone";
    primaries { 192.236.0.18; };
    allow-transfer { none; };
};

zone "0.236.192.in-addr.arpa" IN {
    type secondary;
    file "sec/0.236.192.in-addr.arpa.zone";
    primaries { 192.236.0.18; };
    allow-transfer { none; };
};
CONF

chown -R named:named /var/bind/pri /var/bind/sec
named-checkconf /etc/bind/named.conf && echo "named.conf OK"

mkdir -p /var/run/named
chown named:named /var/run/named
pkill named 2>/dev/null || true
sleep 1
named -u named -c /etc/bind/named.conf
sleep 5

echo "=== VERIFIKASI TEDD ==="
ps | grep [n]amed
ls -l /var/bind/sec/
dig @127.0.0.1 K50.com SOA +short
EOF
chmod +x /root/setup-tedd.sh
sh /root/setup-tedd.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI TEDD ===
 1234 root      0:00 named -u named -c /etc/bind/named.conf
-rw-r--r--    1 named    named    [size]  K50.com.zone
-rw-r--r--    1 named    named    [size]  0.236.192.in-addr.arpa.zone
2026100201
```
Serial harus sama persis dengan serial di prab (2026100201). Kalau file belum muncul di `/var/bind/sec/` atau serial beda, zone transfer belum jalan.

---

## 3. Alpha (Client Resolver)

```bash
cat > /root/setup-alpha.sh << 'EOF'
#!/bin/sh
set -e

echo "alpha" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.2     alpha.K50.com alpha
EOT
hostname -F /etc/hostname

sed -i '/resolv.conf/d' /etc/network/interfaces
cat >> /etc/network/interfaces << 'EOT'
    up printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf
EOT
printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf

apk add --no-cache bind-tools curl apache2-utils

echo "=== VERIFIKASI ALPHA ==="
cat /etc/resolv.conf
EOF
chmod +x /root/setup-alpha.sh
sh /root/setup-alpha.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI ALPHA ===
nameserver 192.236.0.18
nameserver 192.236.0.19
nameserver 192.168.122.1
```

---

## 4. Obladi (Apache Static — Area Vault)

```bash
cat > /root/setup-obladi.sh << 'EOF'
#!/bin/sh
set -e

echo "obladi" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.26    obladi.K50.com obladi
EOT
hostname -F /etc/hostname

apk add --no-cache apache2 curl

mkdir -p /var/www/localhost/htdocs/arsip
echo "laporan dari obladi" > /var/www/localhost/htdocs/arsip/laporan.txt
echo "catatan dari obladi" > /var/www/localhost/htdocs/arsip/catatan.txt
echo "data dari obladi" > /var/www/localhost/htdocs/arsip/data.txt

cat > /etc/apache2/conf.d/arsip.conf << 'CONF'
<Directory "/var/www/localhost/htdocs/arsip">
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
CONF

grep -q "^ServerName" /etc/apache2/httpd.conf || echo "ServerName localhost" >> /etc/apache2/httpd.conf

httpd -t
mkdir -p /run/apache2
pkill httpd 2>/dev/null || true
sleep 1
httpd
sleep 2

echo "=== VERIFIKASI OBLADI ==="
ps | grep [h]ttpd
netstat -tlnp | grep :80
curl -s localhost/arsip/laporan.txt
EOF
chmod +x /root/setup-obladi.sh
sh /root/setup-obladi.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI OBLADI ===
 1234 root      0:00 httpd -k start
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
laporan dari obladi
```

---

## 5. Desmond (Apache Static — Area Vault)

```bash
cat > /root/setup-desmond.sh << 'EOF'
#!/bin/sh
set -e

echo "desmond" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.27    desmond.K50.com desmond
EOT
hostname -F /etc/hostname

apk add --no-cache apache2 curl

mkdir -p /var/www/localhost/htdocs/arsip
echo "laporan dari desmond" > /var/www/localhost/htdocs/arsip/laporan.txt
echo "catatan dari desmond" > /var/www/localhost/htdocs/arsip/catatan.txt
echo "data dari desmond" > /var/www/localhost/htdocs/arsip/data.txt

cat > /etc/apache2/conf.d/arsip.conf << 'CONF'
<Directory "/var/www/localhost/htdocs/arsip">
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
CONF

grep -q "^ServerName" /etc/apache2/httpd.conf || echo "ServerName localhost" >> /etc/apache2/httpd.conf

httpd -t
mkdir -p /run/apache2
pkill httpd 2>/dev/null || true
sleep 1
httpd
sleep 2

echo "=== VERIFIKASI DESMOND ==="
ps | grep [h]ttpd
netstat -tlnp | grep :80
curl -s localhost/arsip/laporan.txt
EOF
chmod +x /root/setup-desmond.sh
sh /root/setup-desmond.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI DESMOND ===
 1234 root      0:00 httpd -k start
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
laporan dari desmond
```

---

## 6. Oblada (Nginx + PHP-FPM — Area Core)

```bash
cat > /root/setup-oblada.sh << 'EOF'
#!/bin/sh
set -e

echo "oblada" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.28    oblada.K50.com oblada
EOT
hostname -F /etc/hostname

apk update
apk add --no-cache nginx php85 php85-fpm curl

mkdir -p /var/www/html
cat > /var/www/html/index.php << 'PHP'
<!DOCTYPE html>
<html>
<head><title>Beranda</title></head>
<body>
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/profil">Halaman Profil</a>
</body>
</html>
PHP

cat > /var/www/html/profil.php << 'PHP'
<!DOCTYPE html>
<html>
<head><title>Profil</title></head>
<body>
<h1>Profil</h1>
<p>Kelompok: K50</p>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/">Kembali ke Beranda</a>
</body>
</html>
PHP

chmod -R 755 /var/www/html
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/core.conf << 'CONF'
server {
    listen 80 default_server;
    server_name core.K50.com oblada.K50.com molly.K50.com;

    root /var/www/html;
    index index.php;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
CONF

nginx -t
pkill -f php-fpm85 2>/dev/null || true
pkill nginx 2>/dev/null || true
sleep 1
php-fpm85
mkdir -p /run/nginx
nginx
sleep 2

echo "=== VERIFIKASI OBLADA ==="
ps | grep -E "[p]hp-fpm|[n]ginx"
netstat -tlnp | grep -E ":80|:9000"
curl -s localhost/
curl -s localhost/profil
EOF
chmod +x /root/setup-oblada.sh
sh /root/setup-oblada.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI OBLADA ===
 1234 root      0:00 php-fpm85
 1235 root      0:00 nginx: master process
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: oblada</p>
<h1>Profil</h1>
<p>Dilayani oleh: oblada</p>
```
`gethostname()` harus muncul "oblada" dengan benar, bukan kosong/error — itu bukti PHP-FPM beneran nyambung lewat `mod_proxy_fcgi`, bukan nginx nyajiin file .php mentah sebagai teks.

---

## 7. Molly (Nginx + PHP-FPM — Area Core)

```bash
cat > /root/setup-molly.sh << 'EOF'
#!/bin/sh
set -e

echo "molly" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.29    molly.K50.com molly
EOT
hostname -F /etc/hostname

apk update
apk add --no-cache nginx php85 php85-fpm curl

mkdir -p /var/www/html
cat > /var/www/html/index.php << 'PHP'
<!DOCTYPE html>
<html>
<head><title>Beranda</title></head>
<body>
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/profil">Halaman Profil</a>
</body>
</html>
PHP

cat > /var/www/html/profil.php << 'PHP'
<!DOCTYPE html>
<html>
<head><title>Profil</title></head>
<body>
<h1>Profil</h1>
<p>Kelompok: K50</p>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/">Kembali ke Beranda</a>
</body>
</html>
PHP

chmod -R 755 /var/www/html
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/core.conf << 'CONF'
server {
    listen 80 default_server;
    server_name core.K50.com oblada.K50.com molly.K50.com;

    root /var/www/html;
    index index.php;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
CONF

nginx -t
pkill -f php-fpm85 2>/dev/null || true
pkill nginx 2>/dev/null || true
sleep 1
php-fpm85
mkdir -p /run/nginx
nginx
sleep 2

echo "=== VERIFIKASI MOLLY ==="
ps | grep -E "[p]hp-fpm|[n]ginx"
netstat -tlnp | grep -E ":80|:9000"
curl -s localhost/
curl -s localhost/profil
EOF
chmod +x /root/setup-molly.sh
sh /root/setup-molly.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI MOLLY ===
 1234 root      0:00 php-fpm85
 1235 root      0:00 nginx: master process
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: molly</p>
<h1>Profil</h1>
<p>Dilayani oleh: molly</p>
```

---

## 8. Abbey (Hostname saja — Reverse Proxy dibangun live di soal 11)

```bash
cat > /root/setup-abbey.sh << 'EOF'
#!/bin/sh
set -e

echo "abbey" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.34    abbey.K50.com abbey
EOT
hostname -F /etc/hostname

apk add --no-cache curl bind-tools

echo "=== VERIFIKASI ABBEY ==="
hostname
cat /etc/hosts
EOF
chmod +x /root/setup-abbey.sh
sh /root/setup-abbey.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI ABBEY ===
abbey
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.34    abbey.K50.com abbey
```
Belum ada service apapun listen di port 80 — itu baru dibangun pas demo soal 11.

---

## 9. Penny (Hostname saja — Reverse Proxy dibangun live di soal 11)

```bash
cat > /root/setup-penny.sh << 'EOF'
#!/bin/sh
set -e

echo "penny" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.38    penny.K50.com penny
EOT
hostname -F /etc/hostname

apk add --no-cache curl bind-tools

echo "=== VERIFIKASI PENNY ==="
hostname
cat /etc/hosts
EOF
chmod +x /root/setup-penny.sh
sh /root/setup-penny.sh
```

**Ekspektasi output kalau benar:**
```
=== VERIFIKASI PENNY ===
penny
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
192.236.0.38    penny.K50.com penny
```

---

## Catatan

Kalau salah satu output beda dari ekspektasi (port gak listen, `gethostname()` kosong/error di oblada/molly, serial tedd gak sama prab), itu sinyal paling cepat buat tau node mana yang perlu di-retry sebelum mulai demo soal 11.