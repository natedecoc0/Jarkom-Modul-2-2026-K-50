#!/bin/sh
# =====================================================================
# mesh.sh - Setup Soal 1-10 (The Mesh, zona K50.com)
# Pemakaian: sh mesh.sh <node> [all|1..10|test]
# =====================================================================
NODE="$1"
STEP="${2:-all}"
DOM=K50.com

[ -z "$NODE" ] && { echo "Pemakaian: sh $0 <node> [all|1-10|test]"; exit 1; }

# ---------- Tabel IP per node ----------
MASK=; GW=
case "$NODE" in
  rootkit) IP=192.236.0.1 ;;
  alpha)   IP=192.236.0.2;  MASK=255.255.255.248; GW=192.236.0.1 ;;
  beta)    IP=192.236.0.3;  MASK=255.255.255.248; GW=192.236.0.1 ;;
  gamma)   IP=192.236.0.4;  MASK=255.255.255.248; GW=192.236.0.1 ;;
  delta)   IP=192.236.0.10; MASK=255.255.255.248; GW=192.236.0.9 ;;
  epsilon) IP=192.236.0.11; MASK=255.255.255.248; GW=192.236.0.9 ;;
  prab)    IP=192.236.0.18; MASK=255.255.255.248; GW=192.236.0.17 ;;
  tedd)    IP=192.236.0.19; MASK=255.255.255.248; GW=192.236.0.17 ;;
  obladi)  IP=192.236.0.26; MASK=255.255.255.248; GW=192.236.0.25 ;;
  desmond) IP=192.236.0.27; MASK=255.255.255.248; GW=192.236.0.25 ;;
  oblada)  IP=192.236.0.28; MASK=255.255.255.248; GW=192.236.0.25 ;;
  molly)   IP=192.236.0.29; MASK=255.255.255.248; GW=192.236.0.25 ;;
  abbey)   IP=192.236.0.34; MASK=255.255.255.252; GW=192.236.0.33 ;;
  penny)   IP=192.236.0.38; MASK=255.255.255.252; GW=192.236.0.37 ;;
  *) echo "Node tidak dikenal: $NODE"; exit 1 ;;
esac

# ---------- Helper ----------
start_named() {
  killall named 2>/dev/null
  sleep 1
  mkdir -p /var/run/named
  chown named:named /var/run/named
  named -u named -c /etc/bind/named.conf
  sleep 3
  ps | grep [n]amed
  netstat -ulnp | grep :53
}

reload_named() {
  kill -HUP $(pidof named)
  sleep 3
  dig SOA $DOM @127.0.0.1 +short
}

# zone_write <serial> <level>   level 1=dasar, 2=+semua host, 3=+round-robin & CNAME
zone_write() {
  Z=/var/bind/pri/$DOM.zone
  cat > $Z << 'EOF'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        SERIAL          ; Serial (YYYYMMDDNN)
                        3600            ; Refresh
                        900             ; Retry
                        1209600         ; Expire
                        300 )           ; Negative Cache TTL

; Name Server
@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.

; Apex domain -> penny (Dynamic Proxy)
@       IN      A       192.236.0.38

; Name Server host
prab    IN      A       192.236.0.18
tedd    IN      A       192.236.0.19
EOF
  if [ "$2" -ge 2 ]; then
    cat >> $Z << 'EOF'

; Router
rootkit IN      A       192.236.0.1

; Klien Sayap Kiri
alpha   IN      A       192.236.0.2
beta    IN      A       192.236.0.3
gamma   IN      A       192.236.0.4

; Klien Sayap Kanan
delta   IN      A       192.236.0.10
epsilon IN      A       192.236.0.11

; Proxy
abbey   IN      A       192.236.0.34
penny   IN      A       192.236.0.38

; Area Vault (Apache)
obladi  IN      A       192.236.0.26
desmond IN      A       192.236.0.27

