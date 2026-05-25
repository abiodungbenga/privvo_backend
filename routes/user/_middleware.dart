import 'package:dart_frog/dart_frog.dart';

import '../../core/middleware/main_middlewares.dart';
import '../../core/repository/user_repo/user_repo.dart';

Middleware _provideUserRepository() {
  return provider(
    (context) => UserRepo(),
  );
}

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(requestLogger())
      .use(MainMiddlewares.mongoMiddleware())
      .use(MainMiddlewares.redisMiddleware())
      .use(MainMiddlewares.authMiddleware())
      .use(_provideUserRepository());
}
