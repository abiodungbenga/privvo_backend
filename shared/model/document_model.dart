import 'document_file_model.dart';

class DocumentModel {
  DocumentModel({
    this.id,
    this.extractedData,
    this.aiGenerated,
    required this.userId,
    required this.title,
    this.description,
    required this.documentType,
    required this.tags,
    this.file,
    this.thumbnailUrl,
    this.customFields,
    required this.isArchived,
    required this.isFavorite,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      documentType: json['documentType'] as String,
      tags: List<String>.from(
        (json['tags'] ?? []) as List,
      ),
      file: json['file'] != null
          ? DocumentFileModel.fromJson(
              json['file'] as Map<String, dynamic>,
            )
          : null,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      customFields: json['customFields'] != null
          ? Map<String, dynamic>.from(
              json['customFields'] as Map,
            )
          : null,
      aiGenerated: json['aiGenerated'] != null
          ? Map<String, dynamic>.from(
              json['customFields'] as Map,
            )
          : null,
      extractedData: json['extractedData'] != null
          ? Map<String, dynamic>.from(
              json['extractedData'] as Map,
            )
          : null,
      isArchived: json['isArchived'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String,
      ),
    );
  }
  final String? id;
  final String userId;

  final String title;
  final String? description;

  final String documentType;

  final List<String> tags;

  final DocumentFileModel? file;

  final String? thumbnailUrl;

  final Map<String, dynamic>? customFields;

  final Map<String, dynamic>? aiGenerated;

  final Map<String, dynamic>? extractedData;

  final bool isArchived;
  final bool isFavorite;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'extractedData': extractedData,
      'aiGenerated': aiGenerated,
      'description': description,
      'documentType': documentType,
      'tags': tags,
      'file': file?.toJson(),
      'thumbnailUrl': thumbnailUrl,
      'customFields': customFields,
      'isArchived': isArchived,
      'isFavorite': isFavorite,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
