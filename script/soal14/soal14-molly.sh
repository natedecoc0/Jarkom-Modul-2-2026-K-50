cat > /root/soal14-core-reallog.sh << 'EOF'
#!/bin/sh
set -e

cat > /etc/nginx/http.d/core.conf << 'CONF'
log_format realip '$http_x_real_ip - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent';

server {
    listen 80 default_server;
    server_name core.K50.com oblada.K50.com molly.K50.com;

    root /var/www/html;
    index index.php;

    access_log /var/log/nginx/access_real.log realip;

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
CONF

nginx -t
echo "===== config OK ====="
nginx -s reload
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal14-core-reallog.sh
sh /root/soal14-core-reallog.sh