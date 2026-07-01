# Entity Relationship Diagram (ERD) - Bank Sampah

Berikut adalah diagram relasi entitas (ERD) dari struktur database aplikasi *Bank Sampah* (berdasarkan file-file SQL di dalam folder `bank_sampah`).

```mermaid
erDiagram
    PENGGUNA ||--o{ TRANSAKSI : "warga (menyetor)"
    PENGGUNA ||--o{ TRANSAKSI : "petugas (mencatat)"
    PENGGUNA ||--o{ EDUKASI : "author (menulis)"
    PENGGUNA ||--o{ ORDERS : "warga (memesan jemputan)"
    PENGGUNA ||--o{ ORDERS : "driver (mengambil pesanan)"
    PENGGUNA ||--o{ NOTIFIKASI : "menerima notifikasi"
    PENGGUNA ||--o| DETAIL_DRIVER : "detail khusus (jika driver)"

    TRANSAKSI ||--o{ DETAIL_SETORAN : "memiliki rincian"
    JENIS_SAMPAH ||--o{ DETAIL_SETORAN : "merupakan jenis sampah pada"
    
    ORDERS ||--o{ ORDER_ITEMS : "memiliki rincian barang"
    JENIS_SAMPAH ||--o{ ORDER_ITEMS : "merupakan jenis sampah pada"

    PENGGUNA {
        int id_pengguna PK
        varchar nama_lengkap
        varchar username
        varchar password
        enum level
        text alamat
        varchar no_telepon
        decimal saldo
        timestamp tanggal_daftar
        varchar foto_profil
        varchar api_token
        varchar email
    }

    JENIS_SAMPAH {
        int id_jenis_sampah PK
        varchar nama_sampah
        decimal harga_per_kg
        text deskripsi
        varchar satuan
    }

    TRANSAKSI {
        int id_transaksi PK
        int id_warga FK
        int id_petugas_pencatat FK
        timestamp tanggal_transaksi
        enum tipe_transaksi
        decimal total_nilai
        text keterangan
    }

    DETAIL_SETORAN {
        int id_detail_setoran PK
        int id_transaksi_setor FK
        int id_jenis_sampah FK
        decimal berat_kg
        decimal harga_saat_setor
        decimal subtotal_nilai
    }

    EDUKASI {
        int id_edukasi PK
        varchar judul
        text konten
        varchar gambar
        varchar video_url
        varchar video_path
        int author_id FK
        timestamp created_at
        timestamp updated_at
    }

    ORDERS {
        int id_order PK
        int id_warga FK
        int id_driver FK
        text alamat_jemput
        decimal latitude
        decimal longitude
        timestamp tanggal_order
        time waktu_jemput_dari
        time waktu_jemput_sampai
        varchar estimasi_berat
        int estimasi_poin
        enum status
        text catatan
        timestamp created_at
        timestamp updated_at
    }

    ORDER_ITEMS {
        int id_order_item PK
        int id_order FK
        int id_jenis_sampah FK
        decimal estimasi_berat_kg
        decimal berat_aktual_kg
    }

    NOTIFIKASI {
        int id_notifikasi PK
        int id_pengguna FK
        varchar judul
        text pesan
        varchar tipe
        tinyint is_read
        timestamp created_at
    }

    DETAIL_DRIVER {
        int id_detail PK
        int id_pengguna FK
        varchar kecamatan
        varchar kab_kota
        varchar wilayah
        varchar kode_pos
        enum tipe_kendaraan
        varchar jenis_kendaraan
        varchar plat_nomor
        decimal kapasitas_berat
        timestamp created_at
        timestamp updated_at
    }
```
