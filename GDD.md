# GDD – Melestarikan: Tutur Terakhir

**Game Design Document · Versi 0.3 · 12 November 2026**

> **Pitch satu kalimat:** Game puzzle kata tempat kamu merekam bahasa Banjar dari penutur terakhir sebelum ceritanya berakhir.

| Judul | Genre | Platform | Durasi sesi | Mode |
| :--- | :--- | :--- | :--- | :--- |
| Melestarikan: Tutur Terakhir | Puzzle kata naratif | Web (HTML5), prioritas **desktop browser** | 5–8 menit | Single player |

---

## 1. Gambaran Umum

### 1.1 Konsep
Pemain duduk bersama Nenek Wati, penutur terakhir bahasa Banjar di kampungnya, di pelataran rumahnya saat senja. Nenek bercerita dalam bahasa Banjar, dan pemain harus menebak makna kata dari konteks: gestur Nenek, benda di sekitar, dan alur cerita. Setiap kata yang berhasil dicatat membawa pemain lebih dekat ke tujuan mewariskan bahasa itu ke anak-anak desa, tetapi energi Nenek terus menipis.

Game memiliki **dua mode permainan**:
1. **Mode Normal (`Pendatang`):** Nenek bercerita dalam bahasa Indonesia yang disisipi 20 kata bahasa Banjar bergaris bawah. Dirancang untuk pemain yang belum akrab dengan bahasa Banjar dan kurator agar setiap kata dapat disimpulkan secara adil.
2. **Mode Sulit (`Akamsi` – Anak Kampung Sini):** Terbuka setelah pemain **menamatkan Mode Normal** (minimal 15/20 kata benar). Dialog **berbeda** (bukan terjemahan 1:1), 100% Bahasa Banjar, dengan **10 kata lama + 10 kata baru**. Pemain menebak dari gestur, ikon, dan pertanyaan (jawaban petunjuk tanpa arti langsung).

### 1.2 Pilar Desain
- **Menebak, bukan diberi tahu.** Makna selalu bisa disimpulkan dari konteks; game tidak pernah memberi terjemahan langsung.
- **Waktu adalah energi seseorang.** Batas sesi bukan timer dingin, melainkan kelelahan Nenek yang terasa personal.
- **Kesalahan terasa manusiawi.** Tebakan salah menyakiti kepercayaan Nenek, tetapi dikoreksi dengan lembut, bukan dihukum.
- **Pendek dan utuh.** Satu sore, satu cerita, satu momen emosional di akhir.

### 1.3 Player Fantasy
Menjadi pendengar yang sabar dan peka, yang berhasil menyelamatkan sebuah bahasa di detik-detik terakhir. Rasa haru dan *"aha!"* saat arti sebuah kata terbuka adalah inti pengalaman.

### 1.4 Target Pemain
Pemain casual yang menyukai game naratif pendek dan puzzle ringan; pelajar dan guru (bahan diskusi budaya dan bahasa); komunitas yang peduli pelestarian bahasa daerah. Tempo yang pelan tidak cocok untuk pemain yang mencari aksi cepat.

---

## 2. Tujuan, Obstacle, dan Kondisi Akhir

### 2.1 Goal
Mengumpulkan dan mencatat **minimal 15 dari 20 kata bahasa Banjar** yang muncul dalam cerita Nenek Wati sebelum sesi berakhir. Jika berhasil, memori Nenek terbuka dan bahasa itu "diwariskan" ke anak-anak desa.

### 2.2 Obstacle
- Energi Nenek terbatas, sehingga jumlah pertanyaan juga terbatas.
- Makna kata harus ditebak dari konteks, bukan diberi tahu langsung.
- Tebakan yang salah menurunkan kepercayaan Nenek dan menguras energinya lebih cepat.

### 2.3 Kondisi Akhir

