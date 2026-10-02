mkdir -p /var/bind/pri /var/bind/sec

cat > /etc/bind/named.conf << 'EOF'
options {
    directory "/var/bind";
    pid-file "/var/run/named/named.pid";

    listen-on port 53 { any; };
    listen-on-v6 { none; };

    allow-query { any; };
    recursion yes;
    allow-recursion { 127.0.0.1; 192.236.0.0/26; };

    forwarders { 192.168.122.1; };
    forward first;
    dnssec-validation no;

    notify yes;
    allow-transfer { 192.236.0.19; };
};

zone "K50.com" IN {
    type master;
    file "pri/K50.com.zone";
    notify yes;
    also-notify { 192.236.0.19; };
    allow-transfer { 192.236.0.19; };
};
EOF

cat > /var/bind/pri/K50.com.zone << 'EOF'
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026092901      ; Serial (YYYYMMDDNN)
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
EOF

chown -R named:named /var/bind/pri /var/bind/sec
chmod 644 /var/bind/pri/K50.com.zone

echo "===== VERIFIKASI FILE ====="
ls -l /etc/bind/named.conf /var/bind/pri/K50.com.zone
echo "===== ISI named.conf ====="
cat /etc/bind/named.conf
echo "===== CEK SINTAKS ====="
named-checkconf /etc/bind/named.conf && echo "named.conf OK"
named-checkzone K50.com /var/bind/pri/K50.com.zone