; Area Core (Nginx + PHP)
oblada  IN      A       192.236.0.28
molly   IN      A       192.236.0.29
EOF
  fi
  if [ "$2" -ge 3 ]; then
    cat >> $Z << 'EOF'

; Round-Robin Group (Soal 7)
vault   IN      A       192.236.0.26
vault   IN      A       192.236.0.27
core    IN      A       192.236.0.28
core    IN      A       192.236.0.29

; Alias CNAME (Soal 7)
www     IN      CNAME   penny.K50.com.
static  IN      CNAME   abbey.K50.com.
EOF
  fi
  sed -i "s/SERIAL/$1/" $Z
  chown named:named $Z
  chmod 644 $Z
  named-checkzone $DOM $Z
}

# =====================================================================
# SOAL 1 - IP & Gateway
# =====================================================================
soal1() {
  echo ">>> SOAL 1: IP & Gateway ($NODE)"
  if [ "$NODE" = rootkit ]; then
    cat > /etc/network/interfaces << 'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.236.0.17
    netmask 255.255.255.248
    up ip addr add 192.236.0.25/29 dev eth1
    down ip addr del 192.236.0.25/29 dev eth1 || true

auto eth2
iface eth2 inet static
    address 192.236.0.33
    netmask 255.255.255.252

auto eth3
iface eth3 inet static
    address 192.236.0.37
    netmask 255.255.255.252

auto eth4
iface eth4 inet static
    address 192.236.0.1
    netmask 255.255.255.248

auto eth5
iface eth5 inet static
    address 192.236.0.9
    netmask 255.255.255.248
EOF
  else
    cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $IP
    netmask $MASK
    gateway $GW
EOF
  fi
  rc-service networking restart
}

# =====================================================================
# SOAL 2 - NAT (hanya rootkit)
# =====================================================================
soal2() {
  [ "$NODE" = rootkit ] || return
  echo ">>> SOAL 2: NAT & IP forwarding"
  sysctl -w net.ipv4.ip_forward=1
  grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

  iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

  grep -q "MASQUERADE" /etc/network/interfaces || \
    awk '{print} /^iface eth0 inet dhcp/{print "    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"}' \
      /etc/network/interfaces > /tmp/if.new && cat /tmp/if.new > /etc/network/interfaces
  cat /etc/network/interfaces
}

# =====================================================================
# SOAL 3 - Resolver awal (semua non-router)
# =====================================================================
soal3() {
  [ "$NODE" = rootkit ] && return
  echo ">>> SOAL 3: Resolver awal 192.168.122.1"
  echo "nameserver 192.168.122.1" > /etc/resolv.conf
  grep -q "resolv.conf" /etc/network/interfaces || \
    echo '    up echo "nameserver 192.168.122.1" > /etc/resolv.conf' >> /etc/network/interfaces
  ifdown eth0 && ifup eth0
  cat /etc/resolv.conf
}

# =====================================================================
# SOAL 4 - DNS master-slave + resolver baru
# =====================================================================
dns_master() {
  apk add bind bind-tools
  mkdir -p /var/bind/pri /var/bind/sec
  cat > /etc/bind/named.conf << 'EOF'
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
EOF
  zone_write 2026092901 1
  chown -R named:named /var/bind/pri /var/bind/sec
  named-checkconf /etc/bind/named.conf && echo "named.conf OK"
  start_named
}

dns_slave() {
  apk add bind bind-tools
  mkdir -p /var/bind/pri /var/bind/sec
  cat > /etc/bind/named.conf << 'EOF'
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
EOF
  chown -R named:named /var/bind/pri /var/bind/sec
  named-checkconf /etc/bind/named.conf && echo "named.conf OK"
  start_named
  sleep 3
  ls -l /var/bind/sec/
}

