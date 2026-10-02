echo "===== hostname ====="
hostname
hostname -f
echo "===== A record via prab (master) ====="
dig @192.236.0.18 molly.K50.com +short
dig @192.236.0.18 obladi.K50.com +short
echo "===== A record via tedd (slave) ====="
dig @192.236.0.19 rootkit.K50.com +short
dig @192.236.0.19 epsilon.K50.com +short
echo "===== nslookup ====="
nslookup abbey.K50.com
nslookup delta.K50.com
echo "===== ping pakai nama ====="
ping -c 2 obladi.K50.com