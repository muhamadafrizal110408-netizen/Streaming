# Sinema Saku

Web streaming video-on-demand sederhana. Video ditambahkan lewat **tautan** (YouTube, Vimeo, atau file .mp4 langsung), bukan upload file. Akun & seluruh data disimpan di browser (localStorage) — cocok untuk proyek personal/demo, bukan untuk data sensitif.

## Peran akun
- **dev** (`dev` / `dev123` bawaan): akses penuh Panel Dev — tambah/edit/hapus video, kelola akun & role, lihat statistik, ekspor/impor data, ganti sandi sendiri.
- **editor**: bisa ditunjuk oleh dev lewat tab "Akun" di Panel Dev. Bisa tambah & edit video, tapi tidak bisa menghapus video atau mengelola akun lain.
- **user** (akun yang daftar sendiri): hanya menonton, tidak punya akses Panel Dev.

## Fitur
- Kategori, tag, durasi, season/episode, gambar sampul & trailer per video
- Filter kategori/tag, sortir (terbaru / A-Z / populer / rating tertinggi), pencarian judul
- Lanjutkan nonton otomatis (khusus tautan file video langsung — YouTube/Vimeo dimulai dari perkiraan waktu terakhir lewat parameter start)
- Watchlist, favorit, rating bintang, komentar per video (komentar & rating tersimpan **per-browser**, tidak dibagikan ke pengunjung lain)
- Video serupa berdasarkan kategori/tag yang sama
- Lupa sandi lewat pertanyaan keamanan, ganti username/sandi/avatar sendiri
- Panel Dev: statistik ringkas, kelola akun & role, ekspor/impor seluruh data sebagai file JSON (buat backup manual)
- Dark/light mode, notifikasi toast, animasi modal, bisa di-"install" ke homescreen (PWA)

## Batasan penting
- Semua data (akun, video, komentar, rating, riwayat) tersimpan di **localStorage browser** — per-perangkat/per-browser, tidak sinkron antar pengunjung, dan hilang kalau cache dibersihkan.
- Sandi disimpan sebagai teks biasa, **tidak aman** untuk data penting.
- Karena GitHub Pages hanya hosting statis, ini bukan sistem akun/server sungguhan. Fitur seperti "komentar" cuma kelihatan di browser yang sama dengan yang nulis — kalau mau beneran dibagikan ke semua pengunjung, butuh backend/database asli (misal Firebase/Supabase).

## Batasan penting
- Data akun & video tersimpan di **localStorage browser** — artinya data ini **per-perangkat/per-browser**, tidak sinkron antar pengunjung, dan hilang kalau cache dibersihkan.
- Sandi disimpan sebagai teks biasa, **tidak aman** untuk data penting. Jangan pakai sandi yang dipakai di akun lain.
- Karena GitHub Pages hanya hosting statis, ini bukan sistem akun/server sungguhan — cocok untuk demo, portofolio, atau koleksi tontonan pribadi.

## Deploy ke GitHub Pages
1. Buat repository baru di GitHub (bisa public atau private, tapi GitHub Pages gratis butuh public untuk akun non-Pro).
2. Upload semua file ini ke repo: `index.html`, `style.css`, `app.js`, `manifest.json`, `sw.js`, `icon.svg` (dan `README.md` kalau mau). File `index-standalone.html` tidak perlu diupload — itu cuma buat preview cepat.
3. Buka **Settings → Pages** di repo tersebut.
4. Di bagian **Source**, pilih branch `main` dan folder `/ (root)`, lalu klik **Save**.
5. Tunggu 1-2 menit, GitHub akan memberi URL seperti `https://namamu.github.io/nama-repo/`.
6. Buka URL itu — situs sudah jalan.

### Via terminal (opsional)
```bash
git init
git add .
git commit -m "Sinema Saku pertama"
git branch -M main
git remote add origin https://github.com/USERNAME/NAMA-REPO.git
git push -u origin main
```
Lalu aktifkan Pages seperti langkah 3-5 di atas.
