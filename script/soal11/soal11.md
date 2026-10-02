### Soal 11: Konfigurasi Reverse Proxy (Apache & Nginx) dengan Header Forwarding
> Konfigurasikan Penny (menggunakan Apache) sebagai reverse proxy yang mengarah ke semua node di area vault (Obladi & Desmond). Sementara itu, konfigurasikan Abbey (menggunakan Nginx) sebagai reverse proxy menuju area core (Oblada & Molly). Pastikan kedua gerbang ini meneruskan identitas asli pengunjung ke server backend dengan melakukan forwarding header Host dan X-Real-IP. Buktikan bahwa Penny dan Abbey berhasil mendistribusikan lalu lintas dengan tepat.

Penny (Apache) jadi reverse proxy ke area vault (obladi & desmond), Abbey (Nginx) jadi reverse proxy ke area core (oblada & molly). Proxy diarahkan langsung ke IP backend, bukan lewat vault.K50.com/core.K50.com (yang sudah round-robin dari soal 7), supaya tidak ada dua lapis load balancing yang saling tumpang tindih dan susah dibuktikan. Load balancing dibuat lewat dua anggota backend di tiap gerbang (BalancerMember di Apache, upstream di Nginx) supaya syarat "mengarah ke semua node" terpenuhi, bukan cuma satu. Forwarding Host dan X-Real-IP ditambahkan eksplisit di kedua config karena default-nya backend hanya melihat IP proxy, bukan identitas pengunjung asli.

#### Konfigurasi Penny (Apache → area vault)

```bash
cat > /root/soal11-penny-proxy.sh << 'EOF'
#!/bin/sh
set -e

# Alpine memisahkan modul proxy Apache ke paket sendiri (beda dari Debian yang satu paket besar).
# apache2-utils disiapkan sekarang: isinya htpasswd (soal 12) dan ab (soal 16).
apk add --no-cache apache2 apache2-proxy apache2-utils

# proxy + proxy_http        = inti reverse proxy
# proxy_balancer + lbmethod_byrequests + slotmem_shm = wajib buat BalancerMember
# headers                   = buat RequestHeader set X-Real-IP
# rewrite, auth_basic, authn_*, authz_* = disiapkan buat soal 12 & 13
sed -i \
  -e 's/^#LoadModule proxy_module/LoadModule proxy_module/' \
  -e 's/^#LoadModule proxy_http_module/LoadModule proxy_http_module/' \
  -e 's/^#LoadModule proxy_balancer_module/LoadModule proxy_balancer_module/' \
  -e 's/^#LoadModule lbmethod_byrequests_module/LoadModule lbmethod_byrequests_module/' \
  -e 's/^#LoadModule slotmem_shm_module/LoadModule slotmem_shm_module/' \
  -e 's/^#LoadModule headers_module/LoadModule headers_module/' \
  -e 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' \
  -e 's/^#LoadModule auth_basic_module/LoadModule auth_basic_module/' \
  -e 's/^#LoadModule authn_file_module/LoadModule authn_file_module/' \
  -e 's/^#LoadModule authn_core_module/LoadModule authn_core_module/' \
  -e 's/^#LoadModule authz_user_module/LoadModule authz_user_module/' \
  -e 's/^#LoadModule authz_core_module/LoadModule authz_core_module/' \
  /etc/apache2/httpd.conf

grep -q "^ServerName" /etc/apache2/httpd.conf || echo "ServerName penny.K50.com" >> /etc/apache2/httpd.conf

cat > /etc/apache2/conf.d/proxy-vault.conf << 'CONF'
# Dua BalancerMember = syarat soal "proxy ke SEMUA node area vault".
<Proxy balancer://vaultcluster>
    BalancerMember http://192.236.0.26:80
    BalancerMember http://192.236.0.27:80
</Proxy>

# ProxyRequests Off wajib: kalau On, apache jadi forward proxy, bukan reverse proxy.
ProxyRequests Off

# Jawab syarat forwarding Host: backend lihat Host asli, bukan IP backend sendiri.
ProxyPreserveHost On

ProxyPass "/" "balancer://vaultcluster/"
ProxyPassReverse "/" "balancer://vaultcluster/"

# Jawab syarat forwarding X-Real-IP. REMOTE_ADDR = IP client yang connect ke penny.
RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"
CONF

httpd -t
echo "===== config OK ====="

mkdir -p /run/apache2
httpd
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal11-penny-proxy.sh
sh /root/soal11-penny-proxy.sh
```

```
Syntax OK
===== config OK =====
===== status service =====
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
```

#### Buktikan Penny mendistribusikan trafik ke obladi & desmond (dari alpha)

```bash
for i in 1 2 3 4; do curl -s http://penny.K50.com/arsip/laporan.txt; done
```

```
laporan dari obladi
laporan dari desmond
laporan dari obladi
laporan dari desmond
```

Hasil bergantian `laporan dari obladi` dan `laporan dari desmond`, artinya kedua BalancerMember sama-sama dipakai.

#### Konfigurasi Abbey (Nginx → area core)

```bash
cat > /root/soal11-abbey-proxy.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache nginx curl

# Default.conf dihapus, soalnya biasa punya "listen 80 default_server" yang nabrak
# sama server block baru kita.
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/proxy-core.conf << 'CONF'
# Dua server di upstream = versi Nginx dari BalancerMember.
upstream corecluster {
    server 192.236.0.28:80;
    server 192.236.0.29:80;
}

log_format proxy_access '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         'real_ip=$http_x_real_ip fwd=$http_x_forwarded_for';

server {
    listen 80;
    server_name abbey.K50.com;

    access_log /var/log/nginx/abbey_access.log proxy_access;

    location / {
        proxy_pass http://corecluster;
        # Jawab syarat forwarding Host.
        proxy_set_header Host $host;
        # Jawab syarat forwarding X-Real-IP.
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
CONF

nginx -t
echo "===== config OK ====="

mkdir -p /run/nginx
nginx
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal11-abbey-proxy.sh
sh /root/soal11-abbey-proxy.sh
```

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
===== config OK =====
===== status service =====
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
```

#### Buktikan Abbey mendistribusikan trafik ke oblada & molly (dari alpha)

```bash
for i in 1 2 3 4; do curl -s http://abbey.K50.com/ | grep "Dilayani"; done
```

```
Dilayani oleh: oblada
Dilayani oleh: molly
Dilayani oleh: oblada
Dilayani oleh: molly
```

Hasil bergantian `Dilayani oleh: molly` dan `Dilayani oleh: oblada`, artinya kedua anggota upstream sama-sama dipakai.

---