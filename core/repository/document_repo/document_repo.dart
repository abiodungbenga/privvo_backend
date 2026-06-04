import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/document_file_model.dart';
import '../../../shared/model/document_model.dart';
import '../../../shared/utils/id_generator.dart';
import '../../data/mongo/mongo_service.dart';
import '../../services/ai/ai_service.dart';
import '../../services/redis/redis_service.dart';
import '../../services/storage/storage_service.dart';
import '../ocr/ocr_repository.dart';

class DocumentRepo {
  Future<DocumentModel> createDocument(
    MongoService mongoService,
    RedisService redis,
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
    final userCollection =
        mongoService.db!.collection(AppConstants.usersCollection);

    final encryptionKey =
        await redis.redisClient.get(key: 'encryptionKey:$userId');

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
    final encyptedFile = await StorageService.instance
        .encryptFile(file!.readAsBytesSync(), encryptionKey ?? '');

    await StorageService.instance.uploadFile(
      fileBytes: encyptedFile,
      uploadedFile: file,
      userId: userId,
      folder: savedFilePath,
    );

    final extractedString = await OcrRepository.extractFromFIle(file);
    final data = extractedString.replaceAll('\n', ' ');
    final aiGen = await AiService.instance.generateText(
      bytes: file.readAsBytesSync(),
      mimeType: uploadedFile?.contentType.mimeType,
      docInfo: data,
    );

    final aiGenRes = jsonDecode(aiGen);

    final json = {'raw_text': data};
    final sizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);

    final bytes = await file.readAsBytes();
    final document = DocumentModel(
      title: title ?? '',
      description: description ?? '',
      documentType: documentType ?? '',
      extractedData: shouldExtractData ? json : extractedData ?? {},
      tags: tags ?? [],
      aiGenerated: shouldExtractData ? aiGenRes as Map<String, dynamic> : {},
      file: uploadedFile != null
          ? DocumentFileModel(
              sizeBytesUint8List: encyptedFile,
              // url: "",
              fileName: uploadedFile.name,
              mimeType: uploadedFile.contentType.mimeType,
              extension: file.path.split('.').last,
              sizeMb: double.parse(sizeMb),
              sizeBytes: bytes.length,
              isImage: uploadedFile.contentType.mimeType.startsWith('image/'),
            )
          : null,
      id: getRandomId,
      thumbnailUrl: thumbnailUrl ?? '',
      customFields: customFields ?? {},
      isArchived: isArchived ?? false,
      isFavorite: isFavorite ?? false,
      userId: userId ?? '',
      createdAt: DateTime.now(),
    );

    await collection.insertOne(document.toJson()).whenComplete(file.delete);
    await userCollection.updateOne(
      where.eq('id', userId),
      modify.set('userMeta.storageUsedMb', sizeMb),
    );
    return document;
  }

  Future<List<DocumentModel>> getAllDocuments(MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    final documents = await collection.find().toList();
    return documents.map(DocumentModel.fromJson).toList();
  }

  Future<List<DocumentModel>> getUserDocuments(
    String userId,
    MongoService mongoService,
  ) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    final documents = await collection.find({'userId': userId}).toList();
    return documents.map(DocumentModel.fromJson).toList();
  }

  Future<DocumentModel> getDocument(
    String id,
    MongoService mongoService,
  ) async {
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
    DocumentModel document,
    MongoService mongoService,
  ) async {
    final collection =
        mongoService.db!.collection(AppConstants.documentsCollection);
    await collection.updateOne(where.eq('id', document.id), document.toJson());
    return document;
  }
}