| Hasil | Syarat | Ending |
| :--- | :--- | :--- |
| **Menang – Warisan Penuh** | 20/20 kata benar | Memori Nenek terbuka sepenuhnya; anak-anak desa menirukan seluruh cerita |
| **Menang – Warisan** | 18–19 kata benar | Memori terbuka; anak-anak mengulang kata-kata yang tercatat |
| **Menang – Warisan Tipis** | 15–17 kata benar | Memori terbuka sebagian; ada kata yang masih tertinggal |
| **Kalah – Senyap** | < 15 kata saat energi habis | Nenek tertidur; ending reflektif tentang bahasa yang ikut hilang. Pemain bisa mengulang |

---

## 3. Core Gameplay Loop

**Dengarkan cerita → amati gestur dan benda di sekitar → tebak makna kata (pilihan ganda) → catat di buku → Nenek bereaksi (senang, koreksi, atau lelah) → lanjut ke kata berikutnya.**

Loop mikro (per kata) berlangsung sekitar 15–25 detik; loop makro (per sesi) terdiri dari 10 segmen cerita dengan 2 kata per segmen.

---

## 4. Mekanik dan Sistem

### 4.1 Alur Satu Segmen Cerita
1. **Narasi:** teks cerita Nenek muncul di kotak dialog. Kata bahasa Banjar ditandai dengan garis bawah saat diucapkan.
2. **Petunjuk:** sprite Nenek melakukan gestur dan ikon benda terkait disorot sebentar.
3. **Penandaan:** kata masuk ke buku kosakata dengan status *"belum diketahui"*.
4. **Tebakan:** pemain membuka buku, memilih kata, lalu memilih satu dari empat arti (**pilihan ganda**).
5. **Reaksi:** Nenek merespons benar, salah, atau lelah; sumber daya diperbarui.
6. **Lanjut:** segmen berikutnya berjalan, atau pemain bisa menebak kata lama yang belum selesai.

Pemain boleh menebak kapan saja selama sesi; kata yang belum ditebak tetap menumpuk di buku. Hal ini memungkinkan pemain menunda sampai petunjuk di segmen berikutnya terkumpul, dengan risiko energi habis.

### 4.2 Sistem Energi Nenek
Energi adalah batas waktu sesi. Nilai di bawah adalah **nilai awal untuk penyeimbangan (tuning)** dan akan diubah setelah playtest.

| Peristiwa | Perubahan energi (skala 0–100) |
| :--- | :--- |
| Awal sesi | 100 |
| Pengurasan pasif | −0,22 per detik (kosong sekitar 7,5 menit tanpa peristiwa lain) |
| Tebakan benar | +3 (Nenek senang) |
| Tebakan salah | −8 |
| Mengajukan pertanyaan | −4 |
| Energi ≤ 25 | Nenek mulai batuk dan melambat; pengurasan pasif naik 25% |
| Energi = 0 | Sesi berakhir, masuk ke penilaian akhir |

### 4.3 Sistem Kepercayaan
Kepercayaan menentukan seberapa murah hati Nenek memberi petunjuk. Rentang 0–100, dimulai dari 60.

| Tingkat | Rentang | Efek pada petunjuk |
| :--- | :--- | :--- |
| **Percaya** | 60–100 | Gestur lengkap, ikon benda disorot lebih lama, jawaban pertanyaan jelas |
| **Ragu** | 30–59 | Gestur singkat, sorotan benda hanya sekali |
| **Waspada** | 0–29 | Nenek jarang menunjuk; jawaban pertanyaan samar dan lebih mahal energi (−6) |

Tebakan benar: **+8 kepercayaan**. Tebakan salah: **−15 kepercayaan**. Pertanyaan tidak memengaruhi kepercayaan. Ini membuat pemain terdorong menebak hanya saat cukup yakin, tanpa menghukum rasa ingin tahu.

