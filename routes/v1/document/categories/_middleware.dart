import 'package:dart_frog/dart_frog.dart';
import '../../../../core/middleware/main_middlewares.dart';
import '../../../../core/repository/categories/category_repo.dart';

Middleware _provideCategoryRepository() {
  return provider(
    (context) => CategoryRepo(),
  );
}

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(requestLogger())
      .use(MainMiddlewares.authMiddleware())
      .use(MainMiddlewares.mongoMiddleware())
      .use(MainMiddlewares.redisMiddleware())
      .use(_provideCategoryRepository());
}
