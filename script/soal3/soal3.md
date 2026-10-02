### Soal 3: Pengaturan Routing Internal dan Resolver Awal
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