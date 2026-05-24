import 'package:dotenv/dotenv.dart';

class AppConstants {
  static final DotEnv env = DotEnv(
    includePlatformEnvironment: false,
  );

  static bool _initialized = false;

  static void initEnv() {
    if (_initialized) {
      return;
    }
    env.load(['.env']);
    _initialized = true;
  }

  /// config
  static String JwtSecret = env['JWT_SECRET'] ?? '';
  static String DbUrl = env['DB_CONNECTION_URL'] ?? '';

  /// redis
  static String redisHost = env['REDIS_HOST'] ?? 'localhost';
  static int redisPort = int.parse(env['REDIS_PORT'] ?? '6379');
  static String redisUsername = env['REDIS_USERNAME'] ?? '';
  static String redisPassword = env['REDIS_PASSWORD'] ?? '';

  /// collections
  static String usersCollection = "users";
}
