import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/auth/auth_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/cache/redis/redis_service.dart';
import '../../../shared/utils/validator/validator_rules.dart';
import '../../../shared/utils/validator/validator_schema.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onLogin(context),
    _ => Future.value(
        errorResponse(
          'Method not allowed',
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onLogin(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  final validator = ValidatorSchema({
    'email': [ValidationRules.required(), ValidationRules.email()],
    'password': [ValidationRules.required(), ValidationRules.minLength(8)],
  });

  final errors = validator.validate(body);
  if (errors != null) {
    return errorResponse('Validation error!', data: errors);
  }

  final mongoClient = context.read<MongoService>();
  final redisService = context.read<RedisService>();

  final user = await context
      .read<AuthRepository>()
      .loginUser(email ?? '', password ?? '', mongoClient, redisService);
  return successResponse(user);
}