### 4.4 Sistem Menebak (Pilihan Ganda)
- Setiap kata memiliki **4 pilihan arti**: 1 benar dan 3 pengecoh yang masuk akal secara konteks.
- Setiap kata mendapat maksimal **2 percobaan**. Setelah dua kali salah, kata terkunci sebagai *"terlewat"* dan Nenek menyebut artinya dengan sedih; kata itu tidak dihitung.
- Pilihan jawaban diacak setiap sesi untuk mencegah hafalan posisi.
- Kata yang benar terkunci di buku kosakata dengan ikon benda dan arti.

### 4.5 Sistem Pertanyaan
Pemain punya **6 pertanyaan per sesi**. Setiap pertanyaan memberi petunjuk tambahan berupa gestur atau cerita lanjutan, tidak pernah terjemahan langsung.

| Pertanyaan | Bentuk jawaban Nenek |
| :--- | :--- |
| *"Itu untuk apa, Nek?"* | Memperagakan fungsi benda |
| *"Bisa ditunjukkan lagi?"* | Mengulang gestur atau menunjuk benda dengan jelas |
| *"Nenek rasakan apa waktu itu?"* | Ekspresi wajah dan nada menunjukkan perasaan (untuk kata abstrak) |
| *"Siapa itu, Nek?"* | Menunjuk foto, sosok, atau gestur hubungan keluarga |

### 4.6 Buku Kosakata
Buku berisi **20 slot kata**. Setiap slot punya status: **belum ditebak**, **terkunci benar**, atau **terlewat**. Slot menampilkan bentuk kata bahasa Banjar, ikon benda terkait, dan catatan pendek dari cerita (misalnya *"disebut saat Nenek memegang ..."*). Kolom tebakan pilihan ganda hanya aktif untuk kata yang sedang dipilih.

### 4.7 Kurva Kesulitan

| Fase | Kata | Jenis petunjuk |
| :--- | :--- | :--- |
| **Pengantar** | 1–5 | Benda terlihat jelas, gestur langsung, kata disebut berulang dalam satu segmen |
| **Menengah** | 6–15 | Petunjuk gabungan: benda plus konteks cerita; perlu membandingkan dua kemunculan |
| **Menantang** | 16–20 | Kata abstrak (perasaan, hubungan kerabat, waktu); mengandalkan nada dan gestur |

Tutorial disisipkan dalam cerita: Nenek menyapa, memperkenalkan buku kosakata, lalu kata pertama diajarkan dengan petunjuk yang hampir jelas.

---

## 5. Level dan Struktur Sesi

Satu sesi = satu sore di teras rumah Nenek, **5–8 menit**, satu cerita utama, tanpa progression. Latar senja bergradasi dari jingga ke ungu seiring energi menurun, sehingga pemain merasakan waktu berlalu tanpa melihat angka.

| Segmen | Tema cerita | Kata |
| :--- | :--- | :--- |
| 1 | Sambutan dan pengenalan teras | 1–2 |
| 2–3 | Dapur dan makanan (periuk, bahan masakan) | 3–6 |
| 4–5 | Kegiatan harian dan peralatan (tikar, sirih, dll.) | 7–10 |
| 6–7 | Alam sekitar dan hewan | 11–14 |
| 8 | Keluarga dan kerabat | 15–16 |
| 9 | Kenangan, perasaan, dan kehilangan | 17–18 |
| 10 | Pesan terakhir kepada anak-anak desa | 19–20 |

### 5.1 Diagram Alur Sesi
`Pembuka dan tutorial → Segmen 1–10 (narasi, petunjuk, tebakan, reaksi) → Penilaian akhir → Layar ending (menang atau kalah) → Opsi mengulang sesi.`

Sesi dapat berakhir lebih awal bila energi habis di tengah cerita; Nenek menutup cerita dengan singkat.

---

## 6. Konten

### 6.1 Struktur Data Kata

