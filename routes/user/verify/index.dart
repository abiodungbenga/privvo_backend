import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/user_repo/user_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/cache/redis/redis_service.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onVerify(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onVerify(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final otp = body['otp'] as String?;
  if (otp == null) {
    return errorResponse('OTP is required');
  }
  if (otp.length != 4) {
    return errorResponse('Invalid OTP');
  }
  final mongoClient = context.read<MongoService>();

  final redisService = context.read<RedisService>();
  final userId = context.read<String>();
  final verified = await context
      .read<UserRepo>()
      .verifyUser(otp ?? '', userId, redisService, mongoClient);
  return successResponse({'verified': verified});
}
