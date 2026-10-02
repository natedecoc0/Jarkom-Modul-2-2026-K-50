### Soal 1: Penetapan Alamat IP dan Gateway (Topologi Jaringan)
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

