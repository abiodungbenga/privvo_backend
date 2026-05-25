import 'package:email_otp/email_otp.dart';

import '../redis/redis_service.dart';

class VerificationService {
  static Future<void> init() async {
    // AppConstants.initEnv();
    await EmailOTP.config(
      appName: 'MyApp',
      appEmail: "privvo@gmail.com",
      otpType: OTPType.numeric,
      otpLength: 4,
      expiry: 5,
      emailTheme: EmailTheme.v5,
    );
    await EmailOTP.setSMTP(
      host: 'smtp.gmail.com',
      emailPort: EmailPort.port465,
      secureType: SecureType.ssl,
      username: 'gbengaemma22@gmail.com',
      password: 'xesa wdyw exfx rzlj',
    );
  }

  static void sendOtp(String email, RedisService redis, String userId) async {
    EmailOTP.sendOTP(email: email);
    await redis.redisClient.set(
      key: 'otp:${userId}',
      value: sentOtp ?? "",
      ttl: const Duration(minutes: 5),
    );
  }

  static String? get sentOtp => EmailOTP.getOTP();

  static bool get otpExpired => EmailOTP.isOtpExpired();

  static bool verifyOtp(String otp) => EmailOTP.verifyOTP(otp: otp);
}
