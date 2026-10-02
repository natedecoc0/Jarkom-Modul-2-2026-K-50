cat > /var/bind/pri/K50.com.zone << 'EOF'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026092902      ; Serial (YYYYMMDDNN)
                        3600            ; Refresh
                        900             ; Retry
                        1209600         ; Expire
                        300 )           ; Negative Cache TTL

; Name Server
@       IN      NS      prab.K50.com.
@       IN      NS      tedd.K50.com.

; Apex domain -> penny (Dynamic Proxy)
@       IN      A       192.236.0.38

; Name Server host
prab    IN      A       192.236.0.18
tedd    IN      A       192.236.0.19

; Router
rootkit IN      A       192.236.0.1

; Klien Sayap Kiri
alpha   IN      A       192.236.0.2
beta    IN      A       192.236.0.3
gamma   IN      A       192.236.0.4

; Klien Sayap Kanan
delta   IN      A       192.236.0.10
epsilon IN      A       192.236.0.11

; Proxy
abbey   IN      A       192.236.0.34
penny   IN      A       192.236.0.38

; Area Vault (Apache)
obladi  IN      A       192.236.0.26
desmond IN      A       192.236.0.27

; Area Core (Nginx + PHP)
oblada  IN      A       192.236.0.28
molly   IN      A       192.236.0.29
EOF

chown named:named /var/bind/pri/K50.com.zone

echo "===== CEK SINTAKS ====="
named-checkzone K50.com /var/bind/pri/K50.com.zone

echo "===== RELOAD named ====="
kill -HUP $(pidof named)
sleep 3
dig SOA K50.com @192.236.0.18 +short