import 'package:dotenv/dotenv.dart';

class AppConstants {
  static final DotEnv env = DotEnv();

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

  /// api keys
  static String googleApiKey = env['GEMINI_API_KEY'] ?? '';

  static String deepSeekApiKey = env['DEEP_SEEK_API_KEY'] ?? '';

  ///Smtp
  static String smtpHost = env['SMTP_HOST'] ?? 'smtp.gmail.com';
  static String smtpUsername = env['SMTP_USERNAME'] ?? 'gbengaemma22@gmail.com';
  static String smtpPassword = env['SMTP_PASSWORD'] ?? 'xesa wdyw exfx rzlj';

  /// app
  static String appName = env['APP_NAME'] ?? 'Privvo';
  static String appEmail = env['APP_EMAIL'] ?? 'privvo@gmail.com';

  /// collections
  static String usersCollection = 'users';

  static String documentsCollection = 'documents';
}