set_resolver_final() {
  sed -i '/resolv.conf/d' /etc/network/interfaces
  cat >> /etc/network/interfaces << 'EOF'
    up printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf
EOF
  printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf
  cat /etc/network/interfaces
  cat /etc/resolv.conf
}

soal4() {
  [ "$NODE" = rootkit ] && return
  echo ">>> SOAL 4: DNS master-slave ($NODE)"
  case "$NODE" in
    prab)        dns_master ;;
    tedd)        dns_slave ;;
    alpha|delta) apk add bind-tools ;;
  esac
  set_resolver_final
}

# =====================================================================
# SOAL 5 - Hostname + A record
# =====================================================================
soal5() {
  echo ">>> SOAL 5: Hostname ($NODE)"
  echo "$NODE" > /etc/hostname
  cat > /etc/hosts << EOF
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
$IP     $NODE.$DOM $NODE
EOF
  hostname -F /etc/hostname
  cat /etc/hostname
  cat /etc/hosts
  hostname
  hostname -f

  if [ "$NODE" = prab ]; then
    zone_write 2026092902 2
    reload_named
  fi
}

# =====================================================================
# SOAL 6 - Zone transfer & SOA
# =====================================================================
soal6() {
  case "$NODE" in
    prab)
      echo ">>> SOAL 6: restart BIND di prab"
      start_named
      dig SOA $DOM @127.0.0.1 +short
      ;;
    tedd)
      echo ">>> SOAL 6: tedd tarik ulang zona dari prab"
      killall named 2>/dev/null
      sleep 1
      rm -f /var/bind/sec/$DOM.zone
      ls -l /var/bind/sec/
      start_named
      sleep 3
      ls -l /var/bind/sec/
      cat /var/bind/sec/$DOM.zone
      echo "--- AXFR dari tedd (harus diizinkan) ---"
      dig AXFR $DOM @192.236.0.18
      ;;
  esac
}

# =====================================================================
# SOAL 7 - Round-robin & CNAME
# =====================================================================
soal7() {
  case "$NODE" in
    prab)
      echo ">>> SOAL 7: zona final (vault, core, www, static)"
      zone_write 2026092903 3
      reload_named
      ;;
    tedd)
      sleep 3
      dig SOA $DOM @127.0.0.1 +short
      grep -E "vault|core|www|static" /var/bind/sec/$DOM.zone
      ;;
  esac
}

# =====================================================================
# SOAL 8 - Reverse DNS
# =====================================================================
soal8() {
  case "$NODE" in
    prab)
      echo ">>> SOAL 8: reverse zone (master)"
      grep -q '0.236.192.in-addr.arpa' /etc/bind/named.conf || cat >> /etc/bind/named.conf << 'EOF'

zone "0.236.192.in-addr.arpa" IN {
    type master;
    file "pri/0.236.192.in-addr.arpa.zone";
    notify yes;
    also-notify { 192.236.0.19; };
    allow-transfer { 192.236.0.19; };
};
EOF
      cat > /var/bind/pri/0.236.192.in-addr.arpa.zone << 'EOF'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026092901      ; Serial (YYYYMMDDNN)
                        3600            ; Refresh
                        900             ; Retry
                        1209600         ; Expire
                        300 )           ; Negative Cache TTL

; Name Server
@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.

; PTR Records (angka = oktet terakhir IP)
34      IN      PTR     abbey.K50.com.
38      IN      PTR     penny.K50.com.
26      IN      PTR     obladi.K50.com.
27      IN      PTR     desmond.K50.com.
28      IN      PTR     oblada.K50.com.
29      IN      PTR     molly.K50.com.
EOF
      chown named:named /var/bind/pri/0.236.192.in-addr.arpa.zone
      chmod 644 /var/bind/pri/0.236.192.in-addr.arpa.zone
      named-checkconf /etc/bind/named.conf && echo "named.conf OK"
      named-checkzone 0.236.192.in-addr.arpa /var/bind/pri/0.236.192.in-addr.arpa.zone
      kill -HUP $(pidof named)
      sleep 3
      dig SOA 0.236.192.in-addr.arpa @127.0.0.1 +short
      ;;
    tedd)
      echo ">>> SOAL 8: reverse zone (slave)"
      grep -q '0.236.192.in-addr.arpa' /etc/bind/named.conf || cat >> /etc/bind/named.conf << 'EOF'

