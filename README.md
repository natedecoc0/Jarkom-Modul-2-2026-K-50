## Member

| No  | Nama                        | NRP        | Pengerjaan Soal |
| --- | --------------------------- | ---------- | --------------- |
| 1   | Marvelino Davas             | 5027251085 | Soal 11 - 20    |
| 2   | Nathania Tiara Wahyudi      | 5027251089 | Soal 1 - 10     |

---

### Soal 1: 
> Sebagai pusat kesadaran The Mesh, rootkit harus merentangkan koneksinya ke lima gerbang utama (Switch). Tetapkan alamat IP dan default gateway untuk seluruh Entitas, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly) sesuai dengan topologi pembagian switch yang dirancang.

<img width="1028" height="825" alt="image" src="https://github.com/user-attachments/assets/e1dc7d85-7d81-4f06-bf5b-f6e27ff38981" />

#### Konfigurasi rootkit

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.236.0.17
    netmask 255.255.255.248
    up ip addr add 192.236.0.25/29 dev eth1
    down ip addr del 192.236.0.25/29 dev eth1 || true

auto eth2
iface eth2 inet static
    address 192.236.0.33
    netmask 255.255.255.252

auto eth3
iface eth3 inet static
    address 192.236.0.37
    netmask 255.255.255.252

auto eth4
iface eth4 inet static
    address 192.236.0.1
    netmask 255.255.255.248

auto eth5
iface eth5 inet static
    address 192.236.0.9
    netmask 255.255.255.248
```

#### Konfigurasi tiap client:

**alpha**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.2
    netmask 255.255.255.248
    gateway 192.236.0.1
```

**beta**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.3
    netmask 255.255.255.248
    gateway 192.236.0.1
```

**gamma**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.4
    netmask 255.255.255.248
    gateway 192.236.0.1
```

**delta**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.10
    netmask 255.255.255.248
    gateway 192.236.0.9
```

**epsilon**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.11
    netmask 255.255.255.248
    gateway 192.236.0.9
```

**prab**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.18
    netmask 255.255.255.248
    gateway 192.236.0.17
```

**tedd**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.19
    netmask 255.255.255.248
    gateway 192.236.0.17
```

**obladi**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.26
    netmask 255.255.255.248
    gateway 192.236.0.25
```

**desmond**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.27
    netmask 255.255.255.248
    gateway 192.236.0.25
```

**oblada**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.28
    netmask 255.255.255.248
    gateway 192.236.0.25
```

**molly**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.29
    netmask 255.255.255.248
    gateway 192.236.0.25
```

**abbey**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.34
    netmask 255.255.255.252
    gateway 192.236.0.33
```

**penny**

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.236.0.38
    netmask 255.255.255.252
    gateway 192.236.0.37
```

#### Test node alpha

```bash
ping -c 2 192.236.0.1
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/233146e5-bdb6-4c8b-8255-41fa0be5f528" />

Sudah bisa tersambung ke rootkit

---

### Soal 2:
> Meskipun The Mesh beroperasi dalam bayang-bayang, Rootkit menyadari bahwa Entitas di dalamnya masih membutuhkan asupan paket dari dunia luar. Buka jalur menuju NAT dengan memastikan antarmuka WAN di router rootkit aktif. Konfigurasikan NAT agar dapat meneruskan lalu lintas keluar bagi seluruh alamat internal, sehingga semua host di dalam jaringan dapat menjangkau internet publik menggunakan IP address.

#### Aktifkan IP forwarding agar router dapat meneruskan paket data dari jaringan internal ke luar

```bash
sysctl -w net.ipv4.ip_forward=1
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/346626f9-59d9-4ded-ab3e-9d15a7551ff1" />

#### Agar konfigurasi IP forwarding tetap aktif setelah sistem di-reboot, tambahkan parameternya ke file konfigurasi sistem

```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
```

#### Tambahkan aturan IPTables NAT (Masquerade) pada antarmuka WAN (eth0)

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### Perbarui blok konfigurasi eth0

