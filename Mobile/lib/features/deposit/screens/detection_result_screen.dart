import 'package:flutter/material.dart';

class DetectionResultScreen extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const DetectionResultScreen({super.key, required this.responseData});

  @override
  Widget build(BuildContext context) {
    final uploaded = responseData['uploaded_file'] as String?;
    final detections = (responseData['detections'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        backgroundColor: const Color(0xFF4AC08D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (uploaded != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Gambar yang diunggah',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      uploaded,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, e, s) =>
                              const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            const Text(
              'Deteksi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            if (detections.isEmpty)
              const Text('Tidak ada hasil deteksi')
            else
              ...detections.map((d) {
                final map = d as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          map['nama_sampah'] ?? (map['label'] ?? '-'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (map['kategori'] != null)
                          Text(
                            'Kategori: ${map['kategori']}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        if (map['deskripsi'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            map['deskripsi'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                        if (map['cara_pengolahan'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cara Pengolahan:',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            map['cara_pengolahan'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                        if (map['gambar'] != null) ...[
                          const SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              map['gambar'],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (c, e, s) => const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
