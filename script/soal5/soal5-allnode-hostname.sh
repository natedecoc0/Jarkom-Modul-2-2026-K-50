cat > /root/set-host.sh << 'EOF'
#!/bin/sh
# Pemakaian: sh /root/set-host.sh <nama> <ip>
NAME="$1"
IP="$2"

echo "$NAME" > /etc/hostname
cat > /etc/hosts << EOT
127.0.0.1       localhost localhost.localdomain
::1             localhost localhost.localdomain
$IP     $NAME.K50.com $NAME
EOT
hostname -F /etc/hostname

echo "===== /etc/hostname ====="
cat /etc/hostname
echo "===== /etc/hosts ====="
cat /etc/hosts
echo "===== hostname ====="
hostname
hostname -f
EOF
chmod +x /root/set-host.sh