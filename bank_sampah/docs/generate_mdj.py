#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generator BankSampahActivityDiagram.mdj untuk StarUML
Mengonversi 18 Activity Diagram ke format StarUML (.mdj)
"""

import json
import uuid
import os

def new_id():
    return "AAAAAAAAAA" + str(uuid.uuid4()).upper().replace("-", "")[:30]

# ============================================================
# DEFINISI SEMUA 18 DIAGRAM
# Format node: (id_lokal, tipe, label, lane)
# tipe: initial | final | action | decision
# Format edge: (from_id, to_id, guard)
# ============================================================

DIAGRAMS = [

# ─────────────────────────────────────────────
# 01. LOGIN
# ─────────────────────────────────────────────
{
"name": "01 - Login",
"nodes": [
    ("A",  "initial",  "Start",                                             "Admin"),
    ("B",  "action",   "Membuka halaman Login",                             "Admin"),
    ("C",  "action",   "Mengisi username dan password",                     "Admin"),
    ("D",  "action",   "Klik tombol Login",                                 "Admin"),
    ("E",  "action",   "Menampilkan form Login",                            "Sistem"),
    ("F",  "decision", "Kolom username atau password kosong?",              "Sistem"),
    ("G",  "action",   "Menampilkan pesan kolom harus diisi",               "Sistem"),
    ("H",  "action",   "Melakukan query data pengguna ke database",         "Sistem"),
    ("I",  "decision", "Username ditemukan di database?",                   "Sistem"),
    ("J",  "action",   "Menampilkan pesan username atau password salah",    "Sistem"),
    ("K",  "decision", "Password sesuai dengan hash di database?",          "Sistem"),
    ("L",  "decision", "Level pengguna adalah Admin?",                      "Sistem"),
    ("M",  "action",   "Menampilkan pesan akses ditolak bukan Admin",       "Sistem"),
    ("N",  "action",   "Membuat data session pengguna",                     "Sistem"),
    ("O",  "action",   "Mengarahkan ke halaman Dashboard",                  "Sistem"),
    ("P",  "final",    "End",                                               "Sistem"),
],
"edges": [
    ("A","B",""), ("B","E",""), ("E","C",""), ("C","D",""), ("D","F",""),
    ("F","G","Ya"), ("G","C",""), ("F","H","Tidak"),
    ("H","I",""), ("I","J","Tidak"), ("J","C",""),
    ("I","K","Ya"), ("K","J","Tidak"), ("K","L","Ya"),
    ("L","M","Tidak"), ("M","C",""), ("L","N","Ya"),
    ("N","O",""), ("O","P",""),
]
},

# ─────────────────────────────────────────────
# 02. LOGOUT
# ─────────────────────────────────────────────
{
"name": "02 - Logout",
"nodes": [
    ("A", "initial",  "Start",                                    "Admin"),
    ("B", "action",   "Mengklik menu Logout",                     "Admin"),
    ("E", "final",    "End",                                      "Admin"),
    ("C", "action",   "Menghapus seluruh data session pengguna",  "Sistem"),
    ("D", "action",   "Mengarahkan ke halaman Login",             "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""),
]
},

# ─────────────────────────────────────────────
# 03. RESET PASSWORD
# ─────────────────────────────────────────────
{
"name": "03 - Reset Password",
"nodes": [
    ("A",  "initial",  "Start",                                                  "Admin"),
    ("B",  "action",   "Membuka halaman Reset Password",                         "Admin"),
    ("C",  "action",   "Mengisi alamat email terdaftar",                         "Admin"),
    ("D",  "action",   "Klik tombol Kirim",                                      "Admin"),
    ("K",  "action",   "Membuka link reset password pada email",                 "Admin"),
    ("O",  "action",   "Mengisi password baru dan konfirmasi password",          "Admin"),
    ("P",  "action",   "Klik tombol Simpan Password Baru",                       "Admin"),
    ("E",  "action",   "Menampilkan form Reset Password",                        "Sistem"),
    ("F",  "decision", "Format email valid?",                                    "Sistem"),
    ("G",  "action",   "Menampilkan pesan format email tidak valid",             "Sistem"),
    ("H",  "decision", "Email terdaftar di database?",                           "Sistem"),
    ("I",  "action",   "Menampilkan pesan email tidak ditemukan",                "Sistem"),
    ("J",  "action",   "Membuat token reset dan menyimpan ke database",          "Sistem"),
    ("JJ", "action",   "Mengirimkan link reset password via email",              "Sistem"),
    ("L",  "action",   "Menampilkan pesan email berhasil dikirim",               "Sistem"),
    ("M",  "decision", "Token valid dan belum kedaluwarsa?",                     "Sistem"),
    ("N",  "action",   "Menampilkan pesan token tidak valid atau kadaluarsa",    "Sistem"),
    ("Q",  "action",   "Menampilkan form isi password baru",                     "Sistem"),
    ("R",  "decision", "Password baru dan konfirmasi cocok?",                    "Sistem"),
    ("S",  "action",   "Menampilkan pesan password tidak sesuai",                "Sistem"),
    ("T",  "action",   "Meng-hash dan menyimpan password baru ke database",      "Sistem"),
    ("U",  "action",   "Menghapus token reset dari database",                    "Sistem"),
    ("V",  "action",   "Menampilkan notifikasi password berhasil diubah",        "Sistem"),
    ("W",  "action",   "Mengarahkan ke halaman Login",                           "Sistem"),
    ("X",  "final",    "End",                                                    "Sistem"),
],
"edges": [
    ("A","B",""), ("B","E",""), ("E","C",""), ("C","D",""), ("D","F",""),
    ("F","G","Tidak"), ("G","C",""), ("F","H","Ya"),
    ("H","I","Tidak"), ("I","C",""), ("H","J","Ya"),
    ("J","JJ",""), ("JJ","L",""), ("L","K",""),
    ("K","M",""), ("M","N","Tidak"), ("N","X",""),
    ("M","Q","Ya"), ("Q","O",""), ("O","P",""), ("P","R",""),
    ("R","S","Tidak"), ("S","O",""), ("R","T","Ya"),
    ("T","U",""), ("U","V",""), ("V","W",""), ("W","X",""),
]
},

# ─────────────────────────────────────────────
# 04. DASHBOARD
# ─────────────────────────────────────────────
{
"name": "04 - Dashboard",
"nodes": [
    ("A", "initial",  "Start",                                         "Admin"),
    ("B", "action",   "Membuka halaman Dashboard",                     "Admin"),
    ("C", "decision", "Session login valid?",                          "Sistem"),
    ("D", "action",   "Mengarahkan ke halaman Login",                  "Sistem"),
    ("E", "action",   "Mengambil jumlah Penyetor dari database",       "Sistem"),
    ("F", "action",   "Mengambil jumlah Jenis Sampah dari database",   "Sistem"),
    ("G", "action",   "Menghitung total berat setoran bulan ini",      "Sistem"),
    ("H", "action",   "Menghitung total saldo bank sampah",            "Sistem"),
    ("I", "action",   "Menghitung jumlah Orders pending dan selesai",  "Sistem"),
    ("J", "action",   "Mengambil jumlah Picker dari database",         "Sistem"),
    ("K", "action",   "Mengambil 5 aktivitas transaksi terbaru",       "Sistem"),
    ("L", "action",   "Menampilkan seluruh statistik pada Dashboard",  "Sistem"),
    ("M", "final",    "End",                                           "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D","Tidak"), ("D","M",""),
    ("C","E","Ya"), ("E","F",""), ("F","G",""), ("G","H",""),
    ("H","I",""), ("I","J",""), ("J","K",""), ("K","L",""), ("L","M",""),
]
},

# ─────────────────────────────────────────────
# 05. KELOLA DATA PENYETOR (CRUD)
# ─────────────────────────────────────────────
{
"name": "05 - Kelola Data Penyetor",
"nodes": [
    ("A",    "initial",  "Start",                                                  "Admin"),
    ("B",    "action",   "Membuka halaman Data Penyetor",                          "Admin"),
    ("D",    "decision", "Memilih aksi",                                           "Admin"),
    ("E1",   "action",   "Mengisi kata kunci pencarian",                           "Admin"),
    ("E2",   "action",   "Klik tombol Cari",                                       "Admin"),
    ("T1",   "action",   "Mengisi form data Penyetor baru",                        "Admin"),
    ("T2",   "action",   "Klik tombol Simpan",                                     "Admin"),
    ("Edt1", "action",   "Memilih Penyetor yang akan diedit",                     "Admin"),
    ("Edt2", "action",   "Mengubah data pada form Edit Penyetor",                  "Admin"),
    ("Edt3", "action",   "Klik tombol Simpan Perubahan",                           "Admin"),
    ("H1",   "action",   "Memilih Penyetor yang akan dihapus",                    "Admin"),
    ("H2",   "action",   "Klik tombol Hapus",                                      "Admin"),
    ("H3",   "decision", "Konfirmasi penghapusan?",                               "Admin"),
    ("Sts1", "action",   "Mengklik badge Status Penyetor",                        "Admin"),
    ("C",    "action",   "Menampilkan daftar Penyetor dengan pagination",          "Sistem"),
    ("E3",   "action",   "Memfilter data Penyetor berdasarkan kata kunci",         "Sistem"),
    ("E4",   "action",   "Menampilkan hasil pencarian",                            "Sistem"),
    ("T3",   "action",   "Menampilkan form Tambah Penyetor",                       "Sistem"),
    ("T4",   "decision", "Data valid?",                                            "Sistem"),
    ("T5",   "action",   "Menyimpan data Penyetor baru ke database",               "Sistem"),
    ("T6",   "action",   "Menampilkan pesan error validasi",                       "Sistem"),
    ("Edt4", "action",   "Menampilkan form Edit Penyetor dengan data lama",        "Sistem"),
    ("Edt5", "decision", "Data valid?",                                            "Sistem"),
    ("Edt6", "action",   "Memperbarui data Penyetor di database",                  "Sistem"),
    ("Edt7", "action",   "Menampilkan pesan error validasi",                       "Sistem"),
    ("H4",   "action",   "Menampilkan dialog konfirmasi penghapusan",              "Sistem"),
    ("H5",   "action",   "Menghapus data Penyetor dari database",                  "Sistem"),
    ("Sts2", "action",   "Membalik status akun Penyetor di database",              "Sistem"),
    ("Sts3", "action",   "Menampilkan notifikasi status berhasil diubah",          "Sistem"),
    ("OK",   "action",   "Menampilkan notifikasi proses berhasil",                 "Sistem"),
    ("Z",    "final",    "End",                                                    "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","E1","Cari"), ("E1","E2",""), ("E2","E3",""), ("E3","E4",""), ("E4","D",""),
    ("D","T3","Tambah"), ("T3","T1",""), ("T1","T2",""), ("T2","T4",""),
    ("T4","T6","Tidak"), ("T6","T1",""), ("T4","T5","Ya"), ("T5","OK",""), ("OK","C",""),
    ("D","Edt1","Edit"), ("Edt1","Edt4",""), ("Edt4","Edt2",""), ("Edt2","Edt3",""),
    ("Edt3","Edt5",""), ("Edt5","Edt7","Tidak"), ("Edt7","Edt2",""),
    ("Edt5","Edt6","Ya"), ("Edt6","OK",""),
    ("D","H1","Hapus"), ("H1","H2",""), ("H2","H4",""), ("H4","H3",""),
    ("H3","H5","Ya"), ("H5","OK",""), ("H3","C","Tidak"),
    ("D","Sts1","Toggle Status"), ("Sts1","Sts2",""), ("Sts2","Sts3",""), ("Sts3","C",""),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 06. KELOLA DATA PICKER (CRUD)
# ─────────────────────────────────────────────
{
"name": "06 - Kelola Data Picker",
"nodes": [
    ("A",    "initial",  "Start",                                                 "Admin"),
    ("B",    "action",   "Membuka halaman Data Picker",                           "Admin"),
    ("D",    "decision", "Memilih aksi",                                          "Admin"),
    ("E1",   "action",   "Mengisi kata kunci pencarian",                          "Admin"),
    ("E2",   "action",   "Klik tombol Cari",                                      "Admin"),
    ("T1",   "action",   "Mengisi form data Picker baru",                         "Admin"),
    ("T2",   "action",   "Klik tombol Simpan",                                    "Admin"),
    ("Edt1", "action",   "Memilih Picker yang akan diedit",                       "Admin"),
    ("Edt2", "action",   "Mengubah data pada form Edit Picker",                   "Admin"),
    ("Edt3", "action",   "Klik tombol Simpan Perubahan",                          "Admin"),
    ("H1",   "action",   "Memilih Picker yang akan dihapus",                      "Admin"),
    ("H2",   "action",   "Klik tombol Hapus",                                     "Admin"),
    ("H3",   "decision", "Konfirmasi penghapusan?",                               "Admin"),
    ("Det1", "action",   "Memilih Picker yang akan dilihat detailnya",            "Admin"),
    ("C",    "action",   "Menampilkan daftar Picker dengan pagination",            "Sistem"),
    ("E3",   "action",   "Memfilter data Picker berdasarkan kata kunci",          "Sistem"),
    ("E4",   "action",   "Menampilkan hasil pencarian",                           "Sistem"),
    ("T3",   "action",   "Menampilkan form Tambah Picker",                        "Sistem"),
    ("T4",   "decision", "Data valid?",                                           "Sistem"),
    ("T5",   "action",   "Menyimpan data Picker baru ke database",                "Sistem"),
    ("T6",   "action",   "Menampilkan pesan error validasi",                      "Sistem"),
    ("Edt4", "action",   "Menampilkan form Edit Picker dengan data lama",         "Sistem"),
    ("Edt5", "decision", "Data valid?",                                           "Sistem"),
    ("Edt6", "action",   "Memperbarui data Picker di database",                   "Sistem"),
    ("Edt7", "action",   "Menampilkan pesan error validasi",                      "Sistem"),
    ("H4",   "action",   "Menampilkan dialog konfirmasi penghapusan",             "Sistem"),
    ("H5",   "action",   "Menghapus data Picker dari database",                   "Sistem"),
    ("Det2", "action",   "Menampilkan halaman detail data Picker",                "Sistem"),
    ("OK",   "action",   "Menampilkan notifikasi proses berhasil",                "Sistem"),
    ("Z",    "final",    "End",                                                   "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","E1","Cari"), ("E1","E2",""), ("E2","E3",""), ("E3","E4",""), ("E4","D",""),
    ("D","T3","Tambah"), ("T3","T1",""), ("T1","T2",""), ("T2","T4",""),
    ("T4","T6","Tidak"), ("T6","T1",""), ("T4","T5","Ya"), ("T5","OK",""), ("OK","C",""),
    ("D","Edt1","Edit"), ("Edt1","Edt4",""), ("Edt4","Edt2",""), ("Edt2","Edt3",""),
    ("Edt3","Edt5",""), ("Edt5","Edt7","Tidak"), ("Edt7","Edt2",""),
    ("Edt5","Edt6","Ya"), ("Edt6","OK",""),
    ("D","H1","Hapus"), ("H1","H2",""), ("H2","H4",""), ("H4","H3",""),
    ("H3","H5","Ya"), ("H5","OK",""), ("H3","C","Tidak"),
    ("D","Det1","Detail"), ("Det1","Det2",""), ("Det2","C",""),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 07. KELOLA EDUKASI - ARTIKEL (CRUD)
# ─────────────────────────────────────────────
{
"name": "07 - Kelola Edukasi Artikel",
"nodes": [
    ("A",    "initial",  "Start",                                            "Admin"),
    ("B",    "action",   "Membuka halaman Edukasi",                          "Admin"),
    ("D",    "decision", "Memilih aksi",                                     "Admin"),
    ("E1",   "action",   "Mengisi kata kunci pencarian",                     "Admin"),
    ("E2",   "action",   "Klik tombol Cari",                                 "Admin"),
    ("Baca1","action",   "Mengklik tombol Baca Selengkapnya",                "Admin"),
    ("T1",   "action",   "Mengisi judul, konten, dan gambar artikel",        "Admin"),
    ("T2",   "action",   "Klik tombol Simpan",                               "Admin"),
    ("Edt1", "action",   "Memilih artikel yang akan diedit",                 "Admin"),
    ("Edt2", "action",   "Mengubah data artikel pada form Edit",             "Admin"),
    ("Edt3", "action",   "Klik tombol Simpan Perubahan",                     "Admin"),
    ("H1",   "action",   "Memilih artikel yang akan dihapus",                "Admin"),
    ("H2",   "action",   "Klik tombol Hapus",                                "Admin"),
    ("H3",   "decision", "Konfirmasi penghapusan?",                          "Admin"),
    ("C",    "action",   "Menampilkan daftar konten Edukasi",                "Sistem"),
    ("E3",   "action",   "Memfilter konten berdasarkan judul dan isi",       "Sistem"),
    ("E4",   "action",   "Menampilkan hasil pencarian",                      "Sistem"),
    ("Baca2","action",   "Mengambil konten artikel via request AJAX",        "Sistem"),
    ("Baca3","action",   "Menampilkan konten lengkap pada modal pop-up",     "Sistem"),
    ("T3",   "action",   "Menampilkan form Tambah Artikel",                  "Sistem"),
    ("T4",   "decision", "Data valid?",                                      "Sistem"),
    ("T5",   "action",   "Menyimpan artikel baru ke database",               "Sistem"),
    ("T6",   "action",   "Menampilkan pesan error validasi",                 "Sistem"),
    ("Edt4", "action",   "Menampilkan form Edit Artikel dengan data lama",   "Sistem"),
    ("Edt5", "decision", "Data valid?",                                      "Sistem"),
    ("Edt6", "action",   "Memperbarui artikel di database",                  "Sistem"),
    ("Edt7", "action",   "Menampilkan pesan error validasi",                 "Sistem"),
    ("H4",   "action",   "Menampilkan dialog konfirmasi penghapusan",        "Sistem"),
    ("H5",   "action",   "Menghapus artikel dari database",                  "Sistem"),
    ("OK",   "action",   "Menampilkan notifikasi proses berhasil",           "Sistem"),
    ("Z",    "final",    "End",                                              "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","E1","Cari"), ("E1","E2",""), ("E2","E3",""), ("E3","E4",""), ("E4","D",""),
    ("D","Baca1","Baca"), ("Baca1","Baca2",""), ("Baca2","Baca3",""), ("Baca3","D",""),
    ("D","T3","Tambah Artikel"), ("T3","T1",""), ("T1","T2",""), ("T2","T4",""),
    ("T4","T6","Tidak"), ("T6","T1",""), ("T4","T5","Ya"), ("T5","OK",""), ("OK","C",""),
    ("D","Edt1","Edit"), ("Edt1","Edt4",""), ("Edt4","Edt2",""), ("Edt2","Edt3",""),
    ("Edt3","Edt5",""), ("Edt5","Edt7","Tidak"), ("Edt7","Edt2",""),
    ("Edt5","Edt6","Ya"), ("Edt6","OK",""),
    ("D","H1","Hapus"), ("H1","H2",""), ("H2","H4",""), ("H4","H3",""),
    ("H3","H5","Ya"), ("H5","OK",""), ("H3","C","Tidak"),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 08. KELOLA EDUKASI - VIDEO (CRUD)
# ─────────────────────────────────────────────
{
"name": "08 - Kelola Edukasi Video",
"nodes": [
    ("A",    "initial",  "Start",                                             "Admin"),
    ("B",    "action",   "Membuka halaman Edukasi",                           "Admin"),
    ("D",    "decision", "Memilih aksi",                                      "Admin"),
    ("T1",   "action",   "Mengisi judul dan konten deskripsi video",          "Admin"),
    ("T2",   "decision", "Pilih tipe sumber video",                           "Admin"),
    ("T3",   "action",   "Mengisi URL video YouTube",                         "Admin"),
    ("T4",   "action",   "Mengunggah file video dari komputer",               "Admin"),
    ("T5",   "action",   "Klik tombol Simpan",                                "Admin"),
    ("Edt1", "action",   "Memilih video yang akan diedit",                    "Admin"),
    ("Edt2", "action",   "Mengubah data video pada form Edit",                "Admin"),
    ("Edt3", "action",   "Klik tombol Simpan Perubahan",                      "Admin"),
    ("H1",   "action",   "Memilih video yang akan dihapus",                   "Admin"),
    ("H2",   "action",   "Klik tombol Hapus",                                 "Admin"),
    ("H3",   "decision", "Konfirmasi penghapusan?",                           "Admin"),
    ("C",    "action",   "Menampilkan daftar konten Edukasi",                 "Sistem"),
    ("TV1",  "action",   "Menampilkan form Tambah Video",                     "Sistem"),
    ("TV2",  "decision", "Data valid?",                                       "Sistem"),
    ("TV3",  "action",   "Menyimpan data video baru ke database",             "Sistem"),
    ("TV4",  "action",   "Menampilkan pesan error validasi",                  "Sistem"),
    ("Edt4", "action",   "Menampilkan form Edit Video dengan data lama",      "Sistem"),
    ("Edt5", "decision", "Data valid?",                                       "Sistem"),
    ("Edt6", "action",   "Memperbarui data video di database",                "Sistem"),
    ("Edt7", "action",   "Menampilkan pesan error validasi",                  "Sistem"),
    ("H4",   "action",   "Menampilkan dialog konfirmasi penghapusan",         "Sistem"),
    ("H5",   "action",   "Menghapus video dari database",                     "Sistem"),
    ("OK",   "action",   "Menampilkan notifikasi proses berhasil",            "Sistem"),
    ("Z",    "final",    "End",                                               "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","TV1","Tambah Video"), ("TV1","T1",""), ("T1","T2",""),
    ("T2","T3","URL YouTube"), ("T2","T4","Upload File"),
    ("T3","T5",""), ("T4","T5",""), ("T5","TV2",""),
    ("TV2","TV4","Tidak"), ("TV4","T1",""), ("TV2","TV3","Ya"),
    ("TV3","OK",""), ("OK","C",""),
    ("D","Edt1","Edit"), ("Edt1","Edt4",""), ("Edt4","Edt2",""), ("Edt2","Edt3",""),
    ("Edt3","Edt5",""), ("Edt5","Edt7","Tidak"), ("Edt7","Edt2",""),
    ("Edt5","Edt6","Ya"), ("Edt6","OK",""),
    ("D","H1","Hapus"), ("H1","H2",""), ("H2","H4",""), ("H4","H3",""),
    ("H3","H5","Ya"), ("H5","OK",""), ("H3","C","Tidak"),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 09. KELOLA JENIS SAMPAH (CRUD)
# ─────────────────────────────────────────────
{
"name": "09 - Kelola Jenis Sampah",
"nodes": [
    ("A",    "initial",  "Start",                                                   "Admin"),
    ("B",    "action",   "Membuka halaman Jenis Sampah",                            "Admin"),
    ("D",    "decision", "Memilih aksi",                                            "Admin"),
    ("E1",   "action",   "Memilih kategori dari dropdown filter",                   "Admin"),
    ("T1",   "action",   "Mengisi nama, kategori, harga, satuan, dan gambar",       "Admin"),
    ("T2",   "action",   "Klik tombol Simpan",                                      "Admin"),
    ("Edt1", "action",   "Memilih jenis sampah yang akan diedit",                   "Admin"),
    ("Edt2", "action",   "Mengubah data pada form Edit Jenis Sampah",               "Admin"),
    ("Edt3", "action",   "Klik tombol Simpan Perubahan",                            "Admin"),
    ("H1",   "action",   "Memilih jenis sampah yang akan dihapus",                  "Admin"),
    ("H2",   "action",   "Klik tombol Hapus",                                       "Admin"),
    ("H3",   "decision", "Konfirmasi penghapusan?",                                 "Admin"),
    ("C",    "action",   "Menampilkan daftar Jenis Sampah",                         "Sistem"),
    ("E2",   "action",   "Memfilter daftar berdasarkan kategori yang dipilih",      "Sistem"),
    ("E3",   "action",   "Menampilkan hasil filter kategori",                       "Sistem"),
    ("T3",   "action",   "Menampilkan form Tambah Jenis Sampah",                    "Sistem"),
    ("T4",   "decision", "Data valid?",                                             "Sistem"),
    ("T5",   "action",   "Menyimpan jenis sampah baru ke database",                 "Sistem"),
    ("T6",   "action",   "Menampilkan pesan error validasi",                        "Sistem"),
    ("Edt4", "action",   "Menampilkan form Edit Jenis Sampah dengan data lama",     "Sistem"),
    ("Edt5", "decision", "Data valid?",                                             "Sistem"),
    ("Edt6", "action",   "Memperbarui data jenis sampah di database",               "Sistem"),
    ("Edt7", "action",   "Menampilkan pesan error validasi",                        "Sistem"),
    ("H4",   "action",   "Menampilkan dialog konfirmasi penghapusan",               "Sistem"),
    ("H5",   "decision", "Jenis sampah digunakan dalam transaksi?",                 "Sistem"),
    ("H6",   "action",   "Menghapus jenis sampah dari database",                    "Sistem"),
    ("H7",   "action",   "Menampilkan pesan tidak dapat dihapus",                   "Sistem"),
    ("OK",   "action",   "Menampilkan notifikasi proses berhasil",                  "Sistem"),
    ("Z",    "final",    "End",                                                     "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","E1","Filter Kategori"), ("E1","E2",""), ("E2","E3",""), ("E3","D",""),
    ("D","T3","Tambah"), ("T3","T1",""), ("T1","T2",""), ("T2","T4",""),
    ("T4","T6","Tidak"), ("T6","T1",""), ("T4","T5","Ya"), ("T5","OK",""), ("OK","C",""),
    ("D","Edt1","Edit"), ("Edt1","Edt4",""), ("Edt4","Edt2",""), ("Edt2","Edt3",""),
    ("Edt3","Edt5",""), ("Edt5","Edt7","Tidak"), ("Edt7","Edt2",""),
    ("Edt5","Edt6","Ya"), ("Edt6","OK",""),
    ("D","H1","Hapus"), ("H1","H2",""), ("H2","H4",""), ("H4","H3",""),
    ("H3","H5","Ya"), ("H5","H7","Ya"), ("H7","C",""),
    ("H5","H6","Tidak"), ("H6","OK",""), ("H3","C","Tidak"),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 10. INPUT SETORAN SAMPAH
# ─────────────────────────────────────────────
{
"name": "10 - Input Setoran Sampah",
"nodes": [
    ("A", "initial",  "Start",                                               "Admin"),
    ("B", "action",   "Membuka halaman Input Setoran Sampah",                "Admin"),
    ("C", "action",   "Memilih nama Penyetor dari dropdown",                 "Admin"),
    ("D", "action",   "Memilih tanggal transaksi",                           "Admin"),
    ("E", "action",   "Memilih jenis sampah dan mengisi berat kg",           "Admin"),
    ("F", "decision", "Tambah item sampah lagi?",                            "Admin"),
    ("G", "action",   "Klik tombol Tambah Baris Item",                       "Admin"),
    ("H", "action",   "Klik tombol Simpan Transaksi",                        "Admin"),
    ("I", "action",   "Menampilkan form Input Setoran Sampah",               "Sistem"),
    ("J", "action",   "Memuat daftar Penyetor dan Jenis Sampah",             "Sistem"),
    ("K", "action",   "Menghitung subtotal tiap item secara otomatis",       "Sistem"),
    ("L", "action",   "Menghitung total nilai keseluruhan setoran",          "Sistem"),
    ("M", "decision", "Data transaksi valid?",                               "Sistem"),
    ("N", "action",   "Menampilkan pesan error validasi",                    "Sistem"),
    ("O", "action",   "Menyimpan transaksi ke tabel transaksi",              "Sistem"),
    ("P", "action",   "Menyimpan detail item ke tabel detail_setoran",       "Sistem"),
    ("Q", "action",   "Menambahkan saldo Penyetor sesuai total nilai",       "Sistem"),
    ("R", "action",   "Menampilkan notifikasi transaksi berhasil",           "Sistem"),
    ("S", "final",    "End",                                                 "Sistem"),
],
"edges": [
    ("A","B",""), ("B","I",""), ("I","J",""), ("J","C",""), ("C","D",""),
    ("D","E",""), ("E","K",""), ("K","F",""),
    ("F","G","Ya"), ("G","E",""), ("F","L","Tidak"),
    ("L","H",""), ("H","M",""), ("M","N","Tidak"), ("N","E",""),
    ("M","O","Ya"), ("O","P",""), ("P","Q",""), ("Q","R",""), ("R","S",""),
]
},

# ─────────────────────────────────────────────
# 11. INPUT PENARIKAN SALDO
# ─────────────────────────────────────────────
{
"name": "11 - Input Penarikan Saldo",
"nodes": [
    ("A", "initial",  "Start",                                                    "Admin"),
    ("B", "action",   "Membuka halaman Input Penarikan Saldo",                    "Admin"),
    ("C", "action",   "Memilih nama Penyetor dari dropdown",                      "Admin"),
    ("E", "action",   "Mengisi jumlah penarikan",                                 "Admin"),
    ("F", "action",   "Mengisi tanggal transaksi",                                "Admin"),
    ("G", "action",   "Mengisi keterangan opsional",                              "Admin"),
    ("H", "action",   "Klik tombol Simpan Transaksi",                             "Admin"),
    ("I", "action",   "Menampilkan form Input Penarikan Saldo",                   "Sistem"),
    ("J", "action",   "Memuat daftar Penyetor dari database",                     "Sistem"),
    ("D", "action",   "Menampilkan saldo aktif Penyetor yang dipilih",            "Sistem"),
    ("K", "decision", "Data transaksi valid?",                                    "Sistem"),
    ("L", "action",   "Menampilkan pesan error validasi",                         "Sistem"),
    ("M", "decision", "Jumlah penarikan melebihi saldo aktif?",                   "Sistem"),
    ("N", "action",   "Menampilkan pesan saldo tidak mencukupi",                  "Sistem"),
    ("O", "action",   "Menyimpan transaksi penarikan ke database",                "Sistem"),
    ("P", "action",   "Mengurangi saldo Penyetor sesuai jumlah penarikan",        "Sistem"),
    ("Q", "action",   "Menampilkan notifikasi penarikan berhasil",                "Sistem"),
    ("R", "final",    "End",                                                      "Sistem"),
],
"edges": [
    ("A","B",""), ("B","I",""), ("I","J",""), ("J","C",""), ("C","D",""),
    ("D","E",""), ("E","F",""), ("F","G",""), ("G","H",""), ("H","K",""),
    ("K","L","Tidak"), ("L","E",""),
    ("K","M","Ya"), ("M","N","Ya"), ("N","E",""),
    ("M","O","Tidak"), ("O","P",""), ("P","Q",""), ("Q","R",""),
]
},

# ─────────────────────────────────────────────
# 12. RIWAYAT TRANSAKSI
# ─────────────────────────────────────────────
{
"name": "12 - Riwayat Transaksi",
"nodes": [
    ("A", "initial",  "Start",                                                   "Admin"),
    ("B", "action",   "Membuka halaman Riwayat Transaksi",                       "Admin"),
    ("D", "action",   "Memilih filter Penyetor dari dropdown",                   "Admin"),
    ("E", "action",   "Memilih filter Tipe Transaksi",                           "Admin"),
    ("F", "action",   "Mengisi rentang tanggal mulai dan akhir",                 "Admin"),
    ("G", "action",   "Klik tombol Terapkan Filter",                             "Admin"),
    ("C", "action",   "Menampilkan semua riwayat transaksi setor dan tarik",     "Sistem"),
    ("H", "action",   "Membangun query berdasarkan kombinasi filter",            "Sistem"),
    ("I", "action",   "Menjalankan query ke database",                           "Sistem"),
    ("J", "action",   "Menampilkan hasil transaksi sesuai filter",               "Sistem"),
    ("K", "action",   "Menampilkan detail item sampah per transaksi setor",      "Sistem"),
    ("L", "final",    "End",                                                     "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""), ("E","F",""),
    ("F","G",""), ("G","H",""), ("H","I",""), ("I","J",""), ("J","K",""), ("K","L",""),
]
},

# ─────────────────────────────────────────────
# 13. KELOLA ORDERS PENJEMPUTAN
# ─────────────────────────────────────────────
{
"name": "13 - Kelola Orders Penjemputan",
"nodes": [
    ("A",  "initial",  "Start",                                                       "Admin"),
    ("B",  "action",   "Membuka halaman Orders Penjemputan",                          "Admin"),
    ("D",  "action",   "Memilih filter status order",                                 "Admin"),
    ("F",  "action",   "Memilih order untuk dilihat detailnya",                       "Admin"),
    ("H",  "action",   "Memilih order yang akan ditugaskan Picker",                   "Admin"),
    ("I",  "action",   "Memilih nama Picker dari dropdown",                           "Admin"),
    ("J",  "action",   "Klik tombol Assign Picker",                                   "Admin"),
    ("L",  "action",   "Memilih order yang akan divalidasi selesai",                  "Admin"),
    ("M",  "action",   "Klik tombol Konfirmasi Selesai",                              "Admin"),
    ("C",  "action",   "Menampilkan daftar semua Orders dari mobile",                 "Sistem"),
    ("E",  "action",   "Memfilter Orders berdasarkan status yang dipilih",            "Sistem"),
    ("G",  "action",   "Menampilkan halaman detail Order penjemputan",                "Sistem"),
    ("K",  "decision", "Penugasan Picker berhasil diproses?",                        "Sistem"),
    ("K1", "action",   "Memperbarui status Order menjadi DRIVER_DITUGASKAN",          "Sistem"),
    ("K2", "action",   "Menyimpan notifikasi penugasan ke database untuk Picker",     "Sistem"),
    ("K3", "action",   "Menyimpan notifikasi konfirmasi ke database untuk Penyetor",  "Sistem"),
    ("K4", "action",   "Menampilkan notifikasi penugasan Picker berhasil",            "Sistem"),
    ("K5", "action",   "Menampilkan pesan gagal memproses penugasan",                 "Sistem"),
    ("N",  "action",   "Memperbarui status Order menjadi VALIDASI_BANK_SAMPAH",       "Sistem"),
    ("O",  "action",   "Menampilkan notifikasi validasi berhasil",                    "Sistem"),
    ("Z",  "final",    "End",                                                         "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""), ("E","C",""),
    ("C","F",""), ("F","G",""), ("G","C",""),
    ("C","H",""), ("H","I",""), ("I","J",""), ("J","K",""),
    ("K","K1","Ya"), ("K1","K2",""), ("K2","K3",""), ("K3","K4",""), ("K4","C",""),
    ("K","K5","Tidak"), ("K5","C",""),
    ("C","L",""), ("L","M",""), ("M","N",""), ("N","O",""), ("O","C",""),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 14. KELOLA PENUKARAN POIN / REWARD
# ─────────────────────────────────────────────
{
"name": "14 - Kelola Penukaran Poin",
"nodes": [
    ("A",  "initial",  "Start",                                                       "Admin"),
    ("B",  "action",   "Membuka halaman Manajemen Tukar Poin",                        "Admin"),
    ("D",  "action",   "Memilih tab status pengajuan",                                "Admin"),
    ("F",  "action",   "Mengisi kata kunci atau rentang tanggal filter",              "Admin"),
    ("G",  "action",   "Klik tombol Filter",                                          "Admin"),
    ("H",  "action",   "Memilih pengajuan untuk dilihat detailnya",                   "Admin"),
    ("J",  "action",   "Klik tombol Selesaikan pada pengajuan",                       "Admin"),
    ("K",  "action",   "Mengunggah file bukti transfer",                              "Admin"),
    ("L",  "action",   "Klik tombol Konfirmasi Selesai",                              "Admin"),
    ("P",  "action",   "Klik tombol Tolak pada pengajuan",                            "Admin"),
    ("Q",  "action",   "Mengisi alasan penolakan pada form",                          "Admin"),
    ("R",  "action",   "Klik tombol Konfirmasi Tolak",                                "Admin"),
    ("C",  "action",   "Menampilkan daftar pengajuan Penukaran Poin",                 "Sistem"),
    ("E",  "action",   "Memfilter data berdasarkan status, kata kunci, dan tanggal",  "Sistem"),
    ("I",  "action",   "Menampilkan halaman detail pengajuan Penukaran Poin",         "Sistem"),
    ("M",  "decision", "File bukti transfer sudah diunggah?",                        "Sistem"),
    ("N",  "action",   "Menampilkan pesan bukti transfer wajib diunggah",             "Sistem"),
    ("O1", "action",   "Menyimpan file bukti transfer ke server",                     "Sistem"),
    ("O2", "action",   "Memperbarui status redemption menjadi completed",             "Sistem"),
    ("O3", "action",   "Memotong poin Penyetor secara permanen dari database",        "Sistem"),
    ("O4", "action",   "Mencatat aksi ke tabel audit log",                            "Sistem"),
    ("O5", "action",   "Menyimpan notifikasi berhasil ke database",                   "Sistem"),
    ("O6", "action",   "Menampilkan notifikasi penukaran berhasil diselesaikan",      "Sistem"),
    ("S",  "decision", "Alasan penolakan sudah diisi?",                              "Sistem"),
    ("T",  "action",   "Menampilkan pesan alasan penolakan wajib diisi",              "Sistem"),
    ("U1", "action",   "Memperbarui status redemption menjadi rejected",              "Sistem"),
    ("U2", "action",   "Mengembalikan poin ke saldo aktif Penyetor",                  "Sistem"),
    ("U3", "action",   "Mencatat aksi ke tabel audit log",                            "Sistem"),
    ("U4", "action",   "Menyimpan notifikasi penolakan ke database",                  "Sistem"),
    ("U5", "action",   "Menampilkan notifikasi penukaran berhasil ditolak",           "Sistem"),
    ("Z",  "final",    "End",                                                         "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","C",""),
    ("C","F",""), ("F","G",""), ("G","E",""), ("E","C",""),
    ("C","H",""), ("H","I",""), ("I","C",""),
    ("C","J",""), ("J","M",""),
    ("M","N","Tidak"), ("N","K",""), ("K","M",""),
    ("M","L","Ya"), ("L","O1",""), ("O1","O2",""), ("O2","O3",""),
    ("O3","O4",""), ("O4","O5",""), ("O5","O6",""), ("O6","C",""),
    ("C","P",""), ("P","Q",""), ("Q","R",""), ("R","S",""),
    ("S","T","Tidak"), ("T","Q",""),
    ("S","U1","Ya"), ("U1","U2",""), ("U2","U3",""), ("U3","U4",""), ("U4","U5",""), ("U5","C",""),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 15. LAPORAN HARIAN
# ─────────────────────────────────────────────
{
"name": "15 - Laporan Harian",
"nodes": [
    ("A", "initial",  "Start",                                                       "Admin"),
    ("B", "action",   "Membuka halaman Laporan Harian",                              "Admin"),
    ("D", "action",   "Memilih tanggal laporan dari date picker",                    "Admin"),
    ("E", "action",   "Klik tombol Tampilkan Laporan",                               "Admin"),
    ("J", "decision", "Ingin mengekspor laporan?",                                   "Admin"),
    ("K", "action",   "Klik tombol Ekspor PDF",                                      "Admin"),
    ("L", "action",   "Klik tombol Ekspor Excel",                                    "Admin"),
    ("C", "action",   "Menampilkan laporan hari ini secara default",                 "Sistem"),
    ("F", "action",   "Mengambil data setoran dan penarikan sesuai tanggal",         "Sistem"),
    ("F1","action",   "Menghitung total pemasukan setoran pada tanggal tersebut",    "Sistem"),
    ("F2","action",   "Menghitung total pengeluaran penarikan pada tanggal tersebut","Sistem"),
    ("F3","action",   "Menampilkan laporan harian sesuai tanggal yang dipilih",      "Sistem"),
    ("G", "decision", "Format ekspor",                                               "Sistem"),
    ("M", "action",   "Menghasilkan file PDF laporan harian",                        "Sistem"),
    ("N", "action",   "Mengunduh file PDF ke komputer Admin",                        "Sistem"),
    ("O", "action",   "Menghasilkan file Excel laporan harian",                      "Sistem"),
    ("P", "action",   "Mengunduh file Excel ke komputer Admin",                      "Sistem"),
    ("Q", "action",   "Menampilkan notifikasi unduhan berhasil",                     "Sistem"),
    ("Z", "final",    "End",                                                         "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""), ("E","F",""),
    ("F","F1",""), ("F1","F2",""), ("F2","F3",""), ("F3","J",""),
    ("J","G","Ya"),
    ("G","K","PDF"), ("K","M",""), ("M","N",""), ("N","Q",""), ("Q","Z",""),
    ("G","L","Excel"), ("L","O",""), ("O","P",""), ("P","Q",""),
    ("J","Z","Tidak"),
]
},

# ─────────────────────────────────────────────
# 16. LAPORAN BULANAN
# ─────────────────────────────────────────────
{
"name": "16 - Laporan Bulanan",
"nodes": [
    ("A", "initial",  "Start",                                                      "Admin"),
    ("B", "action",   "Membuka halaman Laporan Bulanan",                            "Admin"),
    ("D", "action",   "Memilih bulan dan tahun periode laporan",                    "Admin"),
    ("E", "action",   "Klik tombol Tampilkan Laporan",                              "Admin"),
    ("J", "decision", "Ingin mengekspor laporan?",                                  "Admin"),
    ("K", "action",   "Klik tombol Ekspor PDF",                                     "Admin"),
    ("L", "action",   "Klik tombol Ekspor Excel",                                   "Admin"),
    ("C", "action",   "Menampilkan laporan bulan dan tahun saat ini secara default","Sistem"),
    ("F", "action",   "Mengambil semua transaksi sesuai periode yang dipilih",      "Sistem"),
    ("F1","action",   "Menghitung total setoran sepanjang bulan tersebut",          "Sistem"),
    ("F2","action",   "Menghitung total penarikan sepanjang bulan tersebut",        "Sistem"),
    ("F3","action",   "Menampilkan ringkasan statistik dan tabel transaksi bulanan","Sistem"),
    ("G", "decision", "Format ekspor",                                              "Sistem"),
    ("M", "action",   "Menghasilkan file PDF laporan bulanan",                      "Sistem"),
    ("N", "action",   "Mengunduh file PDF ke komputer Admin",                       "Sistem"),
    ("O", "action",   "Menghasilkan file Excel laporan bulanan",                    "Sistem"),
    ("P", "action",   "Mengunduh file Excel ke komputer Admin",                     "Sistem"),
    ("Q", "action",   "Menampilkan notifikasi unduhan berhasil",                    "Sistem"),
    ("Z", "final",    "End",                                                        "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""), ("E","F",""),
    ("F","F1",""), ("F1","F2",""), ("F2","F3",""), ("F3","J",""),
    ("J","G","Ya"),
    ("G","K","PDF"), ("K","M",""), ("M","N",""), ("N","Q",""), ("Q","Z",""),
    ("G","L","Excel"), ("L","O",""), ("O","P",""), ("P","Q",""),
    ("J","Z","Tidak"),
]
},

# ─────────────────────────────────────────────
# 17. KELOLA PROFIL ADMIN
# ─────────────────────────────────────────────
{
"name": "17 - Kelola Profil Admin",
"nodes": [
    ("A",  "initial",  "Start",                                                   "Admin"),
    ("B",  "action",   "Membuka halaman Profil Admin",                            "Admin"),
    ("D",  "decision", "Memilih aksi",                                            "Admin"),
    ("E1", "action",   "Mengubah nama lengkap, alamat, dan nomor telepon",        "Admin"),
    ("E2", "action",   "Klik tombol Simpan Perubahan Profil",                     "Admin"),
    ("P1", "action",   "Mengisi password lama saat ini",                          "Admin"),
    ("P2", "action",   "Mengisi password baru dan konfirmasi password baru",      "Admin"),
    ("P3", "action",   "Klik tombol Ganti Password",                              "Admin"),
    ("C",  "action",   "Menampilkan data profil Admin saat ini dari database",    "Sistem"),
    ("E3", "action",   "Menampilkan form Edit Profil",                            "Sistem"),
    ("E4", "decision", "Data profil valid?",                                      "Sistem"),
    ("E5", "action",   "Memperbarui data profil di database",                     "Sistem"),
    ("E6", "action",   "Memperbarui nama pada data session",                      "Sistem"),
    ("E7", "action",   "Menampilkan notifikasi profil berhasil diperbarui",       "Sistem"),
    ("E8", "action",   "Menampilkan pesan error validasi",                        "Sistem"),
    ("P4", "decision", "Password lama cocok dengan hash di database?",            "Sistem"),
    ("P5", "action",   "Menampilkan pesan password lama tidak sesuai",            "Sistem"),
    ("P6", "decision", "Password baru dan konfirmasi cocok?",                     "Sistem"),
    ("P7", "action",   "Menampilkan pesan konfirmasi password tidak sesuai",      "Sistem"),
    ("P8", "action",   "Meng-hash password baru",                                 "Sistem"),
    ("P9", "action",   "Menyimpan password baru ke database",                     "Sistem"),
    ("P10","action",   "Menampilkan notifikasi password berhasil diubah",         "Sistem"),
    ("Z",  "final",    "End",                                                     "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""),
    ("D","E3","Edit Profil"), ("E3","E1",""), ("E1","E2",""), ("E2","E4",""),
    ("E4","E8","Tidak"), ("E8","E1",""),
    ("E4","E5","Ya"), ("E5","E6",""), ("E6","E7",""), ("E7","C",""),
    ("D","P1","Ganti Password"), ("P1","P2",""), ("P2","P3",""), ("P3","P4",""),
    ("P4","P5","Tidak"), ("P5","P1",""),
    ("P4","P6","Ya"), ("P6","P7","Tidak"), ("P7","P1",""),
    ("P6","P8","Ya"), ("P8","P9",""), ("P9","P10",""), ("P10","C",""),
    ("C","Z",""),
]
},

# ─────────────────────────────────────────────
# 18. MONITOR AI SCAN LIVE
# ─────────────────────────────────────────────
{
"name": "18 - Monitor AI Scan Live",
"nodes": [
    ("A",    "initial",  "Start",                                                     "Admin"),
    ("B",    "action",   "Membuka halaman Monitor AI Scan",                           "Admin"),
    ("C",    "action",   "Menampilkan halaman Monitor AI Scan",                       "Sistem"),
    ("D",    "action",   "Melakukan request ke endpoint data deteksi",                "Sistem"),
    ("E",    "decision", "Request berhasil?",                                         "Sistem"),
    ("F",    "action",   "Mencatat error koneksi di console browser",                 "Sistem"),
    ("G",    "decision", "Terdapat data deteksi dari database?",                      "Sistem"),
    ("H",    "action",   "Menampilkan pesan belum ada aktivitas scan",                "Sistem"),
    ("I",    "decision", "Data berbeda dari polling sebelumnya?",                     "Sistem"),
    ("J",    "action",   "Tidak memperbarui tampilan untuk mencegah flicker",         "Sistem"),
    ("K",    "action",   "Merender kartu hasil deteksi AI terbaru",                   "Sistem"),
    ("KK",   "action",   "Menampilkan gambar yang dipindai pengguna Mobile",          "Sistem"),
    ("L",    "action",   "Menampilkan label klasifikasi sampah dari model AI",        "Sistem"),
    ("M",    "action",   "Menampilkan nama pengguna dan waktu scan",                  "Sistem"),
    ("N",    "action",   "Menandai deteksi terbaru dengan badge NEW",                 "Sistem"),
    ("O",    "action",   "Menunggu 3 detik sebelum polling berikutnya",               "Sistem"),
    ("Z",    "final",    "End",                                                       "Sistem"),
],
"edges": [
    ("A","B",""), ("B","C",""), ("C","D",""), ("D","E",""),
    ("E","F","Tidak"), ("F","O",""),
    ("E","G","Ya"), ("G","H","Tidak ada data"), ("H","O",""),
    ("G","I","Ada data"), ("I","J","Tidak berbeda"), ("J","O",""),
    ("I","K","Ada perubahan"), ("K","KK",""), ("KK","L",""), ("L","M",""), ("M","N",""), ("N","O",""),
    ("O","Z",""),
]
},

]  # end DIAGRAMS


# ============================================================
# FUNGSI BUILDER MDJ
# ============================================================

def build_mdj(diagrams):
    """Membangun struktur JSON lengkap untuk file .mdj StarUML"""

    project_id  = new_id()
    model_id    = new_id()

    root = {
        "_type": "Project",
        "_id":   project_id,
        "name":  "BankSampahActivityDiagram",
        "ownedElements": [
            {
                "_type": "UMLModel",
                "_id":   model_id,
                "name":  "Activity Diagram Bank Sampah",
                "_parent": {"$ref": project_id},
                "ownedElements": []
            }
        ]
    }

    model_elem = root["ownedElements"][0]

    for diag in diagrams:
        act_id = new_id()

        # Buat peta: id_lokal -> id_unik StarUML
        id_map = {}
        elements = []          # model elements (nodes + edges)

        # ── Buat partisi swimlane ──
        part_admin_id  = new_id()
        part_sistem_id = new_id()

        part_admin = {
            "_type":   "UMLActivityPartition",
            "_id":     part_admin_id,
            "name":    "Admin",
            "_parent": {"$ref": act_id},
        }
        part_sistem = {
            "_type":   "UMLActivityPartition",
            "_id":     part_sistem_id,
            "name":    "Sistem",
            "_parent": {"$ref": act_id},
        }
        elements.append(part_admin)
        elements.append(part_sistem)

        partition_map = {"Admin": part_admin_id, "Sistem": part_sistem_id}

        # ── Buat nodes ──
        for (local_id, ntype, label, lane) in diag["nodes"]:
            uid = new_id()
            id_map[local_id] = uid
            pid  = partition_map[lane]

            if ntype == "initial":
                node = {
                    "_type":   "UMLInitialNode",
                    "_id":     uid,
                    "name":    "",
                    "_parent": {"$ref": act_id},
                    "inPartition": [{"$ref": pid}]
                }
            elif ntype == "final":
                node = {
                    "_type":   "UMLActivityFinalNode",
                    "_id":     uid,
                    "name":    "",
                    "_parent": {"$ref": act_id},
                    "inPartition": [{"$ref": pid}]
                }
            elif ntype == "decision":
                node = {
                    "_type":   "UMLDecisionNode",
                    "_id":     uid,
                    "name":    label,
                    "_parent": {"$ref": act_id},
                    "inPartition": [{"$ref": pid}]
                }
            else:  # action
                node = {
                    "_type":   "UMLAction",
                    "_id":     uid,
                    "name":    label,
                    "_parent": {"$ref": act_id},
                    "inPartition": [{"$ref": pid}]
                }

            elements.append(node)

        # ── Buat control flows (edges) ──
        for (src, tgt, guard) in diag["edges"]:
            flow = {
                "_type":   "UMLControlFlow",
                "_id":     new_id(),
                "_parent": {"$ref": act_id},
                "source":  {"$ref": id_map[src]},
                "target":  {"$ref": id_map[tgt]},
            }
            if guard:
                flow["guard"] = guard
            elements.append(flow)

        # ── Buat UMLActivity ──
        activity = {
            "_type":         "UMLActivity",
            "_id":           act_id,
            "name":          diag["name"],
            "_parent":       {"$ref": model_id},
            "ownedElements": elements,
        }

        model_elem["ownedElements"].append(activity)

    return root


# ============================================================
# MAIN
# ============================================================
if __name__ == "__main__":
    output_dir  = r"c:\laragon\www\tugasakhirsampah\bank_sampah\docs"
    output_file = os.path.join(output_dir, "BankSampahActivityDiagram.mdj")

    mdj_data = build_mdj(DIAGRAMS)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(mdj_data, f, ensure_ascii=False, indent=2)

    total_diagrams = len(DIAGRAMS)
    total_nodes    = sum(len(d["nodes"]) for d in DIAGRAMS)
    total_edges    = sum(len(d["edges"]) for d in DIAGRAMS)

    print("=" * 60)
    print("  BERHASIL: BankSampahActivityDiagram.mdj dibuat!")
    print("=" * 60)
    print(f"  Lokasi : {output_file}")
    print(f"  Diagram : {total_diagrams}")
    print(f"  Node    : {total_nodes}")
    print(f"  Edge    : {total_edges}")
    print("=" * 60)
    print("  Cara buka: File > Open > pilih file .mdj di StarUML")
    print("=" * 60)
