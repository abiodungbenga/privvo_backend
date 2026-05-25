import 'package:dart_frog/dart_frog.dart';
import '../../../core/middleware/main_middlewares.dart';
import '../../../core/repository/auth/auth_repo.dart';
import '../../../core/repository/google/google_signin_repo.dart';

Middleware _provideAuthRepository() {
  return provider(
    (context) => AuthRepository(),
  );
}

Middleware _provideGoogleRepository() {
  return provider(
    (context) => GoogleSigninRepository(),
  );
}

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(requestLogger())
      .use(MainMiddlewares.mongoMiddleware())
      .use(MainMiddlewares.redisMiddleware())
      .use(_provideGoogleRepository())
      .use(_provideAuthRepository());
}
