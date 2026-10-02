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

    masterfile-format text;
    allow-transfer { none; };
};

zone "K50.com" IN {
    type secondary;
    file "sec/K50.com.zone";
    primaries { 192.236.0.18; };
    allow-transfer { none; };
};
EOF

chown -R named:named /var/bind/pri /var/bind/sec

echo "===== VERIFIKASI FILE ====="
ls -l /etc/bind/named.conf
echo "===== ISI named.conf ====="
cat /etc/bind/named.conf
echo "===== CEK SINTAKS ====="
named-checkconf /etc/bind/named.conf && echo "named.conf OK"