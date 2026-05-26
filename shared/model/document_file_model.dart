class DocumentFileModel {
  final String url;
  final String fileName;

  final String mimeType;
  final String extension;

  final double sizeMb;
  final int sizeBytes;

  final bool isImage;

  DocumentFileModel({
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.extension,
    required this.sizeMb,
    required this.sizeBytes,
    required this.isImage,
  });

  factory DocumentFileModel.fromJson(Map<String, dynamic> json) {
    return DocumentFileModel(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      extension: json['extension'] as String,
      sizeMb: (json['sizeMb'] as num).toDouble(),
      sizeBytes: json['sizeBytes'] as int,
      isImage: json['isImage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'mimeType': mimeType,
      'extension': extension,
      'sizeMb': sizeMb,
      'sizeBytes': sizeBytes,
      'isImage': isImage,
    };
  }
}