zone "0.236.192.in-addr.arpa" IN {
    type secondary;
    file "sec/0.236.192.in-addr.arpa.zone";
    primaries { 192.236.0.18; };
    allow-transfer { none; };
};
EOF
      named-checkconf /etc/bind/named.conf && echo "named.conf OK"
      kill -HUP $(pidof named)
      sleep 5
      ls -l /var/bind/sec/
      dig SOA 0.236.192.in-addr.arpa @127.0.0.1 +short
      cat /var/bind/sec/0.236.192.in-addr.arpa.zone
      ;;
  esac
}

# =====================================================================
# SOAL 9 - Apache + autoindex (obladi, desmond)
# =====================================================================
soal9() {
  case "$NODE" in obladi|desmond) ;; *) return ;; esac
  echo ">>> SOAL 9: Apache autoindex ($NODE)"
  apk add apache2 curl

  mkdir -p /var/www/localhost/htdocs/arsip
  echo "laporan dari $NODE" > /var/www/localhost/htdocs/arsip/laporan.txt
  echo "catatan dari $NODE" > /var/www/localhost/htdocs/arsip/catatan.txt
  echo "data dari $NODE"    > /var/www/localhost/htdocs/arsip/data.txt
  ls -l /var/www/localhost/htdocs/arsip

  cat > /etc/apache2/conf.d/arsip.conf << 'EOF'
<Directory "/var/www/localhost/htdocs/arsip">
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF

  grep -q "^ServerName" /etc/apache2/httpd.conf || echo "ServerName localhost" >> /etc/apache2/httpd.conf
  httpd -M 2>/dev/null | grep autoindex
  httpd -t

  killall httpd 2>/dev/null
  sleep 1
  mkdir -p /run/apache2
  httpd
  sleep 2
  ps | grep [h]ttpd
  netstat -tlnp | grep :80
}

# =====================================================================
# SOAL 10 - Nginx + PHP-FPM + rewrite (oblada, molly)
# =====================================================================
soal10() {
  case "$NODE" in oblada|molly) ;; *) return ;; esac
  echo ">>> SOAL 10: Nginx + PHP-FPM ($NODE)"
  apk update
  PHPV=php85
  apk add nginx $PHPV $PHPV-fpm

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

  grep -E "^listen|^user" /etc/php85/php-fpm.d/www.conf
  killall php-fpm85 nginx 2>/dev/null
  sleep 1
  php-fpm85
  mkdir -p /run/nginx
  nginx
  sleep 2
  ps | grep -E "[p]hp-fpm|[n]ginx"
  netstat -tlnp | grep -E ":80|:9000"
}

