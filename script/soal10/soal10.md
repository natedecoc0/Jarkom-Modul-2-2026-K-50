### Soal 10: Konfigurasi Web Server Dinamis (Nginx & PHP-FPM) dengan URL Rewrite
> Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rewrite pada server sehingga akses ke /profil dapat berfungsi dengan URL bersih (tanpa akhiran .php). Akses pengujian wajib dilakukan melalui hostname.

Nginx dan PHP-FPM dipasang di oblada dan molly (area core). Aplikasi punya halaman beranda dan profil, dan /profil bisa diakses tanpa .php lewat rewrite. Pengujian dilakukan lewat hostname.

#### Perbarui indeks paket dan install Nginx serta PHP-FPM

```bash
apk update
PHPV=php85
apk add nginx $PHPV $PHPV-fpm
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/ad150797-85e7-4e0e-8d21-a7e2a13a8fea" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/611477a8-ee45-4719-81d4-e3c3096051b1" />

#### Buat aplikasi sederhana

```bash
mkdir -p /var/www/html

cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Beranda</title></head>
<body>
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/profil">Halaman Profil</a>
</body>
</html>
EOF

cat > /var/www/html/profil.php << 'EOF'
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
EOF

chmod -R 755 /var/www/html
ls -l /var/www/html
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/4b00f56e-1e00-4e3c-a40d-7eb25036e21a" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/09f85556-93b1-4a83-9930-4140a5d02b02" />

#### Konfigurasi Nginx

```bash
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/core.conf << 'EOF'
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
EOF

nginx -t
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/25a59903-ac95-4209-aae2-f85d74257768" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/98892a88-c293-4fc0-808c-3b86f04c532e" />

#### Jalankan PHP-FPM dan Nginx

```bash
grep -E "^listen|^user" /etc/php85/php-fpm.d/www.conf
php-fpm85
mkdir -p /run/nginx
nginx
sleep 2
ps | grep -E "[p]hp-fpm|[n]ginx"
netstat -tlnp | grep -E ":80|:9000"
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/7c0f3291-c409-4613-a823-e8b524adc51d" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3f821584-478b-419e-902f-7e47ef5c381d" />

#### Uji beranda per hostname (alpha)

```bash
apk add curl
curl -s http://oblada.K50.com/
curl -s http://molly.K50.com/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/b08c30dc-1cbd-4a17-963e-ca300c339a40" />

#### Uji URL bersih /profil (alpha)

```bash
curl -s http://oblada.K50.com/profil
curl -s http://molly.K50.com/profil
curl -s -o /dev/null -w "%{http_code}\n" http://core.K50.com/profil
curl -s -o /dev/null -w "%{http_code}\n" http://core.K50.com/tidakada
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5bb078b7-d2a7-4fe6-949c-10f2d98df0d7" />

#### Uji lewat hostname core (round-robin)

```bash
for i in 1 2 3 4; do curl -s http://core.K50.com/ | grep "Dilayani"; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/92aa68e1-bdbf-4390-93fc-bc72fd355ad3" />

#### Uji dari klien lain (delta)

```bash
apk add curl
curl -s http://core.K50.com/
curl -s http://core.K50.com/profil
curl -s -I http://molly.K50.com/profil
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/80013c89-ea8a-4d42-9d73-7412a88cfb66" />