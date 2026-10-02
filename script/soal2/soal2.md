### Soal 2: Konfigurasi NAT dan Akses Internet (WAN)
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