| Field | Isi |
| :--- | :--- |
| `id` | Nomor unik kata (`w01`–`w20`) |
| `form` | Bentuk kata dalam **bahasa Banjar** |
| `meaning` | Arti yang benar (bahasa Indonesia) |
| `distractors` | 3 arti pengecoh |
| `category` | `benda`, `tindakan`, `alam`, `kerabat`, `perasaan` |
| `visualClue` | Ikon benda atau gestur yang menyertai |
| `narrativeClue` | Kalimat konteks dan segmen kemunculan (minimal dua kemunculan) |
| `difficulty` | `1`–`3` (pengantar, menengah, menantang) |

Seluruh konten disimpan sebagai data (JSON) terpisah dari kode sehingga bahasa, penutur, dan cerita baru dapat ditambahkan tanpa mengubah mesin game.

### 6.2 Daftar Kata Aktif Bahasa Banjar (Tervalidasi)

#### Mode Pendatang (20 kata)
| Kategori | Jumlah | Daftar Kata & Arti |
| :--- | :--- | :--- |
| **Benda & peralatan** | 7 | `pelataran` (teras), `rinjing` (penggorengan/wajan), `panai` (cobek), `cirat` (teko), `ulas tilam` (sprei), `tapih` (kain sarung wanita), `lading` (pisau) |
| **Tindakan** | 5 | `basasimpun` (merapikan ruangan), `maharu` (mengaduk masakan), `mamirik` (mengulek bumbu), `nukar` (membeli), `mahadang` (menunggu) |
| **Alam dan suasana** | 3 | `sabat` (rumput), `haruan` (ikan gabus), `kadap` (gelap) |
| **Kerabat** | 2 | `kai` (kakek), `acil` (bibi/tante) |
| **Perasaan dan waktu** | 3 | `bahari` (zaman dulu), `karindangan` (kerinduan), `himung` (senang/gembira) |

#### Mode Akamsi (20 kata: 10 lama + 10 baru)
**Dipertahankan:** `pelataran`, `rinjing`, `panai`, `cirat`, `tapih`, `haruan`, `kai`, `acil`, `bahari`, `himung`

**Baru:** `gadur` (baskom), `hawas` (melihat), `warik` (kera), `julak` (kakak orang tua), `dingsanak` (saudara), `uyuh` (capek/lelah), `padaringan` (tempat beras), `atung` (panggilan sayang), `ambun` (embun), `salau` (remang)

### 6.3 Aturan Penulisan Cerita
- Setiap kata muncul **minimal dua kali** dalam konteks berbeda agar bisa disimpulkan.
- Tidak ada kata yang hanya muncul sekali tanpa petunjuk visual.
- Nada hangat, personal, dan tidak menggurui; kalimat pendek.
- Pengecoh harus masuk akal (misalnya benda lain di teras), bukan jawaban asal.

### 6.4 Akurasi dan Representasi Budaya
Bahasa yang digunakan adalah **bahasa Banjar** (bahasa daerah nyata) dan **divalidasi langsung oleh pengembang selaku penutur asli Banjar**. Representasi Nenek dan budaya Banjar dibuat dengan hormat dan autentik.

---

## 7. Antarmuka (UI) dan Kontrol

### 7.1 Elemen UI
- **Bar energi Nenek:** di bagian atas; berubah warna dan berdenyut halus saat di bawah 25.
- **Penghitung kata terkumpul:** misalnya `7/15`, di samping bar energi; berubah warna saat target tercapai.
- **Buku kosakata:** tombol buku yang membuka daftar kata dan kolom tebakan pilihan ganda.
- **Kotak dialog:** di bawah layar, menampilkan cerita dengan kata bahasa Banjar bergaris bawah.
- **Tombol pilihan pertanyaan:** 3–4 opsi, menampilkan sisa pertanyaan (misalnya `4/6`).

### 7.2 Kontrol (Prioritas Desktop Web)
- Klik mouse untuk memilih kata, jawaban pilihan ganda, dan pertanyaan.
- Klik kotak dialog (atau tombol `Space` / `Enter` opsional) untuk mempercepat teks; tidak ada gerakan yang membutuhkan kecepatan.
- Tombol jeda dan pengaturan (volume, ukuran teks).

