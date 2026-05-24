import 'package:dart_frog/dart_frog.dart';

import '../core/middleware/main_middlewares.dart';

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(MainMiddlewares.requestBodyValidator())
      .use(MainMiddlewares.middleware())
      .use(MainMiddlewares.envMiddleware());
}
