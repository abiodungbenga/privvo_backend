import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../core/data/mongo/mongo_service.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/repository/google/google_signin_repo.dart';
import '../../../core/response/my_response.dart';
import '../../../core/services/redis/redis_service.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/model/subscription_plan_model.dart';
import '../../../shared/model/user_meta.dart';
import '../../../shared/utils/general_functions.dart';
import '../../../shared/utils/id_generator.dart';

Future<Response> onRequest(RequestContext context) {
  // TODO: implement route handler
  return switch (context.request.method) {
    HttpMethod.post => onGoogleSignIn(context),
    _ => Future.value(
        errorResponse("Method not allowed",
            statusCode: HttpStatus.methodNotAllowed),
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
  final mongoService = context.read<MongoService>();
  final redisService = context.read<RedisService>();
  final data = await googleSigninRepo.initiateGoogleSignIn(idToken: idToken);
  if (data != null) {
    final AuthenticationModel user = AuthenticationModel(
      name: data.givenName ?? "",
      email: data.email ?? "",
      id: getRandomId,
      encryptionKey: generateEncyptionKey(),
      userSubscription: UserSubscription(
        plan: SubscriptionPlan.free,
        status: "Ongoing",
        startedAt: DateTime.now(),
      ),
      userMeta: UserMeta(
        createdAt: DateTime.now(),
        language: "English",
        isDark: false,
        isEmailVerified: bool.tryParse(data.emailVerified ?? "false") ?? false,
        signInMethod: "google",
        lastLoggedIn: DateTime.now(),
        profileUrl: data.picture ?? "",
        storageLimitMb: 1000,
        storageUsedMb: 0,
      ),
      password: "",
    );
    final authUser = await googleSigninRepo.signInWithGoogle(
        user, idToken, data, mongoService, redisService);
    return successResponse(authUser);
  }
  return errorResponse("Google sign in failed!");
}
