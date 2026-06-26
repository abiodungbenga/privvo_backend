import 'package:dart_frog/dart_frog.dart';

import '../../../../core/middleware/main_middlewares.dart';

// Middleware _provideUserRepository() {
//   return provider(
//     (context) => UserRepo(),
//   );
// }

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(requestLogger())
      .use(MainMiddlewares.authMiddleware())
      .use(MainMiddlewares.redisMiddleware());
}
