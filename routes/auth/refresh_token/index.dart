import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/repository/auth/auth_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/jwt/jwt_util.dart';
import '../../../core/services/redis/redis_service.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onRefreshToken(context),
    _ => Future.value(
        Response(
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onRefreshToken(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  String? refToken = body['refreshToken'] as String?;
  if (refToken == null) {
    throw ValidationException({
      'refreshToken': ['refreshToken is required']
    });
  }
  final verifyT = JwtUtil.verifyToken(refToken);
  if (verifyT == null ||
      verifyT.payload == null ||
      verifyT.payload["type"] != "refresh") {
    return errorResponse('Invalid or expired refresh token',
        statusCode: HttpStatus.unauthorized);
  }

  final refUserId = JwtUtil.getUserId(refToken);
  if (refUserId == null) {
    return errorResponse('Invalid refresh token',
        statusCode: HttpStatus.unauthorized);
  }
  final redisService = context.read<RedisService>();
  final authRepo = context.read<AuthRepository>();
  final result = await authRepo.refreshToken(
    refUserId,
    redisService,
    refToken,
  );
  return successResponse(result);
}
