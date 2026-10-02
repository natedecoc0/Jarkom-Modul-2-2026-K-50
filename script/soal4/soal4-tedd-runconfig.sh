mkdir -p /var/run/named
chown named:named /var/run/named
named -u named -c /etc/bind/named.conf

sleep 5
echo "===== STATUS ====="
ps | grep [n]amed
netstat -ulnp | grep :53
echo "===== ZONA HASIL TRANSFER ====="
ls -l /var/bind/sec/