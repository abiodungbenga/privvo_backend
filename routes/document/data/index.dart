import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/document_repo/document_repo.dart';
import '../../../core/response/my_response.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onCreate(context),
    _ => Future.value(
        errorResponse("Method not allowed",
            statusCode: HttpStatus.methodNotAllowed),
      ),
  };
}

Future<Response> onCreate(RequestContext context) async {
  final formData = await context.request.formData();

  final String? title = formData.fields['title'];
  final String? description = formData.fields['description'];
  final String? documentType = formData.fields['documentType'];

  final List<String>? tags = formData.fields['tags'] != null
      ? formData.fields['tags']!.split(',')
      : null;

  final String? thumbnailUrl = formData.fields['thumbnailUrl'];

  final String? customFieldsRaw = formData.fields['customFields'];
  final Map<String, dynamic>? customFields = customFieldsRaw != null
      ? jsonDecode(customFieldsRaw) as Map<String, dynamic>
      : null;

  final bool? isArchived = formData.fields['isArchived'] == 'true';

  final bool? isFavorite = formData.fields['isFavorite'] == 'true';

  final uploadedFile = formData.files['file'];

  if (title == null) {
    return errorResponse("Title is required",
        statusCode: HttpStatus.badRequest);
  }

  if (description == null) {
    return errorResponse("Description is required",
        statusCode: HttpStatus.badRequest);
  }

  if (documentType == null) {
    return errorResponse("Document type is required",
        statusCode: HttpStatus.badRequest);
  }

  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  final document = await context.read<DocumentRepo>().createDocument(
        mongoClient,
        uploadedFile,
        customFields: customFields,
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
