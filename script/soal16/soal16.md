## Soal 16

> Ketahanan gerbang The Mesh harus diuji untuk menghadapi bombardir permintaan. Salah satu Klien (misal: Alpha) bertugas melakukan stress test benchmark menggunakan ApacheBench. Lakukan 250 requests dengan tingkat konkurensi (concurrencies) 10 untuk masing-masing titik akhir: www.xxx.com dan static.xxx.com. Tampilkan rangkuman hasilnya.

### Penjelasan

Pengujian dilakukan dari Alpha memakai ApacheBench (`ab`), 250 request dengan concurrency 10 ke masing-masing endpoint gerbang.

### Script Alpha

```bash
cat > /root/soal16-alpha-benchmark.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache apache2-utils

echo "===== benchmark www.K50.com (vault) ====="
ab -n 250 -c 10 http://www.K50.com/

echo "===== benchmark static.K50.com (core) ====="
ab -n 250 -c 10 http://static.K50.com/
EOF
chmod +x /root/soal16-alpha-benchmark.sh
sh /root/soal16-alpha-benchmark.sh
```

### Hasil

**www.K50.com (vault, Apache balancer ke obladi/desmond)**

| Metrik | Nilai |
|---|---|
| Complete requests | 250 |
| Failed requests | 0 |
| Requests per second | 2054.94 [#/sec] |
| Time per request | 4.866 ms (mean) |
| Transfer rate | 874.96 KB/sec |

**static.K50.com (core, Nginx balancer ke oblada/molly)**

| Metrik | Nilai |
|---|---|
| Complete requests | 250 |
| Failed requests | 123 (tipe Length) |
| Requests per second | 1738.90 [#/sec] |
| Time per request | 5.751 ms (mean) |
| Transfer rate | 554.46 KB/sec |

Catatan soal 123 failed requests di `static.K50.com`: semuanya kategori **Length**, bukan Connect maupun Receive, artinya tidak ada koneksi gagal ataupun timeout. `ab` menganggap request "gagal" kalau panjang body-nya beda dari response pertama. Karena `static.K50.com` di-load-balance ke dua backend (oblada dan molly) yang merender konten PHP dinamis dengan hostname masing-masing, panjang responsnya wajar berbeda tergantung backend mana yang kena giliran round-robin. Gerbang tetap menerima dan meneruskan seluruh 250 request tanpa ada yang benar-benar gagal atau timeout.