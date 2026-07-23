class ScanRecord {
  final int idDeteksi;
  final String? imageUrl;
  final String kategoriSampah;
  final double confidence;
  final double berat;
  final double estimasiPoin;
  final String createdAt;

  ScanRecord({
    required this.idDeteksi,
    this.imageUrl,
    required this.kategoriSampah,
    required this.confidence,
    required this.berat,
    required this.estimasiPoin,
    required this.createdAt,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      idDeteksi: json['id_deteksi'] ?? 0,
      imageUrl: json['image_url']?.toString(),
      kategoriSampah: json['kategori_sampah']?.toString() ?? 'Lainnya',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      berat: (json['berat'] as num?)?.toDouble() ?? 1.0,
      estimasiPoin: (json['estimasi_poin'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
