import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../../shared/constants/app_constants.dart';

class JwtUtil {
  static final String _secret = AppConstants.JwtSecret;

  /// Generate JWT token
  static String generateToken(String userId,
      {Duration? duration, String? type}) {
    final jwt = JWT({
      'sub': userId,
      'type': type ?? 'access',
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: duration ?? const Duration(minutes: 15),
      algorithm: JWTAlgorithm.HS256,
    );
  }

  /// Verify and decode token
  static JWT? verifyToken(String token) {
    try {
      return JWT.verify(token, SecretKey(_secret));
    } catch (_) {
      return null;
    }
  }

  /// Extract userId
  static String? getUserId(String token) {
    final jwt = verifyToken(token);
    return jwt?.payload['sub'] as String?;
  }
}
