## Soal 18

> Ubah A record DNS milik abbey.xxx.com ke alamat IP yang fiktif (ubah secara random namun pastikan format IP valid). Naikkan nilai serial SOA di prab dan pastikan tedd ikut tersinkron. Tetapkan TTL sebesar 15 detik pada record yang relevan tersebut. Verifikasi momen yang terjadi pada tiga fase pencarian: sebelum perubahan terjadi (mengembalikan IP lama), saat perubahan baru saja terjadi dalam jeda 15 detik (masih IP lama karena cache), dan setelah batas waktu TTL habis (berubah ke IP fiktif yang baru).

### Penjelasan

`prab` dan `tedd` adalah authoritative server, bukan caching resolver, sehingga query langsung ke mereka selalu mengembalikan data zone terkini tanpa ada efek cache sama sekali. Supaya fase "masih IP lama karena cache" bisa benar-benar dibuktikan, dipasang `dnsmasq` di Alpha sebagai caching resolver yang forward ke prab/tedd. Semua verifikasi dilakukan lewat `dig @127.0.0.1` di Alpha (ke dnsmasq), bukan langsung ke prab.

Record `abbey` diberi TTL eksplisit 15 detik (menimpa default zone 3600 detik) supaya jendela pengujian singkat dan bisa diamati langsung. IP fiktif diambil dari blok `203.0.113.0/24` (TEST-NET-3, RFC 5737), blok yang memang dialokasikan untuk dokumentasi/contoh sehingga jelas fiktif namun tetap format IP valid. Setiap perubahan zone diikuti kenaikan serial SOA supaya tedd (slave) tersinkron lewat zone transfer.

### Konfigurasi Prab (master, TTL 15 pada abbey)

```bash
cat > /var/bind/pri/K50.com.zone << 'ZONE'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100105      ; Serial
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

alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"

abbey   15      IN      A       192.236.0.34
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

named-checkzone K50.com /var/bind/pri/K50.com.zone
rndc reload K50.com
```

### Konfigurasi Prab (ganti ke IP fiktif)

```bash
cat > /root/soal18-step4-prab-fakeip.sh << 'EOF'
#!/bin/sh
set -e

FAKE_IP="203.0.113.$(awk 'BEGIN{srand(); print int(rand()*253)+2}')"
echo "IP fiktif yang dipakai: $FAKE_IP"

cp /var/bind/pri/K50.com.zone /var/bind/pri/K50.com.zone.bak

cat > /var/bind/pri/K50.com.zone << ZONE
\$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100106      ; Serial
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

alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"

abbey   15      IN      A       $FAKE_IP
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

named-checkzone K50.com /var/bind/pri/K50.com.zone
rndc reload K50.com
sleep 1
dig @127.0.0.1 abbey.K50.com A
EOF
chmod +x /root/soal18-step4-prab-fakeip.sh
sh /root/soal18-step4-prab-fakeip.sh
```

### Konfigurasi Alpha (caching resolver untuk verifikasi)

```bash
cat > /root/recovery-alpha-resolver.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache dnsmasq bind-tools

cat > /etc/dnsmasq.conf << 'CONF'
no-resolv
server=192.236.0.18
server=192.236.0.19
cache-size=150
listen-address=127.0.0.1
bind-interfaces
CONF

pkill dnsmasq 2>/dev/null || true
sleep 1
dnsmasq -C /etc/dnsmasq.conf
EOF
chmod +x /root/recovery-alpha-resolver.sh
sh /root/recovery-alpha-resolver.sh
```

### Hasil Verifikasi 3 Fase (query lewat dnsmasq di Alpha)

| Fase | Waktu (UTC) | IP | TTL | Keterangan |
|---|---|---|---|---|
| 1. Sebelum perubahan | 05:37:44 | 192.236.0.34 | 15 | IP lama, query pertama, mulai cache |
| 2. Baru berubah, dalam jendela 15 detik | 05:37:50 | 192.236.0.34 | 9 | Masih IP lama, TTL turun dari 15 ke 9 (6 detik berlalu), bukti dijawab dari cache meski authoritative sudah punya IP baru |
| 3. Setelah TTL habis | 05:38:21 | 203.0.113.191 | 15 | Cache expired, query ulang ke prab, dapat IP fiktif baru, TTL fresh |

Perubahan di authoritative (prab) terjadi di antara fase 1 dan fase 2, pukul 05:37:47 UTC, dibuktikan lewat `dig` langsung ke prab yang sudah menunjukkan `203.0.113.191`, sementara Alpha (lewat cache) baru ikut berubah di fase 3.

### Verifikasi sinkron ke Tedd

```bash
dig @127.0.0.1 K50.com SOA +short
dig @127.0.0.1 abbey.K50.com A +short
```

Hasil: serial 2026100106, IP `203.0.113.191`, identik dengan prab.

### Screenshot

<!-- TODO: SS 18.1 - dig abbey.K50.com di prab, TTL 15, IP lama -->
<!-- TODO: SS 18.2 - dig SOA di tedd, serial tersinkron -->
<!-- TODO: SS 18.3 - fase 1 di alpha, date + dig, IP lama TTL 15 -->
<!-- TODO: SS 18.4 - output script ganti IP fiktif di prab -->
<!-- TODO: SS 18.5 - fase 2 di alpha, date + dig, IP lama TTL turun (9) -->
<!-- TODO: SS 18.6 - fase 3 di alpha, date + dig, IP fiktif TTL 15 -->
<!-- TODO: SS 18.7 - dig SOA + A di tedd, serial dan IP fiktif tersinkron -->