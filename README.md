# Melestarikan: Tutur Terakhir

Puzzle kata naratif tempat kamu merekam **bahasa Banjar** dari penutur terakhir sebelum ceritanya berakhir.

Duduk bersama Nenek Wati di pelataran rumahnya saat senja. Tebak makna kata dari gestur, benda di sekitar, dan alur cerita — bukan dari terjemahan langsung.

## Mode permainan

| Mode | Isi |
| :--- | :--- |
| **Pendatang** | Cerita berbahasa Indonesia + 20 kata Banjar bergaris bawah. Cocok untuk pemain baru. |
| **Akamsi** | Dialog Banjar **berbeda** (bukan terjemahan 1:1), campuran **10 kata lama + 10 kata baru**. Tebak dari gestur, ikon, dan pertanyaan. Terbuka setelah tamat Mode Pendatang (≥15/20 benar). |

## Cara main

1. Dengarkan cerita Nenek; kata Banjar bergaris bawah masuk ke Buku Kosakata.
2. Amati gestur Nenek dan ikon benda yang tersorot.
3. Boleh bertanya (terbatas) untuk petunjuk — tanpa diberi arti langsung.
4. Tebak arti di buku (maks. 2 percobaan per kata).
5. Catat minimal **15 dari 20** kata sebelum energi Nenek habis.

Kontrol: klik / Spasi untuk dialog; A/D atau tombol untuk berjalan di scene pendekatan.

## Menjalankan

- **Engine:** Godot 4.x
- Buka `project.godot` di Godot Editor, lalu Play (`F5`).
- Target utama: **Web (HTML5)** / desktop browser — lihat [EXPORT_WEB.md](EXPORT_WEB.md).

## Struktur

```
data/          # Cerita, kosakata, pertanyaan, ending, config
scenes/        # Title, approach, main game, vocab, ending
scripts/       # Autoload (GameState, GameData, …) + PixelArt procedural
```

## Kredit

Bahasa Banjar divalidasi langsung oleh pengembang selaku penutur asli. Representasi budaya dibuat dengan hormat.

Detail desain: [GDD.md](GDD.md).
