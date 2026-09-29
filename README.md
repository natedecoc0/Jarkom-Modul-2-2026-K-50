## Member

| No  | Nama                        | NRP        | Pengerjaan Soal |
| --- | --------------------------- | ---------- | --------------- |
| 1   | Marvelino Davas             | 5027251085 | Soal 11 - 20    |
| 2   | Nathania Tiara Wahyudi      | 5027251089 | Soal 1 - 10     |

### Soal 1: 
Sebagai pusat kesadaran The Mesh, rootkit harus merentangkan koneksinya ke lima gerbang utama (Switch). Tetapkan alamat IP dan default gateway untuk seluruh Entitas, mulai dari para operator (alpha, beta, gamma), penjaga directory (prab, tedd), gerbang penyaring (abbey, penny), hingga repository (obladi, desmond, oblada, molly) sesuai dengan topologi pembagian switch yang dirancang.

<img width="1028" height="825" alt="image" src="https://github.com/user-attachments/assets/e1dc7d85-7d81-4f06-bf5b-f6e27ff38981" />


Konfigurasi rootkit
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

Konfigurasi tiap client:

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

Uji di rootkit
```
for ip in 192.236.0.2 192.236.0.3 192.236.0.4 192.236.0.10 192.236.0.11 192.236.0.18 192.236.0.19 192.236.0.26 192.236.0.27 192.236.0.28 192.236.0.29 192.236.0.34 192.236.0.38; do ping -c 1 -W 1 $ip >/dev/null && echo "$ip OK" || echo "$ip GAGAL"; done
```


### Soal 2:
Meskipun The Mesh beroperasi dalam bayang-bayang, Rootkit menyadari bahwa Entitas di dalamnya masih membutuhkan asupan paket dari dunia luar. Buka jalur menuju NAT dengan memastikan antarmuka WAN di router rootkit aktif. Konfigurasikan NAT agar dapat meneruskan lalu lintas keluar bagi seluruh alamat internal, sehingga semua host di dalam jaringan dapat menjangkau internet publik menggunakan IP address.


### Soal 3: 
Jaringan rahasia tidak akan berfungsi tanpa sinkronisasi antar divisi. Pastikan seluruh Entitas dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfungsi). Untuk menghindari fragmentasi saat persiapan, pastikan setiap host non-router menambahkan resolver 192.168.122.1 (tambah di file /etc/resolv.conf, kalau sudah pakai resolver itu tidak perlu memasukkan resolver google) saat antarmukanya aktif agar akses untuk mengunduh paket instalasi dari internet tersedia sejak awal beroperasi.


### Soal 4: 
Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke prab.<xxxx>.com, serta tambahkan catatan NS untuk prab.<xxxx>.com dan tedd.<xxxx>.com. Buat A record untuk prab.<xxxx>.com dan tedd.<xxxx>.com yang mengarah ke alamat IP mereka masing-masing, serta A record apex <xxxx>.com yang mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona <xxxx>.com dari master dan pastikan server menjawab secara authoritative. Setelah fondasi nama ini berdiri kokoh, perbarui urutan resolver pada seluruh Entitas non-router menjadi: IP prab, IP tedd, lalu 192.168.122.1. Verifikasi bahwa query ke domain apex maupun hostname di dalam zona dijawab dengan benar oleh prab atau tedd.

### Soal 5: 
"Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, desmond, oblada, molly, dan verifikasi bahwa setiap host mengenali hostname tersebut secara system-wide. Buat setiap domain untuk masing-masing node sesuai dengan namanya (contoh: alpha.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas prab dan tedd.


### Soal 6: 
Pastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melengkapi.


### Soal 7: 
abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk vault.<xxxx>.com (IP obladi & desmond), dan core.<xxxx>.com (IP oblada & molly). Tetapkan CNAME:
www.<xxxx>.com → penny.<xxxx>.com
static.<xxxx>.com → abbey.<xxxx>.com
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.


### Soal 8:
Di prab (ns1) deklarasikan reverse zone untuk segmen jaringan  tempat abbey, penny, area vault, dan area core berada. Di tedd (ns2) tarik reverse zone tersebut sebagai slave, isi PTR untuk keempat hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat abbey, penny, area vault, dan area core dijawab authoritative.


### Soal 9:
Jalankan layanan web statis pada hostname di node area vault (menggunakan apache). Buka folder direktori /arsip/ dan aktifkan fitur autoindex (directory listing) pada konfigurasi Apache sehingga seluruh daftar file di dalamnya dapat ditelusuri langsung dari browser. Akses pengujian harus dilakukan melalui hostname, bukan IP address.


### Soal 10:
Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rewrite pada server sehingga akses ke /profil dapat berfungsi dengan URL bersih (tanpa akhiran .php). Akses pengujian wajib dilakukan melalui hostname.
