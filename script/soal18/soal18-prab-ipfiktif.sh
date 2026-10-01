cat > /root/soal18-step4-prab-fakeip.sh << 'EOF'
#!/bin/sh
set -e

FAKE_IP="203.0.113.$(awk 'BEGIN{srand(); print int(rand()*253)+2}')"
echo "IP fiktif yang dipakai: $FAKE_IP"

cp /var/bind/pri/K50.com.zone /var/bind/pri/K50.com.zone.bak

cat > /var/bind/pri/K50.com.zone << ZONE
\$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100106      ; Serial
                        3600
                        900
                        1209600
                        300 )

@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.
@       IN      A       192.236.0.38

prab    IN      A       192.236.0.18
tedd    IN      A       192.236.0.19
rootkit IN      A       192.236.0.1

alpha   IN      A       192.236.0.2
beta    IN      A       192.236.0.3
gamma   IN      A       192.236.0.4
delta   IN      A       192.236.0.10
epsilon IN      A       192.236.0.11

alpha   IN      TXT     "alpha"
beta    IN      TXT     "beta"
gamma   IN      TXT     "gamma"
delta   IN      TXT     "delta"
epsilon IN      TXT     "epsilon"

abbey   15      IN      A       $FAKE_IP
penny   IN      A       192.236.0.38

obladi  IN      A       192.236.0.26
desmond IN      A       192.236.0.27
oblada  IN      A       192.236.0.28
molly   IN      A       192.236.0.29

vault   IN      A       192.236.0.26
vault   IN      A       192.236.0.27
core    IN      A       192.236.0.28
core    IN      A       192.236.0.29

www     IN      CNAME   penny.K50.com.
static  IN      CNAME   abbey.K50.com.
ZONE

named-checkzone K50.com /var/bind/pri/K50.com.zone
rndc reload K50.com
sleep 1
dig @127.0.0.1 abbey.K50.com A
EOF
chmod +x /root/soal18-step4-prab-fakeip.sh
sh /root/soal18-step4-prab-fakeip.sh