### 7.3 Umpan Balik

| Peristiwa | Visual | Audio |
| :--- | :--- | :--- |
| Tebakan benar | Nenek tersenyum, kata terkunci dengan animasi, penghitung naik | Efek benar yang lembut, bunyi menulis |
| Tebakan salah | Nenek menggeleng dan mengoreksi, bar energi turun | Efek salah yang pelan, bukan buzzer |
| Energi rendah | Nenek batuk, latar makin gelap | Musik melambat, jangkrik lebih dominan |
| Ending menang | Anak-anak datang, senja berubah hangat | Kecapi atau suling naik, tawa anak-anak |

### 7.4 Aksesibilitas
- Ukuran teks dapat disesuaikan dan kontras tinggi.
- Status tidak hanya mengandalkan warna; ada ikon atau teks pendamping.
- Seluruh aksi inti tidak memerlukan refleks cepat.

---

## 8. Seni, Audio, dan Daftar Aset

Prioritas: **P0** = wajib untuk MVP/seleksi, **P1** = sangat disarankan, **P2** = tambahan jika waktu cukup.

### 8.1 Arah Gaya
- **Visual:** pixel art hangat dengan palet senja (jingga, ungu, cokelat tanah, krem kertas, hijau daun, merah bata). Latar berubah dari sore ke senja seiring energi Nenek menurun.
- **Audio:** kecapi atau suling pelan, ambience jangkrik dan ayam, efek yang lembut (tidak ada buzzer atau bunyi yang mengagetkan). **Tanpa sulih suara pada versi 1.0.**
- **Konsistensi:** tentukan palet (16–24 warna) dan font pixel lebih dulu, lalu semua aset memakai acuan yang sama.

### 8.2 Aset Visual

