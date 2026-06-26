import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../core/data/mongo/mongo_service.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/repository/document_repo/document_repo.dart';
import '../../../../core/response/my_response.dart';
import '../../../../core/services/cache/redis/redis_service.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onCreate(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onCreate(RequestContext context) async {
  final formData = await context.request.formData();

  // final uri = context.;

  // final baseUrl = '${uri.scheme}://${uri.host}';

  final title = formData.fields['title'];
  final description = formData.fields['description'];
  final documentType = formData.fields['documentType'];

  final tags = formData.fields['tags']?.split(',');

  final thumbnailUrl = formData.fields['thumbnailUrl'];

  final customFieldsRaw = formData.fields['customFields'];
  final customFields = customFieldsRaw != null
      ? jsonDecode(customFieldsRaw) as Map<String, dynamic>
      : null;

  final isArchived = bool.tryParse(formData.fields['isArchived'] ?? 'false');

  final isFavorite = bool.tryParse(formData.fields['isFavorite'] ?? 'true');

  final shouldExtractData =
      bool.tryParse(formData.fields['shouldExtractData'] ?? 'true');

  final file = formData.files['file'];

  if (file == null) {
    throw BadRequestException('uploaded is null!');
  }

  if (title == null) {
    return errorResponse(
      'Title is required',
    );
  }

  if (description == null) {
    return errorResponse(
      'Description is required',
    );
  }

  if (documentType == null) {
    return errorResponse(
      'Document type is required',
    );
  }

  final mongoClient = context.read<MongoService>();
  final redis = context.read<RedisService>();
  final userId = context.read<String>();
  final document = await context.read<DocumentRepo>().createDocument(
        mongoClient,
        redis,
        file,
        customFields: customFields,
        shouldExtractData: shouldExtractData ?? true,
        description: description,
        documentType: documentType,
        extractedData: {},
        isArchived: isArchived,
        isFavorite: isFavorite,
        tags: tags,
        thumbnailUrl: thumbnailUrl,
        title: title,
        userId: userId,
      );
  return successResponse(document);
}
