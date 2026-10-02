---

### Soal 12: Basic Authentication pada Path /admin (Penny)
> Terdapat ruang khusus di penny yang yang menyimpan dokumen rahasia sindikat, oleh karena itu terapkan perlindungan basic authentication untuk path /admin. Akses ke jalur tersebut harus menolak pengunjung tanpa kredensial, dan hanya mengizinkan masuk jika menggunakan credential berikut:
>
> | Username | Password |
> | --- | --- |
> | prabs | pakar_pinter_jadi_gob*** |

`/admin` itu ruang lokal di Penny sendiri, bukan konten dari backend vault, jadi harus dikecualikan dari reverse proxy soal 11 supaya Apache melayaninya sendiri, bukan meneruskannya ke obladi/desmond. Modul auth (auth_basic, authn_file, authn_core, authz_user, authz_core) sudah diaktifkan waktu soal 11, jadi tinggal pasang htpasswd dan directive-nya, tidak perlu install ulang modul. Urutan `ProxyPass /admin !` wajib ditulis sebelum `ProxyPass "/"`, karena Apache mencocokkan ProxyPass dari atas ke bawah (bukan berdasarkan prefix terpanjang), jadi kalau kebalik `/admin` tetap ke-proxy ke vault dan basic auth-nya tidak pernah kepanggil.

#### Konfigurasi basic auth di Penny

```bash
cat > /root/soal12-penny-admin-auth.sh << 'EOF'
#!/bin/sh
set -e

# Folder lokal khusus admin di penny sendiri, isinya dokumen rahasia dummy.
mkdir -p /var/www/localhost/htdocs/admin
cat > /var/www/localhost/htdocs/admin/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Admin - Rahasia Sindikat</title></head>
<body>
<h1>Ruang Admin Penny</h1>
<p>Dokumen rahasia sindikat ada di sini.</p>
</body>
</html>
HTML

# -c bikin file baru (timpa kalau sudah ada), -b ambil password langsung dari argumen.
htpasswd -cb /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
echo "===== isi .htpasswd (password ke-hash) ====="
cat /etc/apache2/.htpasswd

# Timpa ulang config proxy vault dari soal 11, tambahkan pengecualian /admin
# supaya path itu dilayani lokal, bukan diteruskan ke backend.
cat > /etc/apache2/conf.d/proxy-vault.conf << 'CONF'
<Proxy balancer://vaultcluster>
    BalancerMember http://192.236.0.26:80
    BalancerMember http://192.236.0.27:80
</Proxy>

ProxyRequests Off
ProxyPreserveHost On

# Pengecualian WAJIB di atas ProxyPass "/" supaya /admin tidak ikut ke-proxy ke vault.
ProxyPass /admin !

ProxyPass "/" "balancer://vaultcluster/"
ProxyPassReverse "/" "balancer://vaultcluster/"

RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"

# Proteksi basic auth khusus /admin.
<Directory "/var/www/localhost/htdocs/admin">
    AuthType Basic
    AuthName "Restricted Area - The Mesh"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
CONF

httpd -t
echo "===== config OK ====="

# Reload, bukan start baru, karena httpd dari soal 11 sudah jalan.
httpd -k graceful
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal12-penny-admin-auth.sh
sh /root/soal12-penny-admin-auth.sh
```

#### Buktikan /admin menolak tanpa kredensial dan menerima kredensial yang benar

```bash
echo "===== Tanpa kredensial (harus 401) ====="
curl -s -o /dev/null -w "%{http_code}\n" http://penny.K50.com/admin/

echo "===== Kredensial salah (harus 401) ====="
curl -s -o /dev/null -w "%{http_code}\n" -u prabs:salah http://penny.K50.com/admin/

echo "===== Kredensial benar, username prabs (harus 200) ====="
curl -s -u 'prabs:pakar_pinter_jadi_gob***' http://penny.K50.com/admin/
```

Hasil terbukti: `401` tanpa kredensial, `401` dengan kredensial salah, dan `200` dengan isi halaman admin tampil saat kredensial benar (`prabs` / `pakar_pinter_jadi_gob***`).

---