| Aset | Contoh isi / deskripsi | Spesifikasi saran | Nama file | Prio |
| :--- | :--- | :--- | :--- | :--- |
| Latar teras – sore | Teras rumah panggung, tangga kayu, pohon kelapa di kejauhan; langit jingga | 480×270 px (integer-scaled), PNG | `bg_teras_sore.png` | P0 |
| Latar teras – senja | Komposisi sama, langit ungu, lampu pelita menyala | 480×270 px, PNG | `bg_teras_senja.png` | P0 |
| Latar teras – hampir malam | Langit gelap, bintang pertama muncul; dipakai saat energi rendah | 480×270 px, PNG | `bg_teras_malam.png` | P1 |
| Layer depan (foreground) | Rumpun daun, pagar bambu di tepi layar | PNG transparan | `fg_daun.png` | P2 |
| Layer langit dan awan | Awan bergerak pelan; layer terpisah agar bisa digeser | PNG transparan, tileable | `sky_clouds.png` | P2 |
| Ilustrasi ending menang | Halaman rumah, anak-anak desa duduk melingkar bersama Nenek | 480×270 px, PNG | `end_win.png` | P0 |
| Ilustrasi ending kalah | Teras kosong dengan lampu pelita menyala | 480×270 px, PNG | `end_lose.png` | P0 |
| Sprite Nenek – netral (idle) | Duduk di tikar, tangan di pangkuan, napas naik turun (2 frame) | 96×96 px, spritesheet PNG | `nenek_idle.png` | P0 |
| Sprite Nenek – bercerita | Mulut bergerak, tangan sedikit terangkat | 96×96 px, 4 frame | `nenek_talk.png` | P0 |
| Sprite Nenek – senang | Mata menyipit tersenyum, mengangguk | 96×96 px, 2–4 frame | `nenek_happy.png` | P0 |
| Sprite Nenek – mengoreksi | Menggeleng pelan, telunjuk terangkat | 96×96 px, 2–4 frame | `nenek_correct.png` | P0 |
| Sprite Nenek – lelah | Bahu turun, batuk kecil, mata setengah tertutup | 96×96 px, 4 frame | `nenek_tired.png` | P0 |
| Sprite Nenek – gestur menunjuk | Menunjuk ke kiri, kanan, dan bawah (3 arah) | 96×96 px, 3 pose | `nenek_gesture_point.png` | P0 |
| Sprite Nenek – gestur memperagakan | Menumbuk, menganyam, mengaduk periuk (loop) | 96×96 px, 4 frame/gestur | `nenek_gesture_act.png` | P1 |
| Ikon benda (20 buah) | 20 benda/konsep sesuai daftar kata Banjar | 32×32 px, PNG (normal & highlight) | `icon_*.png`, `icon_*_hl.png` | P0 |
| UI – bar energi | Frame kayu dengan isi hijau-kuning-merah, ikon pelita di ujung | Sprite 9-slice, PNG | `ui_energy_bar.png` | P0 |
| UI – penghitung kata | Pelat kecil bertuliskan `"7/15"` | PNG + font pixel | `ui_counter.png` | P0 |
| UI – buku kosakata | Ikon buku tertutup; halaman terbuka dengan kolom kata, ikon benda, 4 tombol jawaban | Beberapa sprite PNG | `ui_book_closed.png`, `ui_book_open.png` | P0 |
| UI – ikon status kata | Belum ditebak, benar (centang daun), terlewat (silang kecil) | 16×16 px, 3 ikon | `ui_status_*.png` | P0 |
| UI – kotak dialog | Panel kertas atau kayu dengan label nama `"Nenek Wati"` di pojok | Sprite 9-slice, PNG | `ui_dialog.png` | P0 |
| UI – tombol pertanyaan | 3–4 tombol dengan ikon kecil dan sisa kuota `"4/6"` | PNG, 3 state | `ui_btn_question.png` | P0 |
| UI – indikator kepercayaan | Tiga ikon hati atau daun yang terisi/kosong | 16×16 px | `ui_trust.png` | P1 |
| Efek visual | Percikan saat kata terkunci, kunang-kunang di ending menang, vignette gelap | Spritesheet kecil / shader | `fx_*.png` | P2 |

### 8.3 Aset Audio
*(Catatan: Sulih suara penutur asli tidak disertakan pada versi 1.0).*

| Aset | Contoh isi / deskripsi | Spesifikasi saran | Nama file | Prio |
| :--- | :--- | :--- | :--- | :--- |
| Musik latar utama | Kecapi atau suling pelan, 60–70 BPM, loop 60–90 detik (normal & melambat) | OGG, sekitar −16 LUFS | `bgm_main.ogg`, `bgm_slow.ogg` | P0 |
| Musik ending menang | Melodi naik dan hangat | 15–25 detik, OGG | `bgm_win.ogg` | P0 |
| Musik ending kalah | Satu nada suling panjang dan sepi | 15–25 detik, OGG | `bgm_lose.ogg` | P0 |
| Ambience jangkrik | Jangkrik malam, loop tanpa terputus | 30–60 detik, OGG | `amb_cricket.ogg` | P1 |
| Ambience ayam dan alam | Ayam berkokok jauh, angin, gesekan daun | 30–60 detik, OGG | `amb_village.ogg` | P1 |
| SFX menulis di buku | Bunyi pena menggores kertas | 0,3–0,5 detik, OGG | `sfx_write.ogg` | P0 |
| SFX buka/tutup buku | Halaman dibuka dan ditutup | 0,2–0,4 detik, OGG | `sfx_book_open.ogg`, `sfx_book_close.ogg` | P1 |
| SFX klik tombol | Ketukan kayu halus | 0,1–0,2 detik, OGG | `sfx_click.ogg` | P0 |
| SFX tebakan benar | Denting lembut dua nada | 0,3–0,8 detik, OGG | `sfx_correct.ogg` | P0 |
| SFX tebakan salah | Bunyi tumpul rendah, bukan buzzer | 0,3–0,8 detik, OGG | `sfx_wrong.ogg` | P0 |
| SFX Nenek (batuk, tawa, napas) | Batuk kecil, tawa pelan, helaan napas | 2–3 variasi per jenis | `sfx_nenek_cough_01.ogg`, ... | P1 |

