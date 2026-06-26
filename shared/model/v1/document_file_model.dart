import 'dart:typed_data';

class DocumentFileModel {
  DocumentFileModel({
    // required this.url,
    required this.sizeBytesUint8List,
    required this.fileName,
    required this.mimeType,
    required this.extension,
    required this.sizeMb,
    required this.sizeBytes,
    required this.isImage,
  });

  factory DocumentFileModel.fromJson(Map<String, dynamic> json) {
    return DocumentFileModel(
      // url: json['url'] as String,
      sizeBytesUint8List: json['sizeBytesUint8List'] as Uint8List,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      extension: json['extension'] as String,
      sizeMb: (json['sizeMb'] as num).toDouble(),
      sizeBytes: json['sizeBytes'] as int,
      isImage: json['isImage'] as bool,
    );
  }
  final String fileName;

  final String mimeType;
  final String extension;

  final double sizeMb;
  final Uint8List? sizeBytesUint8List;
  final int sizeBytes;

  final bool isImage;

  Map<String, dynamic> toJson() {
    return {
      // 'url': url,
      'fileName': fileName,
      'sizeBytesUint8List': sizeBytesUint8List,
      'mimeType': mimeType,
      'extension': extension,
      'sizeMb': sizeMb,
      'sizeBytes': sizeBytes,
      'isImage': isImage,
    };
  }
}
