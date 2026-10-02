### Soal 5: Pengaturan Hostname dan Domain Entitas System-Wide
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