### 8.4 Aset Teks, Data, dan Halaman Rilis

| Aset | Isi / Deskripsi | Nama file | Prio |
| :--- | :--- | :--- | :--- |
| Data konten | 20 kata Banjar, naskah 10 segmen, reaksi, jawaban pertanyaan, tutorial, ending, tuning | `data/words.json`, `data/story.json`, `data/dialog_reaction.json`, `data/dialog_questions.json`, `data/tutorial.json`, `data/endings.json`, `data/config.json` | P0 |
| Font & Palet | Font pixel terbaca jelas (mendukung karakter Indonesia) & palet 16–24 warna | `font_main.ttf`, `palette.png` / `palette.txt` | P0 |
| Aset dummy prototipe | Kotak berwarna & bunyi sementara untuk pengujian loop inti | `placeholder_*` | P0 |
| Lisensi dan kredit | Catatan lisensi font, musik, aset pihak ketiga, serta kredit validasi bahasa Banjar | `credits.txt` | P0 |
| Gambar sampul itch.io | Ilustrasi Nenek di teras dengan judul (`1280×720 px`) | `cover.png` | **P0 (19 Nov)** |
| Tangkapan layar itch.io | 3–5 tangkapan layar: tebakan, buku, energi rendah, ending (`1280×720 px`) | `shot_01.png` ... | **P0 (19 Nov)** |
| Ikon aplikasi dan logo | Logo judul `"Tutur Terakhir"` (`512×512 px`) | `logo.png`, `app_icon.png` | P1 |

---

## 9. Teknis

- **Engine & Platform:** **Godot 4.5** (`GL Compatibility`) dengan target **Web Export (HTML5)** untuk **desktop browser** di **itch.io**.
- **Performa:** muat di bawah 5 detik pada 4G; lancar di perangkat menengah; ukuran build di bawah 50 MB.
- **Data:** konten kata dan cerita dalam file JSON terpisah (`data/*.json`); nilai tuning (energi, kepercayaan) di `data/config.json`.
- **Penyimpanan:** menyimpan pengaturan volume/ukuran teks serta status **pembukaan Mode `Akamsi`** (terbuka setelah menang di Mode Normal) secara lokal (`user://save.cfg`).
- **Catatan Web Export:** uji kompatibilitas thread/Single-Threaded Web Export atau aktifkan *SharedArrayBuffer support* di pengaturan proyek itch.io sejak awal.

---

## 10. Penyeimbangan dan Playtest

- Sasaran tingkat menang percobaan pertama: **30–50%**.
- Sasaran: kurang dari **10%** kata dinilai *"tidak adil"* atau tidak bisa ditebak.
- Sasaran durasi: **5–8 menit**; sesi yang selesai kurang dari 4 menit atau lebih dari 9 menit menandakan tuning perlu diubah.
- Variabel utama yang disetel: pengurasan pasif, penalti salah tebak, jumlah pertanyaan, jumlah pengecoh.
- Pertanyaan playtest: apakah momen *"aha!"* terasa, apakah tempo membosankan, apakah ending menyentuh.

---

## 11. Cakupan dan Jadwal

### 11.1 MVP
Satu sesi lengkap: satu cerita (10 segmen), 20 kata bahasa Banjar, buku kosakata (pilihan ganda), sistem energi dan kepercayaan, 6 pertanyaan, ending menang dan kalah, pixel art dan audio dasar, **Mode Normal** + **Mode `Akamsi`** (terkunci sampai Mode Normal selesai; ditargetkan aktif penuh pada rilis 29 Nov).

