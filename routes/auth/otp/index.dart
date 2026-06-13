import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../core/response/my_response.dart';
import '../../../core/services/redis/redis_service.dart';
import '../../../core/services/verification/verification_service.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onSendOtp(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onSendOtp(RequestContext context) async {
  final redisService = context.read<RedisService>();
  final email = context.request.headers['email'] ?? '';
  final userId = context.read<String>();
  await VerificationService.sendOtp(email, redisService, userId);
  return successResponse(null, statusCode: HttpStatus.noContent);
}
