import 'package:mongo_dart/mongo_dart.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/v1/authentication_model.dart';
import '../../../shared/utils/general_functions.dart';
import '../../data/mongo/mongo_service.dart';
import '../../exceptions/app_exceptions.dart';
import '../../services/jwt/jwt_util.dart';
import '../../services/cache/redis/redis_service.dart';
import '../../services/verification/verification_service.dart';

class AuthRepository {
  Future<AuthenticationModel> createUser(
    AuthenticationModel user,
    MongoService mongoClient,
    RedisService redisService,
  ) async {
    _rateLimit(user.email, mongoClient, redisService);
    // if (user.email.isEmpty ||
    //     (user.password?.isEmpty ?? true) ||
    //     user.name.isEmpty) {
    //   throw ValidationException({
    //     'email': [
    //       'Email is required',
    //     ],
    //     'password': [
    //       'Password is required',
    //     ],
    //     'name': [
    //       'Name is required',
    //     ],
    //   });
    // }
    final exists = await userExists(user.email, mongoClient, redisService);
    if (exists) {
      throw BadRequestException('User exist already');
    }
    if (mongoClient.db != null) {
      final refToken = JwtUtil.generateToken(
        user.id ?? '',
        duration: const Duration(days: 7),
        type: 'refresh',
      );

      await redisService.redisClient.set(
        key: 'refresh:${user.id}',
        value: refToken,
        ttl: const Duration(days: 7),
      );

      await redisService.redisClient.set(
        key: 'encryptionKey:${user.id}',
        value: user.encryptionKey ?? '',
      );
      final collection =
          mongoClient.db!.collection(AppConstants.usersCollection);
      await collection.insertOne(user.toJson());
      final token = JwtUtil.generateToken(user.id ?? '');
      await VerificationService.init();
      VerificationService.sendOtp(user.email, redisService, user.id ?? '');
      return AuthenticationModel.fromJson(user.toJson())
          .copyWith(token: token, refreshToken: refToken);
    }
    throw MongoDartError('DB connection failed');
  }

  Future<AuthenticationModel> loginUser(
    String email,
    String password,
    MongoService mongoClient,
    RedisService redisService,
  ) async {
    _rateLimit(email, mongoClient, redisService);
    if (mongoClient.db != null) {
      final collection =
          mongoClient.db!.collection(AppConstants.usersCollection);

      final user = await collection.findOne({'email': email});
      if (user == null) {
        throw BadRequestException('Invalid credentials');
      }

      final isPasswordValid = GeneralFunctions.verifyPassword(
        password,
        user['password'].toString(),
      );

      if (!isPasswordValid) {
        throw BadRequestException('Incorrect password');
      }
      await collection.updateOne(
        where.eq('email', email),
        modify.set('userMeta.lastLogin', DateTime.now()),
      );

      final userModel = AuthenticationModel.fromJson(user);

      final refToken = JwtUtil.generateToken(
        userModel.id ?? '',
        duration: const Duration(days: 7),
        type: 'refresh',
      );

      final accessToken = JwtUtil.generateToken(userModel.id ?? '');

      await redisService.redisClient.set(
        key: 'refresh:${userModel.id}',
        value: refToken,
        ttl: const Duration(days: 7),
      );

      if (userModel.userMeta?.isEmailVerified == false ||
          userModel.userMeta?.isEmailVerified == null) {
        await VerificationService.init();
        VerificationService.sendOtp(
          userModel.email,
          redisService,
          userModel.id ?? '',
        );
      }

      return AuthenticationModel.fromJson(user).copyWith(
          token: accessToken,
          refreshToken: refToken,
          isEmailVerified: user['userMeta']['isEmailVerified'] as bool);
    } else {
      throw MongoDartError('DB connection failed');
    }
  }

  Future<bool> userExists(
    String email,
    MongoService mongoClient,
    RedisService redisService,
  ) async {
    try {
      final collection =
          mongoClient.db!.collection(AppConstants.usersCollection);
      final user = await collection.findOne({'email': email});
      return user != null;
    } catch (e) {
      throw DataBaseException('User exist already');
    }
  }

  Future<Map<String, dynamic>> refreshToken(
    String userId,
    RedisService redisService,
    String token,
  ) async {
    final savedToken =
        await redisService.redisClient.get(key: 'refresh:$userId');

    final refToken = savedToken;

    if (savedToken == null) {
      throw UnauthorizedException(message: 'Session expired');
    }

    if (savedToken != refToken) {
      throw UnauthorizedException(
        message: 'Saved token does not match $savedToken',
      );
    }

    final newAccessToken = JwtUtil.generateToken(userId);
    final newRefreshToken = JwtUtil.generateToken(
      userId,
      duration: const Duration(days: 7),
      type: 'refresh',
    );

    await redisService.redisClient.set(
      key: 'refresh:$userId',
      value: newRefreshToken,
      ttl: const Duration(days: 7),
    );

    return {'token': newAccessToken, 'refreshToken': newRefreshToken};
  }

  Future<void> logoutUser(String userId, RedisService redisService) async {
    await redisService.redisClient.delete(key: 'refresh:$userId');
  }

  Future<void> _rateLimit(
    String email,
    MongoService mongoClient,
    RedisService redisService,
  ) async {
    final key = 'login_attempt:$email';

    final attempts = await redisService.redisClient.increment(key: key);

    if (attempts == 1) {
      await redisService.expire(
        key: key,
        ttl: const Duration(minutes: 15),
      );
    }

    if (attempts > 20) {
      throw BadRequestException(
        'Too many login attempts',
      );
    }
  }
}
