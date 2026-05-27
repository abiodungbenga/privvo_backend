import 'dart:convert';
import 'package:cloudinary/cloudinary.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/document_file_model.dart';
import '../../../shared/model/document_model.dart';
import '../../data/mongo/mongo_service.dart';
import '../../services/ai/ai_service.dart';
import '../../services/storage/storage_service.dart';
import '../ocr/ocr_repository.dart';

class DocumentRepo {
  Future<DocumentModel> createDocument(
    MongoService mongoService,
    UploadedFile? uploadedFile, {
    String? title,
    bool shouldExtractData = true,
    String? description,
    String? documentType,
    Map<String, dynamic>? extractedData,
    List<String>? tags,
    String? thumbnailUrl,
    Map<String, dynamic>? customFields,
    bool? isArchived,
    bool? isFavorite,
    String? userId,
  }) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);

    const uuid = Uuid();

    String savedFilePath;
    if (uploadedFile?.contentType.mimeType.startsWith('image/') ?? false) {
      savedFilePath = 'documents/images';
    } else if (uploadedFile?.contentType.mimeType
            .startsWith('application/pdf') ??
        false) {
      savedFilePath = 'documents/pdfs';
    } else {
      savedFilePath = 'documents/others';
    }

    final file =
        await StorageService.instance.compressFile(uploadedFile: uploadedFile);
    final cloudFile = await StorageService.instance.uploadFile(
      uploadedFile: file,
      folder: savedFilePath,
      resourceType:
          uploadedFile?.contentType.mimeType.startsWith('image/') ?? false
              ? CloudinaryResourceType.image
              : CloudinaryResourceType.auto,
    );

    final extractedString = await OcrRepository.extractFromFIle(file!);
    final data = extractedString.replaceAll('\n', ' ');
    final aiGen = await AiService.instance.generateText(
      bytes: file.readAsBytesSync(),
      mimeType: uploadedFile?.contentType.mimeType,
    );

    final aiGenRes = jsonDecode(aiGen);

    final json = {"raw_text": data};

    final bytes = await file.readAsBytes();
    final DocumentModel document = DocumentModel(
      title: title ?? "",
      description: description ?? "",
      documentType: documentType ?? "",
      extractedData: shouldExtractData ? json : extractedData ?? {},
      tags: tags ?? [],
      aiGenerated: shouldExtractData ? aiGenRes as Map<String, dynamic> : {},
      file: uploadedFile != null
          ? DocumentFileModel(
              url: cloudFile?.secureUrl ?? "",
              fileName: uploadedFile.name ?? "",
              mimeType: uploadedFile.contentType.mimeType ?? "",
              extension: file.path.split('.').last ?? "",
              sizeMb: (bytes.length ?? 0) / (1024 * 1024),
              sizeBytes: bytes.length ?? 0,
              isImage: uploadedFile.contentType.mimeType.startsWith('image/') ??
                  false)
          : null,
      id: uuid.v4(),
      thumbnailUrl: thumbnailUrl ?? "",
      customFields: customFields ?? {},
      isArchived: isArchived ?? false,
      isFavorite: isFavorite ?? false,
      userId: userId ?? "",
      createdAt: DateTime.now(),
    );

    await collection.insertOne(document.toJson()).whenComplete(file.delete);
    return document;
  }

  Future<List<DocumentModel>> getAllDocuments(MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    final documents = await collection.find().toList();
    return documents.map((e) => DocumentModel.fromJson(e)).toList();
  }

  Future<List<DocumentModel>> getUserDocuments(
      String userId, MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    final documents = await collection.find({'userId': userId}).toList();
    return documents.map((e) => DocumentModel.fromJson(e)).toList();
  }

  Future<DocumentModel> getDocument(
      String id, MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    final document = await collection.findOne({'id': id});
    return DocumentModel.fromJson(document!);
  }

  Future<void> deleteDocument(String id, MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    await collection.deleteOne({'id': id});
  }

  Future<DocumentModel> updateDocument(
      DocumentModel document, MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    await collection.updateOne(where.eq('id', document.id), document.toJson());
    return document;
  }
}
