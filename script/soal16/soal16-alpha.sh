cat > /root/soal16-alpha-benchmark.sh << 'EOF'
#!/bin/sh
set -e

apk add --no-cache apache2-utils

echo "===== benchmark www.K50.com (vault) ====="
ab -n 250 -c 10 http://www.K50.com/

echo "===== benchmark static.K50.com (core) ====="
ab -n 250 -c 10 http://static.K50.com/
EOF
chmod +x /root/soal16-alpha-benchmark.sh
sh /root/soal16-alpha-benchmark.sh