### 11.2 Tahapan & Timeline Nyata (11–29 November 2026)

| Fase | Rentang Tanggal | Fokus & Deliverable Utama |
| :--- | :--- | :--- |
| **1. Konten & Bahasa** | 11–13 Nov | Finalisasi 20 kata bahasa Banjar (validasi penutur asli), 3 pengecoh per kata, dan naskah 10 segmen cerita (`data/*.json`). |
| **2. Core Prototype** | 13–15 Nov | Loop inti di Godot 4.5 (dialog, buku kosakata pilihan ganda, energi, kepercayaan, pertanyaan, ending) dengan aset placeholder + tes awal Web Export ke itch.io. |
| **3. Aset Seleksi & Halaman Itch.io** | 16–19 Nov | Aset visual inti (`bg_teras_sore/senja`, sprite dasar Nenek, UI panel, 5–10 ikon), `cover.png` (`1280×720`), 3–5 screenshot, dan **publikasi halaman itch.io + build seleksi (19 Nov)**. |
| **4. Produksi Penuh** | 20–24 Nov | Lengkapi seluruh 20 ikon benda, sisa sprite gestur Nenek, latar malam, ilustrasi `end_win`/`end_lose`, dan seluruh aset audio (BGM + SFX). |
| **5. Playtest & Polish** | 25–27 Nov | Uji pemain, tuning `config.json` (target durasi 5–8 menit, win rate 30–50%), perbaikan tempo & efek visual. |
| **6. Final Rilis** | 28–29 Nov | Finalisasi `credits.txt`, verifikasi build Web HTML5 (`< 50 MB`), upload build final ke itch.io (**batas akhir 29 Nov**). |

### 11.3 Pengembangan Lanjutan (Pasca-Rilis)
- Seri *"Bahasa Nusantara"* dengan bahasa, penutur, dan memori baru.
- Mode kelas dengan panduan guru.
- Kolaborasi dengan komunitas penutur asli untuk konten dan sulih suara.

---

## 12. Evaluasi Konsep Awal

| Kriteria | Skor | Catatan |
| :--- | :--- | :--- |
| Clarity | 4 | Pitch ringkas dan mudah dipahami |
| Originality | 4 | Perpaduan puzzle bahasa, pelestarian bahasa Banjar, dan energi penutur sebagai batas waktu |
| Player Fantasy | 3 | Rasa *"menemukan arti"* dan haru kuat; perlu variasi ritme dan momen *"aha!"* yang tegas |
| Scalability | 4 | Berbasis data JSON; mudah dikembangkan menjadi seri *"Bahasa Nusantara"* |

---

## 13. Risiko dan Keputusan Terkunci

### 13.1 Risiko & Mitigasi

| Risiko | Mitigasi |
| :--- | :--- |
| Tempo terlalu pelan | Variasi ritme cerita, interaksi mikro, momen *"aha!"* |
| Kata tidak adil ditebak | Playtest, petunjuk berlapis (minimal 2 kemunculan), pengecoh yang masuk akal |
| Akurasi bahasa dan budaya | Validasi langsung oleh pengembang selaku penutur asli bahasa Banjar |
| Cakupan membengkak / mepet deadline | Kunci scope MVP: satu cerita, satu bahasa, pilihan ganda, tanpa sulih suara, tanpa progression |

### 13.2 Keputusan Pertanyaan Terbuka (Terkunci di v0.2)
1. **Bahasa:** Bahasa daerah nyata (**Bahasa Banjar**), divalidasi langsung oleh pengembang (penutur asli Banjar).
2. **Mekanik Tebakan:** **Pilihan ganda** (4 opsi per kata, maks 2 percobaan).
3. **Sulih Suara:** **Tidak perlu** di versi pertama (v1.0).
4. **Platform Prioritas:** **Desktop (Web HTML5)**.
