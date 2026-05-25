import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../core/data/mongo/mongo_service.dart';
import '../../core/repository/user_repo/user_repo.dart';
import '../../core/response/my_response.dart';
import '../../shared/model/user_model.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.get => onGet(context),
    HttpMethod.delete => onDelete(context),
    HttpMethod.put => onUpdate(context),
    _ => Future.value(
        Response(
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
  final body = await context.request.json() as Map<String, dynamic>;
  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  final user = await context
      .read<UserRepo>()
      .updateUser(UserModel.fromJson(body), mongoClient);
  return successResponse(user);
}

Future<Response> onDelete(RequestContext context) async {
  final mongoClient = context.read<MongoService>();
  final userId = context.read<String>();
  await context.read<UserRepo>().deleteUser(userId, mongoClient);
  return successResponse(null,
      statusCode: HttpStatus.noContent,
      successMsg: 'Account deleted successfully!');
}
