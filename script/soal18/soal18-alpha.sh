cat > /root/recovery-alpha-resolver.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache dnsmasq bind-tools

cat > /etc/dnsmasq.conf << 'CONF'
no-resolv
server=192.236.0.18
server=192.236.0.19
cache-size=150
listen-address=127.0.0.1
bind-interfaces
CONF

pkill dnsmasq 2>/dev/null || true
sleep 1
dnsmasq -C /etc/dnsmasq.conf
EOF
chmod +x /root/recovery-alpha-resolver.sh
sh /root/recovery-alpha-resolver.sh