# =====================================================================
# PENGUJIAN (sh mesh.sh <node> test)
# =====================================================================
tests() {
  case "$NODE" in
    alpha)
      apk add curl bind-tools
      echo "== Soal 1-3 =="
      ping -c 2 192.236.0.1
      ping -c 2 8.8.8.8
      ping -c 2 192.236.0.26
      ping -c 2 google.com
      echo "== Soal 4-5 =="
      dig @192.236.0.18 $DOM A +noall +answer
      dig @192.236.0.19 $DOM NS +noall +answer
      nslookup prab.$DOM
      nslookup abbey.$DOM
      ping -c 2 obladi.$DOM
      echo "== Soal 6 =="
      for s in 192.236.0.18 192.236.0.19; do echo -n "$s -> serial "; dig +short SOA $DOM @$s | awk '{print $3}'; done
      dig @192.236.0.18 $DOM SOA | grep flags
      dig @192.236.0.19 $DOM SOA | grep flags
      echo "--- AXFR dari alpha (harus ditolak) ---"
      dig AXFR $DOM @192.236.0.18
      echo "== Soal 7 =="
      for i in 1 2 3 4; do echo "--- vault $i ---"; dig vault.$DOM +short; done
      for i in 1 2 3 4; do echo "--- core $i ---"; dig core.$DOM +short; done
      dig www.$DOM +noall +answer
      dig static.$DOM +noall +answer
      dig vault.$DOM @192.236.0.19 +short
      dig www.$DOM @192.236.0.19 +noall +answer
      echo "== Soal 8 =="
      dig -x 192.236.0.34
      for ip in 192.236.0.34 192.236.0.38 192.236.0.26 192.236.0.27 192.236.0.28 192.236.0.29; do
        echo -n "$ip -> "; dig -x $ip @192.236.0.18 +short
      done
      for ip in 192.236.0.34 192.236.0.38 192.236.0.26 192.236.0.27 192.236.0.28 192.236.0.29; do
        echo -n "$ip -> "; dig -x $ip @192.236.0.19 +short
      done
      for s in 192.236.0.18 192.236.0.19; do echo -n "$s -> serial "; dig +short SOA 0.236.192.in-addr.arpa @$s | awk '{print $3}'; done
      nslookup 192.236.0.29
      nslookup 192.236.0.18
      echo "== Soal 9 =="
      curl -s http://obladi.$DOM/arsip/
      curl -s http://desmond.$DOM/arsip/
      curl -s http://obladi.$DOM/arsip/laporan.txt
      curl -s http://desmond.$DOM/arsip/laporan.txt
      for i in 1 2 3 4; do curl -s http://vault.$DOM/arsip/laporan.txt; done
      curl -I http://vault.$DOM/arsip/
      echo "== Soal 10 =="
      curl -s http://oblada.$DOM/
      curl -s http://molly.$DOM/
      curl -s http://oblada.$DOM/profil
      curl -s http://molly.$DOM/profil
      curl -s -o /dev/null -w "%{http_code}\n" http://core.$DOM/profil
      curl -s -o /dev/null -w "%{http_code}\n" http://core.$DOM/tidakada
      for i in 1 2 3 4; do curl -s http://core.$DOM/ | grep "Dilayani"; done
      ;;
    delta)
      apk add curl bind-tools
      for i in 1 2 3 4; do echo "--- vault $i ---"; dig vault.$DOM +short; done
      for i in 1 2 3 4; do echo "--- core $i ---"; dig core.$DOM +short; done
      dig www.$DOM +noall +answer
      dig static.$DOM +noall +answer
      nslookup www.$DOM
      curl -s http://vault.$DOM/arsip/
      curl -s http://obladi.$DOM/arsip/catatan.txt
      curl -s http://desmond.$DOM/arsip/data.txt
      curl -s http://core.$DOM/
      curl -s http://core.$DOM/profil
      curl -s -I http://molly.$DOM/profil
      ;;
    prab|tedd)
      ps | grep [n]amed
      netstat -ulnp | grep :53
      ls -l /var/bind/pri /var/bind/sec
      dig SOA $DOM @127.0.0.1 +short
      dig SOA 0.236.192.in-addr.arpa @127.0.0.1 +short
      ;;
    *) echo "Tidak ada pengujian khusus untuk $NODE" ;;
  esac
}

# =====================================================================
# DISPATCHER
# =====================================================================
case "$STEP" in
  all)  for n in 1 2 3 4 5 6 7 8 9 10; do soal$n; done ;;
  test) tests ;;
  [1-9]|10) soal$STEP ;;
  *) echo "Langkah tidak valid: $STEP (pakai all, 1-10, atau test)"; exit 1 ;;
esac

echo
echo "=== Selesai: $NODE ($STEP) ==="