import 'dart:io';
import 'dart:typed_data';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/user_repo/user_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/cache/redis/redis_service.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../shared/model/user_meta.dart';
import '../../../shared/model/user_model.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => onGet(context),
    HttpMethod.delete => onDelete(context),
    HttpMethod.put => onUpdate(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onGet(RequestContext context) async {
  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  final users = await context.read<UserRepo>().getUser(userId, mongoClient);
  return successResponse(users);
}

Future<Response> onUpdate(RequestContext context) async {
  final formData = await context.request.formData();
  final name = formData.fields['name'];
  final language = formData.fields['language'];

  final profileFile = formData.files['profileFile'];
  final storageLimitMb = int.tryParse(formData.fields['storageLimitMb'] ?? '');
  final storageUsedMb = int.tryParse(formData.fields['storageUsedMb'] ?? '');

  final isDark = bool.tryParse(formData.fields['isDark'] ?? '');

  if (formData.isEmpty) {
    return errorResponse('No data provided');
  }
  if (name != null && name.length < 3) {
    return errorResponse(
      'Name must be at least 3 characters long',
    );
  }

  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  final prevData = await context.read<UserRepo>().getUser(userId, mongoClient);
  String? profileUrl;
  if (profileFile != null) {
    final file =
        await StorageService.instance.compressFile(uploadedFile: profileFile);
    final cloudinaryUrl = await StorageService.instance.uploadFile(
      fileBytes: file?.readAsBytesSync(),
      uploadedFile: file,
      folder: 'documents/images',
    );
    profileUrl = cloudinaryUrl?.secureUrl;
  }
  final user = await context.read<UserRepo>().updateUser(
        UserModel(
          name: name ?? '',
          email: prevData.email,
          userSubscription: prevData.userSubscription,
          userMeta: UserMeta(
            signInMethod: prevData.userMeta?.signInMethod,
            updatedAt: DateTime.now(),
            isEmailVerified: prevData.userMeta?.isEmailVerified ?? false,
            createdAt: prevData.userMeta?.createdAt,
            lastLoggedIn: prevData.userMeta?.lastLoggedIn,
            profileUrl: profileUrl ?? prevData.userMeta?.profileUrl,
            isDark: (isDark ?? prevData.userMeta?.isDark) ?? false,
            language: language ?? prevData.userMeta?.language,
            storageLimitMb: storageLimitMb ?? prevData.userMeta?.storageLimitMb,
            storageUsedMb: storageUsedMb ?? prevData.userMeta?.storageUsedMb,
          ),
        ),
        userId,
        mongoClient,
      );
  return successResponse(user);
}

Future<Response> onDelete(RequestContext context) async {
  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  await context.read<UserRepo>().deleteUser(userId, mongoClient);
  return successResponse(
    null,
    statusCode: HttpStatus.noContent,
    successMsg: 'Account deleted successfully!',
  );
}
