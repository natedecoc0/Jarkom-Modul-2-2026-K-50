cat > /root/soal15-abbey-orion.sh << 'EOF'
#!/bin/sh
set -e

mkdir -p /var/www/orion
cat > /var/www/orion/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Orion</title></head>
<body>
<h1>/orion di Abbey</h1>
<p>Ini halaman statis murni, tidak ada rendering PHP.</p>
</body>
</html>
HTML

cat > /etc/nginx/http.d/proxy-core.conf << 'CONF'
upstream corecluster {
    server 192.236.0.28:80;
    server 192.236.0.29:80;
}

log_format proxy_access '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         'real_ip=$http_x_real_ip fwd=$http_x_forwarded_for';

server {
    listen 80 default_server;
    server_name static.K50.com;

    access_log /var/log/nginx/abbey_access.log proxy_access;

    location /orion {
        alias /var/www/orion/;
        autoindex on;
    }

    location / {
        proxy_pass http://corecluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name abbey.K50.com 192.236.0.34;
    return 302 http://static.K50.com$request_uri;
}
CONF

nginx -t
nginx -s reload
EOF
chmod +x /root/soal15-abbey-orion.sh
sh /root/soal15-abbey-orion.sh