```
auto eth0
iface eth0 inet dhcp
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### Coba ping 8.8.8.8 dari alpha

```bash
ping -c 2 8.8.8.8
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/581c7647-e73e-4f9d-886d-870c9df87c9d" />

---

### Soal 3: 
> Jaringan rahasia tidak akan berfungsi tanpa sinkronisasi antar divisi. Pastikan seluruh Entitas dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfungsi). Untuk menghindari fragmentasi saat persiapan, pastikan setiap host non-router menambahkan resolver 192.168.122.1 (tambah di file /etc/resolv.conf, kalau sudah pakai resolver itu tidak perlu memasukkan resolver google) saat antarmukanya aktif agar akses untuk mengunduh paket instalasi dari internet tersedia sejak awal beroperasi.

#### Konfigurasi Resolver di Seluruh Node Non-Router

```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Update konfigurasi di semua node kecuali rootkit

```
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

#### Restart Network Interface di console semua node non-router untuk menerapkan perubahan interface

```bash
ifdown eth0 && ifup eth0
```

#### Testing dari alpha ke obladi

```bash
ping -c 2 192.236.0.26
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/d6d91ba5-2f3f-41b2-94bd-bd8bb8a5e511" />


#### Testing ke google.com

```bash
ping -c 2 google.com
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/c68b0cdb-8aeb-445e-b9ef-50c7ec6f893c" />

#### Memperbarui daftar paket dari repositori tiap node

```bash
apk update
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/c666e681-ee08-4a63-b03f-0c6297e585b3" />

---- 

### Soal 4: 
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

---

### Soal 5: 
> "Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas prab dan tedd.

#### Buat script hostname di semua node termasuk rootkit

```bash
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
```

#### Jalankan command di tiap node

**rootkit**

```bash
sh /root/set-host.sh rootkit 192.236.0.1
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3acc9fbb-dbfb-4c32-b9a6-7f2849a00ad2" />

**alpha**

```bash
sh /root/set-host.sh alpha 192.236.0.2
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/7556ab07-9c18-4b62-a1f9-5ca30d25fd54" />

**beta**

```bash
sh /root/set-host.sh beta 192.236.0.3
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/b373d33e-4a44-463d-a954-74bdabf00b3e" />

**gamma**

```bash
sh /root/set-host.sh gamma 192.236.0.4
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/386445e7-ba64-4c05-81b5-19551ca22d29" />

**delta**

```bash
sh /root/set-host.sh delta 192.236.0.10
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/1f13f0a7-96ff-468f-88e0-db922de2f0ab" />

**epsilon**

```bash
sh /root/set-host.sh epsilon 192.236.0.11
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/600dbafd-30a1-4114-b613-f4bf5a65bd2b" />


**prab**

```bash
sh /root/set-host.sh prab 192.236.0.18
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/61780f78-e5d8-4606-a17a-92ae63f3d56c" />

**tedd**

```bash
sh /root/set-host.sh tedd 192.236.0.19
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/e957d8bd-1954-4594-b741-4fd81d6c73dd" />

**obladi**

```bash
sh /root/set-host.sh obladi 192.236.0.26
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/9e33d215-bdb8-49e1-a10b-5b5cccfd61fd" />

**desmond**

```bash
sh /root/set-host.sh desmond 192.236.0.27
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/dc188bc8-c1cb-4494-aa6f-426fce649996" />

**oblada**

```bash
sh /root/set-host.sh oblada 192.236.0.28
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/996a1dff-e9a0-4ae0-9d32-edf8943d0ac6" />

**molly**

```bash
sh /root/set-host.sh molly 192.236.0.29
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/c8ee2e5c-ca41-427c-be86-d02cedbcc449" />

**abbey**

```bash
sh /root/set-host.sh abbey 192.236.0.34
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/318c289e-136a-4d29-8a45-71d92cbc2442" />

**penny**

```bash
sh /root/set-host.sh penny 192.236.0.38
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/a886efc7-918e-476e-b567-f476020411ea" />

#### Tambah A record di DNS master
Zone file ditulis ulang utuh dengan serial naik ke 2026092902. Serial harus naik supaya tedd mau menarik data baru.

```bash
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
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/d548d59b-5811-471c-9c82-f48e84a95535" />

