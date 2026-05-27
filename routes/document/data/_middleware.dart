import 'package:dart_frog/dart_frog.dart';
import '../../../core/middleware/main_middlewares.dart';
import '../../../core/repository/document_repo/document_repo.dart';

Middleware _provideDocumentRepository() {
  return provider(
    (context) => DocumentRepo(),
  );
}

Handler middleware(Handler handler) {
  // TODO: implement middleware
  return handler
      .use(requestLogger())
      .use(MainMiddlewares.authMiddleware())
      .use(MainMiddlewares.redisMiddleware())
      .use(MainMiddlewares.mongoMiddleware())
      .use(_provideDocumentRepository());
}
