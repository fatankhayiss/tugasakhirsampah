/// Typed result model for waste detection API response.
class DetectResult {
  /// Whether the HTTP request and JSON parsing succeeded.
  final bool success;

  /// Raw detected labels from the YOLO model (e.g. ["Plastik Botol", "Kardus"]).
  final List<String> labels;

  /// Matched database entries for each label.
  final List<Map<String, dynamic>> detections;

  /// URL of the uploaded image on the server.
  final String? uploadedFileUrl;

  /// Local filesystem path of the captured camera image.
  /// Set by ScanDepositScreen after takePicture(); never populated from JSON.
  final String? localImagePath;

  /// True when the Python worker is not running (PHP returns worker_unavailable=true).
  final bool workerUnavailable;

  /// Human-readable error message when success == false.
  final String? errorMessage;

  /// ID of the detection record in the database.
  final int? detectionId;

  const DetectResult({
    required this.success,
    required this.labels,
    required this.detections,
    this.uploadedFileUrl,
    this.localImagePath,
    this.workerUnavailable = false,
    this.errorMessage,
    this.detectionId,
  });

  /// Returns a copy of this result with [localImagePath] set.
  DetectResult withLocalImagePath(String path) => DetectResult(
        success: success,
        labels: labels,
        detections: detections,
        uploadedFileUrl: uploadedFileUrl,
        localImagePath: path,
        workerUnavailable: workerUnavailable,
        errorMessage: errorMessage,
        detectionId: detectionId,
      );

  /// Parses a decoded API JSON map into a [DetectResult].
  factory DetectResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final labelsList = (data['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final detectionsList = (data['detections'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    return DetectResult(
      success: json['success'] == true,
      labels: labelsList,
      detections: detectionsList,
      uploadedFileUrl: data['uploaded_file']?.toString() ?? data['image_url']?.toString(),
      workerUnavailable: data['worker_unavailable'] == true,
      errorMessage: json['message']?.toString(),
      detectionId: data['detection_id'] != null ? int.tryParse(data['detection_id'].toString()) : null,
    );
  }

  /// True if detection returned at least one label.
  bool get hasDetections => labels.isNotEmpty;

  /// True if detection found no labels but worker was available.
  bool get lowConfidence => !hasDetections && !workerUnavailable && success;
}
