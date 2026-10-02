## Soal 18

> Ubah A record DNS milik abbey.xxx.com ke alamat IP yang fiktif (ubah secara random namun pastikan format IP valid). Naikkan nilai serial SOA di prab dan pastikan tedd ikut tersinkron. Tetapkan TTL sebesar 15 detik pada record yang relevan tersebut. Verifikasi momen yang terjadi pada tiga fase pencarian: sebelum perubahan terjadi (mengembalikan IP lama), saat perubahan baru saja terjadi dalam jeda 15 detik (masih IP lama karena cache), dan setelah batas waktu TTL habis (berubah ke IP fiktif yang baru).

### Penjelasan

`prab` dan `tedd` adalah authoritative server, bukan caching resolver, sehingga query langsung ke mereka selalu mengembalikan data zone terkini tanpa ada efek cache sama sekali. Supaya fase "masih IP lama karena cache" bisa benar-benar dibuktikan, dipasang `dnsmasq` di Alpha sebagai caching resolver yang forward ke prab/tedd. Semua verifikasi dilakukan lewat `dig @127.0.0.1` di Alpha (ke dnsmasq), bukan langsung ke prab.

Record `abbey` diberi TTL eksplisit 15 detik (menimpa default zone 3600 detik) supaya jendela pengujian singkat dan bisa diamati langsung. IP fiktif diambil dari blok `203.0.113.0/24` (TEST-NET-3, RFC 5737), blok yang memang dialokasikan untuk dokumentasi/contoh sehingga jelas fiktif namun tetap format IP valid. Setiap perubahan zone diikuti kenaikan serial SOA supaya tedd (slave) tersinkron lewat zone transfer.

Dua clock jalan bersamaan di soal ini: clock cache di Alpha (mulai ngitung mundur dari detik dig pertama, berhenti saat TTL habis) dan clock perubahan di Prab (kapan saja, begitu script dijalankan authoritative langsung punya data baru). Langkah 5 di bawah harus terjadi setelah Langkah 4 tapi sebelum 15 detik dari Langkah 4 habis, supaya saat Langkah 6 nanya ke Alpha, authoritative sudah punya jawaban baru tapi cache Alpha masih menyimpan yang lama.

### Langkah 1 — di Prab, set TTL 15 pada record abbey

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

```
zone K50.com/IN: loaded serial 2026100105
OK
server reload successful
```

### Langkah 2 — di Alpha, pasang dnsmasq sebagai caching resolver

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

```
(dnsmasq jalan tanpa output, proses background)
```

### Langkah 3 — di Prab, siapkan script ganti IP fiktif (disiapkan dulu, belum dijalankan)

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
```

Belum ada output, file cuma dibuat dan di-chmod. Dijalankan di Langkah 5.

### Langkah 4 — di Alpha, fase 1 (mulai hitungan)

```bash
date; dig @127.0.0.1 abbey.K50.com A
```

```
Fri Oct  2 22:50:10 UTC 2026
;; ANSWER SECTION:
abbey.K50.com.          15      IN      A       192.236.0.34
```

Query pertama, cache Alpha baru mulai menyimpan, TTL penuh 15.

### Langkah 5 — segera pindah ke Prab, jalankan script dari Langkah 3 (target selesai ±5 detik dari Langkah 4)

```bash
sh /root/soal18-step4-prab-fakeip.sh
```

```
IP fiktif yang dipakai: 203.0.113.191
zone K50.com/IN: loaded serial 2026100106
OK
server reload successful

;; ANSWER SECTION:
abbey.K50.com.          15      IN      A       203.0.113.191
```

Dig di akhir script ini query langsung ke Prab (authoritative), jadi walau cache Alpha belum berubah, Prab sendiri sudah pasti menunjuk IP baru.

### Langkah 6 — balik ke Alpha, fase 2 (harus masih dalam 15 detik dari Langkah 4)

```bash
date; dig @127.0.0.1 abbey.K50.com A
```

```
Fri Oct  2 22:50:16 UTC 2026
;; ANSWER SECTION:
abbey.K50.com.          9       IN      A       192.236.0.34
```

Masih IP lama, tapi TTL sudah turun (15 dikurangi detik yang lewat sejak Langkah 4, bukan reset). Ini bukti paling penting: authoritative sudah beda, tapi client masih percaya cache.

### Langkah 7 — di Alpha, tunggu sampai total waktu sejak Langkah 4 lewat 15 detik

```bash
sleep 10
```

### Langkah 8 — di Alpha, fase 3

```bash
date; dig @127.0.0.1 abbey.K50.com A
```

```
Fri Oct  2 22:50:27 UTC 2026
;; ANSWER SECTION:
abbey.K50.com.          15      IN      A       203.0.113.191
```

Cache sudah expired, dnsmasq nanya ulang ke prab/tedd, dapat IP fiktif, TTL fresh balik ke 15.

### Langkah 9 — verifikasi Tedd ikut sinkron

```bash
dig @192.236.0.19 K50.com SOA +short
dig @192.236.0.19 abbey.K50.com A +short
```

```
2026100106
203.0.113.191
```

Catatan praktis: siapkan dua terminal (Alpha dan Prab) berdampingan dari awal, jangan baru dibuka saat mulai, supaya perpindahan Langkah 4→5→6 tidak kebuang waktu. Perpindahan 5 ke 6 adalah bagian paling kritis — kalau kelewat 15 detik, Langkah 6 ikut menangkap IP baru juga (karena cache keburu expired), dan pembuktian "masih cache"-nya jadi tidak kelihatan. Kalau itu terjadi saat live, tinggal ulang dari Langkah 4 lagi.

### Hasil Verifikasi 3 Fase (ringkasan)

| Fase | Waktu (UTC) | IP | TTL | Keterangan |
|---|---|---|---|---|
| 1. Sebelum perubahan (Langkah 4) | 05:37:44 | 192.236.0.34 | 15 | IP lama, query pertama, mulai cache |
| 2. Baru berubah, dalam jendela 15 detik (Langkah 6) | 05:37:50 | 192.236.0.34 | 9 | Masih IP lama, TTL turun dari 15 ke 9 (6 detik berlalu), bukti dijawab dari cache meski authoritative sudah punya IP baru |
| 3. Setelah TTL habis (Langkah 8) | 05:38:21 | 203.0.113.191 | 15 | Cache expired, query ulang ke prab, dapat IP fiktif baru, TTL fresh |

Perubahan di authoritative (prab) terjadi di antara fase 1 dan fase 2, pukul 05:37:47 UTC (Langkah 5), dibuktikan lewat `dig` langsung ke prab yang sudah menunjukkan `203.0.113.191`, sementara Alpha (lewat cache) baru ikut berubah di fase 3. Hasil Langkah 9: serial 2026100106, IP `203.0.113.191`, identik dengan prab.