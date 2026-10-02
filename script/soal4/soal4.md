### Soal 4: Konfigurasi DNS Master-Slave dan Pembaruan Resolver
> Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke prab.<xxxx>.com, serta tambahkan catatan NS untuk prab.<xxxx>.com dan tedd.<xxxx>.com. Buat A record untuk prab.<xxxx>.com dan tedd.<xxxx>.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex <xxxx>.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona <xxxx>.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd.

#### Install paket di prab dan tedd

```bash
apk add bind bind-tools
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/60b6ddec-e354-498f-b477-e2fbb74a2eb6" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/9748e64f-381a-428c-80d6-37b371d3fc56" />


#### Jalankan di alpha dan delta untuk dig dan nslookup

```bash
apk add bind-tools
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/c4e529d2-bbd9-4ecd-a58b-3f6a5ead14b9" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/dea2713d-7ab0-436a-b8d5-b124d5fbb974" />

#### Konfigurasi master

```bash
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
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/680473b3-80ae-417d-b6f5-c9ab2c0ddadc" />

#### Konfigurasi Slave

```bash
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
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/bb4516e4-dfae-4fbf-80b0-6ddeb8317b2c" />

#### Jalankan konfigurasi di prab dan tedd

**prab**

```bash
mkdir -p /var/run/named
chown named:named /var/run/named
named -u named -c /etc/bind/named.conf

sleep 2
echo "===== STATUS ====="
ps | grep [n]amed
netstat -ulnp | grep :53
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/9feb2d41-18d0-4f33-86de-810704e7a64f" />

**tedd**

```bash
mkdir -p /var/run/named
chown named:named /var/run/named
named -u named -c /etc/bind/named.conf

sleep 5
echo "===== STATUS ====="
ps | grep [n]amed
netstat -ulnp | grep :53
echo "===== ZONA HASIL TRANSFER ====="
ls -l /var/bind/sec/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/57512542-bd6b-4553-9c93-37d2ad852045" />

#### Ganti resolver di 13 node non-router

```bash
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
```
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/11acf9ce-db88-4509-a08e-f67f1b2ec44f" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/cff5b450-678b-4d5d-b9cc-5c0552151d4d" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/abd825b4-387b-4fb8-a661-4cabc5897a39" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/ef5ebeb5-eea8-406d-bc3a-067a490c29fe" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/26beb7e0-bf33-4108-b1c1-06c00af6941d" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/bd68d5cf-3cba-475f-9e07-bae18a323062" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/8f793ded-d946-4b7f-8f0a-73f989c75d14" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3ed9cf8d-fec3-45d6-9b7c-d220c6705634" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/58fdb8f9-c38b-449a-b3d2-4f0f1571677d" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/7d69d90d-71da-4b8b-bc5f-cd0685b23301" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/8a1018a1-f5f9-40b1-a507-291e25b1e7fa" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/f7fe31a8-d6a6-4a45-97ff-005510511abc" />
<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/4fb3d033-3512-4ec6-b99d-cad1f1346519" />

#### Testing di alpha

```bash
echo "===== Query ke prab (master) ====="
dig @192.236.0.18 K50.com A +noall +answer
echo "===== Query NS ke tedd (slave) ====="
dig @192.236.0.19 K50.com NS +noall +answer
echo "===== nslookup pakai resolver default ====="
nslookup prab.K50.com
nslookup tedd.K50.com 192.236.0.19
echo "===== Resolve domain publik lewat forwarder ====="
dig google.com +short
ping -c 2 google.com
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/f62ec9db-904e-443f-aa8b-03bb90c002cd" />
