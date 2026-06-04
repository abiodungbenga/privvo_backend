abstract class AppException implements Exception {
  AppException({
    required this.message,
    required this.statusCode,
    required this.code,
  });
  final String message;
  final int statusCode;
  final String code;
}

class NotFoundException extends AppException {
  NotFoundException(String message)
      : super(
          message: message,
          statusCode: 404,
          code: 'NOT_FOUND',
        );
}

class FailedException extends AppException {
  FailedException(String message)
      : super(
          message: message,
          statusCode: 500,
          code: 'FAILURE',
        );
}

class DataBaseException extends AppException {
  DataBaseException(String message)
      : super(
          message: message,
          statusCode: 500,
          code: 'DATABASE_ERROR',
        );
}

class UnauthorizedException extends AppException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized',
          statusCode: 401,
          code: 'UNAUTHORIZED',
        );
}

class BadRequestException extends AppException {
  BadRequestException(String message)
      : super(
          message: message,
          statusCode: 400,
          code: 'BAD_REQUEST',
        );
}

class ValidationException extends AppException {
  ValidationException(this.errors)
      : super(
          message: 'Validation failed',
          statusCode: 422,
          code: 'VALIDATION_ERROR',
        );
  final Map<String, List<String>> errors;
}
