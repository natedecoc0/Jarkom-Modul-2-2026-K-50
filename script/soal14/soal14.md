### Soal 14: Access Log Mencatat IP Asli Pengunjung
> Di dalam The Mesh, rekam jejak tidak boleh dipalsukan oleh sistem. Pastikan access log pada setiap server web di area vault maupun area core mencatat alamat IP asli milik client (pengunjung) yang diteruskan oleh gerbang, dan bukan mencatat IP dari Penny ataupun Abbey.

Semua traffic ke obladi/desmond/oblada/molly lewat Penny/Abbey, jadi `$remote_addr`/`%h` di access log backend bakal selalu nunjuk IP Penny (`192.236.0.38`) atau Abbey (`192.236.0.34`), karena merekalah yang beneran buka koneksi TCP ke backend, bukan si pengunjung asli. Soal 11 udah nyiapin fondasinya: Penny dan Abbey udah forward header `X-Real-IP` berisi IP pengunjung asli. Tinggal ganti format access log di backend supaya baca dari header itu (`%{X-Real-IP}i` di Apache, `$http_x_real_ip` di Nginx), bukan dari `%h`/`$remote_addr` bawaan. Log ditulis ke file terpisah (`access_real.log`) biar gampang dibuktikan isinya tanpa ngoprek log default.

#### Konfigurasi obladi & desmond (Apache)

```bash
cat > /root/soal14-vault-reallog.sh << 'EOF'
#!/bin/sh
set -e

# X-Real-IP diambil dari header yang diteruskan Penny (soal 11), bukan %h
# yang isinya IP Penny sendiri karena dia yang connect langsung ke sini.
cat > /etc/apache2/conf.d/reallog.conf << 'CONF'
LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %b" realip
CustomLog /var/log/apache2/access_real.log realip
CONF

httpd -t
echo "===== config OK ====="
httpd -k graceful
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal14-vault-reallog.sh
sh /root/soal14-vault-reallog.sh
```

#### Konfigurasi oblada & molly (Nginx)

```bash
cat > /root/soal14-core-reallog.sh << 'EOF'
#!/bin/sh
set -e

cat > /etc/nginx/http.d/core.conf << 'CONF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent';

server {
    listen 80 default_server;
    server_name core.K50.com oblada.K50.com molly.K50.com;

    root /var/www/html;
    index index.php;

    access_log /var/log/nginx/access_real.log realip;

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
echo "===== config OK ====="
nginx -s reload
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal14-core-reallog.sh
sh /root/soal14-core-reallog.sh
```

#### Buktikan access log mencatat IP asli (dari alpha)

```bash
for i in 1 2 3 4; do curl -s http://www.K50.com/arsip/laporan.txt > /dev/null; done
for i in 1 2 3 4; do curl -s http://static.K50.com/ > /dev/null; done
```

Cek log di tiap backend:

```bash
tail -5 /var/log/apache2/access_real.log    # obladi, desmond
tail -5 /var/log/nginx/access_real.log      # oblada, molly
```

Hasil terbukti: keempat backend (obladi, desmond, oblada, molly) mencatat `192.236.0.2` (IP alpha, pengunjung asli) dengan status `200` di `access_real.log`-nya masing-masing, bukan IP Penny (`192.236.0.38`) ataupun Abbey (`192.236.0.34`).

---