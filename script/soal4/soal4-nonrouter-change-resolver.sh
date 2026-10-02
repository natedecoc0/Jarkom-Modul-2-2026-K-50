# 1. Hapus baris resolv.conf lama di interfaces, lalu tambahkan yang baru
sed -i '/resolv.conf/d' /etc/network/interfaces
cat >> /etc/network/interfaces << 'EOF'
    up printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf
EOF

# 2. Terapkan sekarang juga
printf 'nameserver 192.236.0.18\nnameserver 192.236.0.19\nnameserver 192.168.122.1\n' > /etc/resolv.conf

# 3. Bukti untuk laporan
echo "===== /etc/network/interfaces ====="
cat /etc/network/interfaces
echo "===== /etc/resolv.conf ====="
cat /etc/resolv.conf