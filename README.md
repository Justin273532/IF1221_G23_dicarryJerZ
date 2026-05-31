# Permainan Game UNI

**Praktikum IF1221 Logika Komputasional 2025**  
**Bahasa:** GNU Prolog  
**Tema:** permainan kartu berbasis giliran yang terinspirasi dari UNO.

---

## Gambaran singkat proyek
Proyek ini merupakan implementasi permainan kartu berbasis **GNU Prolog**. Permainan ini menerapkan konsep dasar seperti permainan UNO. Tujuan utama dari permainan ini adalah agar setiap pemain dapat menghabiskan seluruh kartu yang dimilikinya lebih dahulu dibanding pemain lain. Pemain harus memainkan kartu yang sesuai dengan warna, angka, atau efek kartu yang sedang berada di discard pile teratas. Selama permainan berlangsung, pemain juga harus memperhatikan berbagai aturan dan efek kartu spesial, seperti perubahan arah permainan, penalti pengambilan kartu, skip giliran, tantangan `tantang`, hingga kondisi `UNI` ketika kartu tersisa satu. Pemain yang berhasil mengosongkan seluruh kartunya akan dinyatakan sebagai pemenang permainan.

---
## Cara Menjalankan Program

### 1. Instalasi GNU Prolog
[GNU Prolog](http://www.gprolog.org/)

### 2. Clone repository

```bash
git clone https://github.com/Justin273532/IF1221_G23_dicarryJerZ.git
cd IF1221_G23_dicarryJerZ/src
```

### 2. Jalankan GNU Prolog

```bash
gprolog
```

### 3. Consult file utama

Untuk menjalankan program consult `main.pl`

```prolog
| ?- ['main.pl'].
```

Apabila file berhasil dimuat, GNU Prolog akan menampilkan status bahwa file berhasil dikonsultkan.

### 4. Mulai permainan

```prolog
| ?- startGame.
```

Program akan meminta jumlah pemain dan nama masing-masing pemain. Jumlah pemain yang valid adalah **2 sampai 4 pemain**.

Contoh:

```prolog
| ?- startGame.
Masukkan jumlah pemain: 3.
Masukkan nama pemain 1: a.
Masukkan nama pemain 2: b.
Masukkan nama pemain 3: c.

Urutan pemain: b - c - a
Setiap pemain mendapatkan 7 kartu acak.
Kartu discard top: merah-8
Giliran b.
```

---

## Struktur Repository
```text
.
├── src                # Tempat menyimpan semua file sumber (.pl)
│   ├── actionCard.pl
│   ├── bonus.pl
│   ├── fileProcessing.pl
│   ├── gameSystem.pl
│   ├── io.pl
│   ├── main.pl
│   ├── tangkap.pl
│   ├── tantang.pl
│   └── util.pl
└── docs               # Tempat menyimpan semua proses pengerjaan dan laporan
    ├── Milestone1_G23.pdf
    ├── Milestone2_G23.pdf
    └── Laporan_G23.pdf
```
## Fitur Utama
### 1. **Inisialisasi Permainan**
- Reset seluruh game state dan membentuk state awal permainan.
- Menentukan jumlah dan urutan giliran pemain.
- Memberikan 7 kartu acak untuk masing-masing pemain dan 1 kartu acak sebagai discard top.
### 2. **Alur dan Fitur Permainan** 
- **Pemain bermain bergiliran** → melacak giliran pemain dan mengganti giliran secara berurutan.
- **Kartu mimic** → pemain bisa memainkan kartu ini meniru kartu aksi sebelumnya.
- **Kartu draw** → pemain bisa memainkan kartu ini untuk membuat pemain berikutnya mengambil kartu.
- **Kartu wild** → pemain bisa memainkan kartu ini untuk mengganti warna.
- **Kartu reverse** → pemain bisa memainkan kartu ini untuk membalik urutan giliran pemain.
- **Kartu skip** → pemain bisa memainkan kartu ini untuk melewati giliran pemain berikutnya
- **MODE TURNAMEN** → mode 2vs2, dimana pemain dalam satu tim bisa bekerja sama dengan cara menukar kartu antar sesama anggota tim.
### 3. **Perintah yang Tersedia**
- **cekInfo** → cek informasi permainan saat ini, urutan pemain saat ini, kartu discard top, nama pemain, dan jumlah kartu masing-masing pemain.
- **lihatKartu** → cek informasi kartu pemain yang mendapat sedang mendapat giliran, termasuk kartu yang sedang disembunyikan termasuk nomor urutnya.
- **ambilKartu** → mengambil kartu dari deck ketika pemain tidak ingin memainkan kartu atau tidak memiliki langkah valid.
- **mainkanKartu** → memainkan kartu yang sesuai dengan warna/angka/simbol dengan kartu discard top, atau memainkan kartu wild.
- **tantang** → menantang pemain yang mengeluarkan kartu wild draw four apabila pemain tersebut memiliki kartu yang dapat dimainkan.
- **tangkap** → menangkap pemain yang tidak menyerukan uni meskipun kartunya bersisa satu.
- **uni** → menyerukan uni apabila memainkan kartu yang membuat kartu bersisa satu.
- **godsHand** → memilih satu pemain secara acak dan memindahkan kartunya ke pemain lain secara acak.
- **sembunyikanKartu** → menyembunyikan kartu sehingga tidak terlihat oleh lawan saat menggunakan cekInfo.
- **saveGame** → menyimpan game ke dalam file txt.
- **loadGame** → memuat kondisi game yang sebelumnya di save.
- **lihatCommand** → melihat daftar perintah yang bisa digunakan saat ini.

## Anggota Kelompok
| Nama | NIM |
|---|---|
| Justin William | 13525042 |
| Muhammad Ridwan Nasir Firdaus | 13525096 |
| Jeremy Gerald Sutanto | 13525104 |
| Christian Immanuel | 13525116 |
