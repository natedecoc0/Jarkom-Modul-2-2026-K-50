sleep 3
dig SOA K50.com @192.236.0.19 +short
grep -c "IN" /var/bind/sec/K50.com.zone
cat /var/bind/sec/K50.com.zone