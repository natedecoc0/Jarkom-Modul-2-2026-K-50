cat > /root/soal11-abbey-proxy.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache nginx curl

# Default.conf dihapus karena biasanya punya "listen 80 default_server" yang bisa
# nabrak sama server block baru kita, dua-duanya nge-claim default utk port 80.
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/proxy-core.conf << 'CONF'
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
        proxy_set_header Host $host;
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