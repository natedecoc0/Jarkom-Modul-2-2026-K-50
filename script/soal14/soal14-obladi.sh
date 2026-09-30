cat > /root/soal14-vault-reallog.sh << 'EOF'
#!/bin/sh
set -e

# X-Real-IP diambil dari header yang diteruskan Penny (soal 11), bukan %h
# yang isinya IP Penny sendiri karena dia yang connect langsung ke sini.
cat > /etc/apache2/conf.d/reallog.conf << 'CONF'
LogFormat "%{X-Real-IP}i %l %u %t \"%r\" %>s %b" realip
CustomLog /var/log/apache2/access_real.log realip
CONF

httpd -t
echo "===== config OK ====="
httpd -k graceful
sleep 2
echo "===== status service ====="
netstat -tlnp | grep :80
EOF
chmod +x /root/soal14-vault-reallog.sh
sh /root/soal14-vault-reallog.sh