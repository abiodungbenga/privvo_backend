import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/repository/auth/auth_repo.dart';
import '../../../core/repository/google/google_signin_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/redis/redis_service.dart';
import '../../../shared/extensions/hash_extensions.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/model/subscription_plan_model.dart';
import '../../../shared/model/user_meta.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onGoogleSignIn(context),
    _ => Future.value(
        Response(
          statusCode: HttpStatus.methodNotAllowed,
        ),
      ),
  };
}

Future<Response> onGoogleSignIn(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final idToken = body['idToken'] as String?;
  if (idToken == null) {
    throw ValidationException({
      'idToken': ['idToken is required']
    });
  }
  final googleSigninRepo = context.read<GoogleSigninRepository>();
  final mongoClient = context.read<MongoService>();
  final redisService = context.read<RedisService>();
  final user = await googleSigninRepo.initiateGoogleSignIn(idToken: idToken);
  final AuthenticationModel authenticationModel = AuthenticationModel(
    name: user?.name ?? "",
    email: user?.email ?? "",
    id: user?.email?.hashedValue,
    userSubscription: UserSubscription(
      plan: SubscriptionPlan.free,
      status: "Ongoing",
      startedAt: DateTime.now(),
    ),
    userMeta: UserMeta(
      createdAt: DateTime.now(),
      isEmailVerified: bool.tryParse(user?.emailVerified ?? "false") ?? false,
      signInMethod: "Google",
      language: "English",
      lastLoggedIn: DateTime.now(),
      profileUrl: null,
      storageLimitMb: 1000,
      storageUsedMb: 0,
    ),
    password: "",
  );
  final signIn = await googleSigninRepo.signInWithGoogle(
      context.read<AuthRepository>(),
      authenticationModel,
      idToken,
      user,
      mongoClient,
      redisService);
  if (signIn != null) {
    successResponse(signIn);
  }

  return errorResponse("Google sign in failed!");
}
