import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/user_repo/user_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../shared/model/user_meta.dart';
import '../../../shared/model/user_model.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => onGet(context),
    HttpMethod.delete => onDelete(context),
    HttpMethod.put => onUpdate(context),
    _ => Future.value(
        errorResponse("Method not allowed",
            statusCode: HttpStatus.methodNotAllowed),
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
  final body = await context.request.json() as Map<String, dynamic>;
  final String? name = body['name'] as String?;
  final String? language = body['language'] as String?;

  final String? profileUrl = body['profileUrl'] as String?;
  final int? storageLimitMb =
      int.tryParse(body['storageLimitMb'] as String? ?? "");
  final int? storageUsedMb =
      int.tryParse(body['storageUsedMb'] as String? ?? "");

  final bool? isDark = bool.tryParse(body['isDark'] as String? ?? "");

  if (name != null && name.length < 3) {
    return errorResponse('Name must be at least 3 characters long',
        statusCode: HttpStatus.badRequest);
  }
  if (body.isEmpty) {
    return errorResponse('No data provided', statusCode: HttpStatus.badRequest);
  }

  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  final prevData = await context.read<UserRepo>().getUser(userId, mongoClient);
  final user = await context.read<UserRepo>().updateUser(
      UserModel(
        name: name ?? "",
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
      mongoClient);
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
