import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../../core/repository/auth/auth_repo.dart';
import '../../../../core/response/my_response.dart';
import '../../../../core/services/cache/redis/redis_service.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onLogout(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onLogout(RequestContext context) async {
  final redisService = context.read<RedisService>();
  final authRepo = context.read<AuthRepository>();
  final userId = context.read<String>();
  await authRepo.logoutUser(userId, redisService);
  return successResponse(null, statusCode: HttpStatus.noContent);
}
