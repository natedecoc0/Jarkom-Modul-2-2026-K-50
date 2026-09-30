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

# default_server: kalau Host header gak cocok manapun, ini yang dipakai.
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