#### Cek sinkron ke slave

```bash
sleep 3
dig SOA K50.com @192.236.0.19 +short
grep -c "IN" /var/bind/sec/K50.com.zone
cat /var/bind/sec/K50.com.zone
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/107d5d1f-cf8a-47e4-99a2-1e9b270a0eff" />

#### Verifikasi di alpha

```bash
echo "===== hostname ====="
hostname
hostname -f
echo "===== A record via prab (master) ====="
dig @192.236.0.18 molly.K50.com +short
dig @192.236.0.18 obladi.K50.com +short
echo "===== A record via tedd (slave) ====="
dig @192.236.0.19 rootkit.K50.com +short
dig @192.236.0.19 epsilon.K50.com +short
echo "===== nslookup ====="
nslookup abbey.K50.com
nslookup delta.K50.com
echo "===== ping pakai nama ====="
ping -c 2 obladi.K50.com
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/a4fda822-4aa5-4721-9936-15743131df90" />

---

### Soal 6: Verifikasi Zone Transfer dan Sinkronisasi SOA
> Pastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melengkapi.

#### Restart BIND di prab

```bash
killall named
sleep 1
mkdir -p /var/run/named
chown named:named /var/run/named
named -u named -c /etc/bind/named.conf
sleep 2
ps | grep [n]amed
netstat -ulnp | grep :53
dig SOA K50.com @127.0.0.1 +short
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/328cbea0-71b5-4544-9867-c5a4d5684376" />

#### Di console tedd, restart BIND dan hapus salinan lama. Salinan dihapus supaya terbukti tedd menarik ulang dari prab, bukan membaca file lama.

```bash
killall named
sleep 1
rm -f /var/bind/sec/K50.com.zone
ls -l /var/bind/sec/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/e52ce3ea-0807-4f69-b1bf-53feaa9c12fd" />

#### Jalankan named di tedd

```bash
mkdir -p /var/run/named
chown named:named /var/run/named
named -u named -c /etc/bind/named.conf
sleep 5
ps | grep [n]amed
ls -l /var/bind/sec/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/91fdb25c-4a45-48f1-b0e8-044ba88cccd1" />

#### Lihat isi file hasil transfer di tedd

```bash
cat /var/bind/sec/K50.com.zone
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/fc9572b4-b795-4cf7-9f8c-f95b8f10a316" />

#### Bandingkan SOA dari kedua server di alpha

```bash
dig SOA K50.com @192.236.0.18 +short
dig SOA K50.com @192.236.0.19 +short
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/d3acc734-0202-4e4e-8236-a2b379249d7a" />

#### Tampilkan serial saja di alpha

```bash
for s in 192.236.0.18 192.236.0.19; do echo -n "$s -> serial "; dig +short SOA K50.com @$s | awk '{print $3}'; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/474badf5-bb07-4893-a04e-4ae1b2ca7e80" />

#### Buktikan kedua server menjawab sebagai authoritative (flag aa)

```bash
dig @192.236.0.18 K50.com SOA | grep flags
dig @192.236.0.19 K50.com SOA | grep flags
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/68c3beb6-6bbf-4208-89f3-0d89cff833b5" />

#### Uji pembatasan AXFR. prab hanya mengizinkan transfer ke tedd

Di console tedd (harus diizinkan)

```bash
dig AXFR K50.com @192.236.0.18
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/d673fb2d-0bd1-45a0-b548-1d46b8275dcd" />

Di console alpha (harus ditolak)

