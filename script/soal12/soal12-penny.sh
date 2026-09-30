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