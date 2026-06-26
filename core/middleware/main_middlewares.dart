import 'dart:developer';
import 'package:dart_frog/dart_frog.dart';
import '../../shared/constants/app_constants.dart';
import '../data/mongo/mongo_service.dart';
import '../exceptions/app_exceptions.dart';
import '../response/my_response.dart';
import '../services/jwt/jwt_util.dart';
import '../services/cache/redis/redis_service.dart';

class MainMiddlewares {
  static Middleware mongoMiddleware() {
    return (handler) {
      return (context) async {
        AppConstants.initEnv();
        final mongo = MongoService.instance;
        await mongo.init();
        final updatedContext = context.provide<MongoService>(
          () => mongo,
        );
        return handler(updatedContext);
      };
    };
  }

  static Middleware redisMiddleware() {
    return (handler) {
      return (context) async {
        final redis = RedisService.instance;
        await redis.init();
        final updatedContext = context.provide<RedisService>(
          () => redis,
        );
        return handler(updatedContext);
      };
    };
  }

  /// token validation MiddleWare
  static Middleware authMiddleware({List<String>? allowedMethods}) {
    return (handler) {
      return (context) async {
        final method = context.request.method.value;
        if (allowedMethods != null &&
            allowedMethods.isNotEmpty &&
            !allowedMethods.contains(method)) {
          return handler(context);
        }

        final authHeader = context.request.headers['authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return errorResponse('No token', statusCode: 401);
        }

        final token = authHeader.substring(7);

        final userId = JwtUtil.getUserId(token);

        final verifyT = JwtUtil.verifyToken(token);
        if (verifyT == null ||
            verifyT.payload == null ||
            verifyT.payload['type'] != 'access') {
          return errorResponse('Invalid access token', statusCode: 401);
        }

        if (userId == null) {
          return errorResponse('Invalid access token', statusCode: 401);
        }

        return handler.use(
          provider<String>((_) => userId),
        )(context);
      };
    };
  }

  /// errors middleware
  static Middleware requestBodyValidator() {
    return (handler) {
      return (context) async {
        final method = context.request.method;
        final shouldValidateBody = switch (method) {
          HttpMethod.post ||
          HttpMethod.put ||
          HttpMethod.patch ||
          HttpMethod.delete =>
            true,
          _ => false,
        };

        if (!shouldValidateBody) {
          return await handler(context);
        }

        final contentType = context.request.headers['content-type'] ?? '';

        if (contentType.contains('application/json') || contentType.isEmpty) {
          late final dynamic body;
          try {
            body = await context.request.json();
          } on FormatException {
            throw BadRequestException('Invalid JSON body');
          }
          if (body is! Map || body.isEmpty) {
            throw BadRequestException('Empty JSON body');
          }
        }

        // if (contentType.contains('multipart/form-data')) {
        //   late final FormData formData;
        //   try {
        //     formData = await context.request.formData();
        //   } on FormatException {
        //     throw ValidationException({
        //       'message': ['Invalid form-data body'],
        //     });
        //   }

        //   if (formData.fields.isEmpty && formData.files.isEmpty) {
        //     throw ValidationException({
        //       'message': ['Empty form-data body'],
        //     });
        //   }
        // }

        return handler(context);
      };
    };
  }

  static Middleware middleware() {
    return (handler) {
      return (context) async {
        try {
          return await handler(context);
        } on DataBaseException catch (e) {
          return Response.json(
            statusCode: e.statusCode,
            body: {
              'success': false,
              'message': e.message,
              'code': e.code,
            },
          );
        } on BadRequestException catch (e) {
          return Response.json(
            statusCode: e.statusCode,
            body: {
              'success': false,
              'message': e.message,
              'code': e.code,
            },
          );
        } on AppException catch (e) {
          return Response.json(
            statusCode: e.statusCode,
            body: {
              'success': false,
              'message': e.message,
              'code': e.code,
            },
          );
        } catch (e, stackTrace) {
          log('ERROR: $e');
          log(stackTrace.toString());

          return Response.json(
            statusCode: 500,
            body: {
              'success': false,
              'message': '$e',
              'code': 'SERVER_ERROR',
            },
          );
        }
      };
    };
  }
}