```bash
dig AXFR K50.com @192.236.0.18
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/67fa62d7-d5fc-4df6-8b7f-3252bb89f9e8" />

---

### Soal 7: 
> abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk vault.<xxxx>.com (IP obladi & desmond), dan core.<xxxx>.com (IP oblada & molly). Tetapkan CNAME:
www.<xxxx>.com → penny.<xxxx>.com
static.<xxxx>.com → abbey.<xxxx>.com
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.

#### Edit zona di console prab

```bash
nano /var/bind/pri/K50.com.zone
```

Timpa isi file dengan

```
$TTL 3600
@       IN      SOA     prab.K50.com. root.K50.com. (
                        2026092903      ; Serial (YYYYMMDDNN)
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

; Round-Robin Group (Soal 7)
vault   IN      A       192.236.0.26
vault   IN      A       192.236.0.27
core    IN      A       192.236.0.28
core    IN      A       192.236.0.29

; Alias CNAME (Soal 7)
www     IN      CNAME   penny.K50.com.
static  IN      CNAME   abbey.K50.com.
```

#### Cek sintaks lalu reload

```bash
named-checkzone K50.com /var/bind/pri/K50.com.zone
kill -HUP $(pidof named)
sleep 3
dig SOA K50.com @127.0.0.1 +short
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/54b055ab-ceef-4784-aaec-75a6abc0bbf1" />

#### Pastikan salinan sudah ikut naik di console tedd

```bash
sleep 3
dig SOA K50.com @127.0.0.1 +short
grep -E "vault|core|www|static" /var/bind/sec/K50.com.zone
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/c7bef0ff-0b44-4864-bd92-8990f2786635" />

#### Di console alpha (Sayap Kiri), uji round-robin. 

Tiap dig adalah query baru, jadi urutan jawaban berputar

```bash
for i in 1 2 3 4; do echo "--- vault query $i ---"; dig vault.K50.com +short; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/df374fcc-07c9-4e45-b34a-6d114a25bf8b" />

Titik awal rotasi bisa berbeda (mulai dari .27), yang penting urutannya berganti antar query.

```bash
for i in 1 2 3 4; do echo "--- core query $i ---"; dig core.K50.com +short; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/63b3e05d-0a25-41ab-97b6-5f4144764f1d" />

#### Uji CNAME di alpha

```bash
dig www.K50.com +noall +answer
dig static.K50.com +noall +answer
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/cd0e35e4-51df-4219-8f99-aa60466c286a" />

#### Masih di alpha, uji dengan nslookup dan ping

```bash
nslookup www.K50.com
nslookup static.K50.com
nslookup vault.K50.com
ping -c 2 www.K50.com
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/6751e382-50f1-400e-b556-1132bc7e5c04" />

#### Di console delta (Sayap Kanan), jalankan uji yang sama. Jika dig belum ada, install dulu apk add bind-tools

```bash
for i in 1 2 3 4; do echo "--- vault query $i ---"; dig vault.K50.com +short; done
for i in 1 2 3 4; do echo "--- core query $i ---"; dig core.K50.com +short; done
dig www.K50.com +noall +answer
dig static.K50.com +noall +answer
nslookup www.K50.com
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/c8d0ab16-fde9-4fce-acc6-8a000dd8b213" />

#### Di console alpha, pastikan tedd (slave) menjawab sama seperti prab

```bash
dig vault.K50.com @192.236.0.19 +short
dig core.K50.com @192.236.0.19 +short
dig www.K50.com @192.236.0.19 +noall +answer
dig static.K50.com @192.236.0.19 +noall +answer
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/f94db6cb-6c0f-4ad3-853b-226417f7fcf7" />

---

### Soal 8: Reverse DNS Zone (PTR Record)
> Di prab (ns1) deklarasikan reverse zone untuk segmen jaringan  tempat abbey, penny, area vault, dan area core berada. Di tedd (ns2) tarik reverse zone tersebut sebagai slave, isi PTR untuk keempat hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat abbey, penny, area vault, dan area core dijawab authoritative.

#### Di console prab, tambahkan deklarasi zona

```bash
nano /etc/bind/named.conf
```

Tambahkan blok ini di paling bawah file (jangan hapus isi lama)

```
zone "0.236.192.in-addr.arpa" IN {
    type master;
    file "pri/0.236.192.in-addr.arpa.zone";
    notify yes;
    also-notify { 192.236.0.19; };
    allow-transfer { 192.236.0.19; };
};
```

#### Masih di prab, buat file zona reverse

```bash
nano /var/bind/pri/0.236.192.in-addr.arpa.zone
```

Isi file

```
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

; PTR Records (angka = oktet terakhir IP)
34      IN      PTR     abbey.K50.com.
38      IN      PTR     penny.K50.com.
26      IN      PTR     obladi.K50.com.
27      IN      PTR     desmond.K50.com.
28      IN      PTR     oblada.K50.com.
29      IN      PTR     molly.K50.com.
```

Angka di kolom pertama adalah oktet terakhir IP. Serial 2026092901 berdiri sendiri karena ini zona baru, terpisah dari zona K50.com. Nama tujuan PTR wajib FQDN berakhiran titik.

#### Masih di prab, atur izin, cek sintaks, lalu reload

```bash
chown named:named /var/bind/pri/0.236.192.in-addr.arpa.zone
chmod 644 /var/bind/pri/0.236.192.in-addr.arpa.zone
named-checkconf /etc/bind/named.conf && echo "named.conf OK"
named-checkzone 0.236.192.in-addr.arpa /var/bind/pri/0.236.192.in-addr.arpa.zone
kill -HUP $(pidof named)
sleep 3
dig SOA 0.236.192.in-addr.arpa @127.0.0.1 +short
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5684fbf2-753d-4221-ae08-fa9e5c1b24d6" />

#### Di console tedd, tambahkan deklarasi zona slave

```
nano /etc/bind/named.conf
```

Tempatkan di paling bawah file

```
zone "0.236.192.in-addr.arpa" IN {
    type secondary;
    file "sec/0.236.192.in-addr.arpa.zone";
    primaries { 192.236.0.18; };
    allow-transfer { none; };
};
```

#### Masih di tedd, cek sintaks, reload, lalu cek file hasil transfer

```bash
named-checkconf /etc/bind/named.conf && echo "named.conf OK"
kill -HUP $(pidof named)
sleep 5
ls -l /var/bind/sec/
dig SOA 0.236.192.in-addr.arpa @127.0.0.1 +short
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5e1d0a0e-4825-4c5b-ab35-fb1f3bc37c2a" />

#### Di console tedd, lihat isi zona hasil transfer

```bash
cat /var/bind/sec/0.236.192.in-addr.arpa.zone
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3a60dc8e-1e5f-4a79-924d-ddfa66e3e05a" />

#### Di console alpha, uji satu PTR dengan dig -x

```bash
dig -x 192.236.0.34
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/9690c984-9430-44e7-8000-006e89da39d6" />

Flag aa berarti dijawab authoritative oleh prab.

#### Masih di alpha, uji semua enam PTR lewat prab

```bash
for ip in 192.236.0.34 192.236.0.38 192.236.0.26 192.236.0.27 192.236.0.28 192.236.0.29; do echo -n "$ip -> "; dig -x $ip @192.236.0.18 +short; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/612eb9b9-e4a9-4696-b718-def9c644ae9f" />

#### Masih di alpha, ulangi lewat tedd untuk membuktikan slave menjawab sama

```bash
for ip in 192.236.0.34 192.236.0.38 192.236.0.26 192.236.0.27 192.236.0.28 192.236.0.29; do echo -n "$ip -> "; dig -x $ip @192.236.0.19 +short; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/91bc5470-b496-43c1-b231-1bd8364d4d9a" />

#### Masih di alpha, bandingkan serial SOA reverse di kedua server

```bash
for s in 192.236.0.18 192.236.0.19; do echo -n "$s -> serial "; dig +short SOA 0.236.192.in-addr.arpa @$s | awk '{print $3}'; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5f123135-92b6-47d6-8d0f-7e99317dc554" />

#### Masih di alpha, uji dengan nslookup dan IP yang belum punya PTR

```bash
nslookup 192.236.0.29
nslookup 192.236.0.18
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/9a7ddca7-2275-4838-95b3-6b1b65720269" />

192.236.0.18 (prab) memang tidak didaftarkan di soal, jadi NXDOMAIN itu benar dan menunjukkan zona ini authoritative penuh untuk blok 192.236.0.x.

Hasil analisis:

Zona reverse: 0.236.192.in-addr.arpa, master di prab dan slave di tedd
PTR: .34 abbey, .38 penny, .26 obladi, .27 desmond, .28 oblada, .29 molly
Serial SOA reverse: 2026092901 di prab dan tedd
File hasil transfer: /var/bind/sec/0.236.192.in-addr.arpa.zone di tedd

---

### Soal 9:
> Jalankan layanan web statis pada hostname di node area vault (menggunakan apache). Buka folder direktori /arsip/ dan aktifkan fitur autoindex (directory listing) pada konfigurasi Apache sehingga seluruh daftar file di dalamnya dapat ditelusuri langsung dari browser. Akses pengujian harus dilakukan melalui hostname, bukan IP address.

Apache dipasang di obladi dan desmond (area vault). Folder /arsip/ dibuat di document root dengan autoindex aktif, lalu diuji lewat hostname.

#### Install Apache di obladi dan desmond

```bash
apk add apache2 curl
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/41197b39-2d62-425e-9a40-a99d1489790c" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/587a90cf-dfff-4535-b5ec-21beb06c02f4" />

#### Buat folder /arsip/ dan isinya

**obladi** 

```bash
mkdir -p /var/www/localhost/htdocs/arsip
echo "laporan dari obladi" > /var/www/localhost/htdocs/arsip/laporan.txt
echo "catatan dari obladi" > /var/www/localhost/htdocs/arsip/catatan.txt
echo "data dari obladi" > /var/www/localhost/htdocs/arsip/data.txt
ls -l /var/www/localhost/htdocs/arsip
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5349f5b3-3f1b-4a8e-8ffe-1c60bd1b28c7" />

**desmond**

```bash
mkdir -p /var/www/localhost/htdocs/arsip
echo "laporan dari desmond" > /var/www/localhost/htdocs/arsip/laporan.txt
echo "catatan dari desmond" > /var/www/localhost/htdocs/arsip/catatan.txt
echo "data dari desmond" > /var/www/localhost/htdocs/arsip/data.txt
ls -l /var/www/localhost/htdocs/arsip
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/10967451-1033-4966-81bf-ac222dcee5b4" />

#### Aktifkan autoindex

```bash
cat > /etc/apache2/conf.d/arsip.conf << 'EOF'
<Directory "/var/www/localhost/htdocs/arsip">
    Options +Indexes
    AllowOverride None
    Require all granted
</Directory>
EOF

grep -q "^ServerName" /etc/apache2/httpd.conf || echo "ServerName localhost" >> /etc/apache2/httpd.conf

httpd -M 2>/dev/null | grep autoindex
httpd -t
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/92707056-a1e1-49bf-8fb0-437f0a397428" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/a3de387c-22df-4693-a69c-9cbb52d730f3" />

#### Jalankan Apache

```bash
mkdir -p /run/apache2
httpd
sleep 2
ps | grep [h]ttpd
netstat -tlnp | grep :80
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/7eae4cea-aa60-4b18-86e2-4675eff2b2aa" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/a8cc4aa8-c413-47c2-a06b-5444fcde9663" />

#### Uji per hostname

```bash 
curl -s http://obladi.K50.com/arsip/
curl -s http://desmond.K50.com/arsip/
```

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/5df62d50-5d8a-4b6e-911b-9b24a288b356" />

```bash
curl -s http://obladi.K50.com/arsip/laporan.txt
curl -s http://desmond.K50.com/arsip/laporan.txt
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3a2fed7e-3e31-43c8-8589-0b8a590f6aac" />

#### Uji lewat hostname vault (round-robin DNS)

```bash
for i in 1 2 3 4; do curl -s http://vault.K50.com/arsip/laporan.txt; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/e16dfeaa-0d12-493d-af9d-4cc7f12060ac" />

#### Cek status HTTP

```bash
curl -I http://vault.K50.com/arsip/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/ed3038b2-4003-41bd-a5c4-fec0c76cab86" />

#### Uji dari klien lain (delta)

```bash
apk add curl
curl -s http://vault.K50.com/arsip/
curl -s http://obladi.K50.com/arsip/catatan.txt
curl -s http://desmond.K50.com/arsip/data.txt
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/19892ed4-d387-4986-a2b3-14e68fff72c9" />

---

### Soal 10:
> Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rewrite pada server sehingga akses ke /profil dapat berfungsi dengan URL bersih (tanpa akhiran .php). Akses pengujian wajib dilakukan melalui hostname.

Nginx dan PHP-FPM dipasang di oblada dan molly (area core). Aplikasi punya halaman beranda dan profil, dan /profil bisa diakses tanpa .php lewat rewrite. Pengujian dilakukan lewat hostname.

#### Perbarui indeks paket dan install Nginx serta PHP-FPM

```bash
apk update
PHPV=php85
apk add nginx $PHPV $PHPV-fpm
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/ad150797-85e7-4e0e-8d21-a7e2a13a8fea" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/611477a8-ee45-4719-81d4-e3c3096051b1" />

#### Buat aplikasi sederhana

```bash
mkdir -p /var/www/html

cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Beranda</title></head>
<body>
<h1>Beranda The Mesh</h1>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/profil">Halaman Profil</a>
</body>
</html>
EOF

cat > /var/www/html/profil.php << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Profil</title></head>
<body>
<h1>Profil</h1>
<p>Kelompok: K50</p>
<p>Dilayani oleh: <?php echo gethostname(); ?></p>
<a href="/">Kembali ke Beranda</a>
</body>
</html>
EOF

chmod -R 755 /var/www/html
ls -l /var/www/html
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/4b00f56e-1e00-4e3c-a40d-7eb25036e21a" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/09f85556-93b1-4a83-9930-4140a5d02b02" />

#### Konfigurasi Nginx

```bash
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/core.conf << 'EOF'
server {
    listen 80 default_server;
    server_name core.K50.com oblada.K50.com molly.K50.com;

    root /var/www/html;
    index index.php;

    rewrite ^/profil/?$ /profil.php last;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
EOF

nginx -t
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/25a59903-ac95-4209-aae2-f85d74257768" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/98892a88-c293-4fc0-808c-3b86f04c532e" />

#### Jalankan PHP-FPM dan Nginx

```bash
grep -E "^listen|^user" /etc/php85/php-fpm.d/www.conf
php-fpm85
mkdir -p /run/nginx
nginx
sleep 2
ps | grep -E "[p]hp-fpm|[n]ginx"
netstat -tlnp | grep -E ":80|:9000"
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/7c0f3291-c409-4613-a823-e8b524adc51d" />

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/3f821584-478b-419e-902f-7e47ef5c381d" />

#### Uji beranda per hostname (alpha)

```bash
apk add curl
curl -s http://oblada.K50.com/
curl -s http://molly.K50.com/
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/b08c30dc-1cbd-4a17-963e-ca300c339a40" />

#### Uji URL bersih /profil (alpha)

```bash
curl -s http://oblada.K50.com/profil
curl -s http://molly.K50.com/profil
curl -s -o /dev/null -w "%{http_code}\n" http://core.K50.com/profil
curl -s -o /dev/null -w "%{http_code}\n" http://core.K50.com/tidakada
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/5bb078b7-d2a7-4fe6-949c-10f2d98df0d7" />

#### Uji lewat hostname core (round-robin)

```bash
for i in 1 2 3 4; do curl -s http://core.K50.com/ | grep "Dilayani"; done
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/92aa68e1-bdbf-4390-93fc-bc72fd355ad3" />

#### Uji dari klien lain (delta)

```bash
apk add curl
curl -s http://core.K50.com/
curl -s http://core.K50.com/profil
curl -s -I http://molly.K50.com/profil
```

<img width="745" height="521" alt="image" src="https://github.com/user-attachments/assets/80013c89-ea8a-4d42-9d73-7412a88cfb66" />

