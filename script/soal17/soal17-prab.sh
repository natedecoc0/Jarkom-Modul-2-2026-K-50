cat > /root/soal17-prab-txt.sh << 'EOF'
#!/bin/sh
set -e

cp /var/bind/pri/K50.com.zone /var/bind/pri/K50.com.zone.bak

cat > /var/bind/pri/K50.com.zone << 'ZONE'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026100102      ; Serial
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

abbey   IN      A       192.236.0.34
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

rndc reload K50.com || { pkill named; sleep 1; named -u named; }

sleep 1
echo "===== cek dari prab sendiri ====="
dig @127.0.0.1 alpha.K50.com TXT +short
dig @127.0.0.1 beta.K50.com TXT +short
dig @127.0.0.1 gamma.K50.com TXT +short
dig @127.0.0.1 delta.K50.com TXT +short
dig @127.0.0.1 epsilon.K50.com TXT +short
EOF
chmod +x /root/soal17-prab-txt.sh
sh /root/soal17-prab-txt.sh