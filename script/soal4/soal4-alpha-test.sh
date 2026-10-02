echo "===== Query ke prab (master) ====="
dig @192.236.0.18 K50.com A +noall +answer
echo "===== Query NS ke tedd (slave) ====="
dig @192.236.0.19 K50.com NS +noall +answer
echo "===== nslookup pakai resolver default ====="
nslookup prab.K50.com
nslookup tedd.K50.com 192.236.0.19
echo "===== Resolve domain publik lewat forwarder ====="
dig google.com +short
ping -c 2 google.com