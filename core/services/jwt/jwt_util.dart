import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../../shared/constants/app_constants.dart';
import '../../exceptions/app_exceptions.dart';

class JwtUtil {
  static final String _secret = AppConstants.JwtSecret;

  /// Generate JWT token
  static String generateToken(
    String userId, {
    Duration? duration,
    String? type,
  }) {
    final jwt = JWT({
      'sub': userId,
      'type': type ?? 'access',
      'iat': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
    });

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: duration ?? const Duration(minutes: 15),
    );
  }

  /// Verify and decode token
  static JWT? verifyToken(String token) {
    try {
      return JWT.verify(token, SecretKey(_secret));
    } on JWTException {
      throw UnauthorizedException(message: 'Invalid token');
    }
  }

  /// Extract userId
  static String? getUserId(String token) {
    final jwt = verifyToken(token);
    return jwt?.payload['sub'] as String?;
  }
}
