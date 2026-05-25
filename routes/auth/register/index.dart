import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/repository/auth/auth_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/redis/redis_service.dart';
import '../../../shared/extensions/hash_extensions.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/model/subscription_plan_model.dart';
import '../../../shared/model/user_meta.dart';
import '../../../shared/utils/general_functions.dart';
import '../../../shared/utils/validator/validator_rules.dart';
import '../../../shared/utils/validator/validator_schema.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onRegister(context),
    _ => Future.value(
        errorResponse("Method not allowed",
            statusCode: HttpStatus.methodNotAllowed),
      ),
  };
}

Future<Response> onRegister(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final String? username = body['username'] as String?;
  final String? email = body['email'] as String?;
  final String? password = body['password'] as String?;

  final validator = ValidatorSchema({
    'email': [ValidationRules.required(), ValidationRules.email()],
    'username': [ValidationRules.required(), ValidationRules.minLength(3)],
    'password': [ValidationRules.required(), ValidationRules.minLength(8)],
  });

  final errors = validator.validate(body);
  if (errors != null) {
    return errorResponse('Validation error!', data: errors);
  }

  final mongoClient = context.read<MongoService>();
  final redisService = context.read<RedisService>();
  final user = await context.read<AuthRepository>().createUser(
        AuthenticationModel(
          name: username ?? "",
          email: email ?? "",
          id: email?.hashedValue,
          userSubscription: UserSubscription(
            plan: SubscriptionPlan.free,
            status: "Ongoing",
            startedAt: DateTime.now(),
          ),
          userMeta: UserMeta(
            createdAt: DateTime.now(),
            language: "English",
            lastLoggedIn: DateTime.now(),
            profileUrl: null,
            storageLimitMb: 1000,
            storageUsedMb: 0,
          ),
          password: GeneralFunctions.hashPassword(password ?? ""),
        ),
        mongoClient,
        redisService,
      );
  return successResponse(user);
}
