import 'package:email_otp/email_otp.dart';

import '../../../shared/constants/app_constants.dart';
import '../redis/redis_service.dart';

class VerificationService {
  static Future<void> init() async {
    // AppConstants.initEnv();
    await EmailOTP.config(
      appName: AppConstants.appName,
      appEmail: AppConstants.appEmail,
      otpType: OTPType.numeric,
      otpLength: 4,
      expiry: 5,
      emailTheme: EmailTheme.v1,
    );
    await EmailOTP.setSMTP(
      host: AppConstants.smtpHost,
      emailPort: EmailPort.port465,
      secureType: SecureType.ssl,
      username: AppConstants.smtpUsername,
      password: AppConstants.smtpPassword,
    );
  }

  static Future<void> sendOtp(
      String email, RedisService redis, String userId) async {
    EmailOTP.sendOTP(email: email);
    await redis.redisClient.set(
      key: 'otp:$userId',
      value: sentOtp ?? '',
      ttl: const Duration(minutes: 5),
    );
  }

  static String? get sentOtp => EmailOTP.getOTP();

  static bool get otpExpired => EmailOTP.isOtpExpired();

  static bool verifyOtp(String otp) => EmailOTP.verifyOTP(otp: otp);
}
