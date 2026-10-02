### Soal 13: Canonical Redirect (301 & 302)
> Setiap entitas dari luar harus memanggil gerbang dengan nama kanoniknya. Jika ada yang mencoba mengakses IP penny dan domain penny.xxx.com, paksa sistem untuk melakukan redirect secara permanen (status code 301) menuju www.xxx.com. Sebaliknya, jika ada yang mengakses IP abbey dan domain abbey.xxx.com, lakukan redirect sementara (status code 302) menuju static.xxx.com.

Sampai soal 12, Penny dan Abbey belum punya VirtualHost, jadi semua Host header (www.K50.com, penny.K50.com, atau IP langsung) dilayani sama persis oleh satu blok config. Supaya bisa dibedakan perlakuannya (www jalan normal, penny/IP di-redirect), dipecah jadi name-based virtual hosting: satu VirtualHost untuk nama kanonik (isinya proxy+auth dari soal 11-12), satu VirtualHost lagi untuk nama asli plus IP-nya yang isinya cuma redirect.

Untuk IP, cukup pakai `ServerAlias <IP>` di Apache atau tambahkan IP langsung di `server_name` Nginx, karena kalau klien akses pakai IP di URL, header Host yang dikirim curl ya literal IP itu sendiri, jadi bisa dicocokkan sama seperti nama domain biasa. Urutan VirtualHost penting: blok kanonik (www / static) diletakkan lebih dulu (atau ditandai `default_server` di Nginx) supaya jadi default kalau Host header gak cocok ke manapun, biar akses "normal" tetap yang utama.

#### Konfigurasi Penny (redirect 301 ke www.K50.com)

```bash
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
```

```
Syntax OK
===== config OK =====
===== status service =====
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
```

#### Konfigurasi Abbey (redirect 302 ke static.K50.com)

```bash
cat > /root/soal13-abbey-canonical.sh << 'EOF'
#!/bin/sh
set -e

cat > /etc/nginx/http.d/proxy-core.conf << 'CONF'
upstream corecluster {
    server 192.236.0.28:80;
    server 192.236.0.29:80;
}

log_format proxy_access '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         'real_ip=$http_x_real_ip fwd=$http_x_forwarded_for';

# default_server: kalau Host header tidak cocok manapun, ini yang dipakai.
server {
    listen 80 default_server;
    server_name static.K50.com;

    access_log /var/log/nginx/abbey_access.log proxy_access;

    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Akses pakai nama asli abbey atau IP-nya langsung dipaksa pindah sementara (302)
# ke nama kanonik static.K50.com.
server {
    listen 80;
    server_name abbey.K50.com 192.236.0.34;
    return 302 http://static.K50.com$request_uri;
}
CONF

nginx -t
echo "===== config OK ====="
nginx -s reload
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal13-abbey-canonical.sh
sh /root/soal13-abbey-canonical.sh
```

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
===== config OK =====
===== status service =====
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
```

#### Buktikan redirect bekerja (dari alpha)

```bash
echo "===== www.K50.com (harus normal, load balancing tetap jalan) ====="
curl -s http://www.K50.com/arsip/laporan.txt

echo "===== penny.K50.com (harus 301 ke www.K50.com) ====="
curl -s -I http://penny.K50.com/

echo "===== IP penny langsung (harus 301 juga) ====="
curl -s -I http://192.236.0.38/

echo "===== static.K50.com (harus normal, proxy ke core) ====="
curl -s http://static.K50.com/ | grep "Dilayani"

echo "===== abbey.K50.com (harus 302 ke static.K50.com) ====="
curl -s -I http://abbey.K50.com/

echo "===== IP abbey langsung (harus 302 juga) ====="
curl -s -I http://192.236.0.34/
```

```
===== www.K50.com (harus normal, load balancing tetap jalan) =====
laporan dari obladi
===== penny.K50.com (harus 301 ke www.K50.com) =====
HTTP/1.1 301 Moved Permanently
Date: Fri, 02 Oct 2026 14:10:02 GMT
Server: Apache/2.4.65 (Alpine)
Location: http://www.K50.com/
Content-Type: text/html; charset=iso-8859-1

===== IP penny langsung (harus 301 juga) =====
HTTP/1.1 301 Moved Permanently
Date: Fri, 02 Oct 2026 14:10:02 GMT
Server: Apache/2.4.65 (Alpine)
Location: http://www.K50.com/
Content-Type: text/html; charset=iso-8859-1

===== static.K50.com (harus normal, proxy ke core) =====
Dilayani oleh: molly
===== abbey.K50.com (harus 302 ke static.K50.com) =====
HTTP/1.1 302 Found
Date: Fri, 02 Oct 2026 14:10:03 GMT
Server: nginx/1.26.2
Location: http://static.K50.com/

===== IP abbey langsung (harus 302 juga) =====
HTTP/1.1 302 Found
Date: Fri, 02 Oct 2026 14:10:03 GMT
Server: nginx/1.26.2
Location: http://static.K50.com/
```

Hasil terbukti: `www.K50.com` dan `static.K50.com` tetap jalan normal (load balancing tidak terganggu), sementara `penny.K50.com` dan IP `192.236.0.38` sama-sama balas `301 Moved Permanently` dengan `Location: http://www.K50.com/`, dan `abbey.K50.com` beserta IP `192.236.0.34` sama-sama balas `302 Found` dengan `Location: http://static.K50.com/`.

---