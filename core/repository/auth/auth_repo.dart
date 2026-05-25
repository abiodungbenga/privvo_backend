import 'package:mongo_dart/mongo_dart.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/utils/general_functions.dart';
import '../../data/mongo/mongo_service.dart';
import '../../exceptions/app_exceptions.dart';
import '../../services/jwt/jwt_util.dart';
import '../../services/redis/redis_service.dart';
import '../../services/verification/verification_service.dart';

class AuthRepository {
  Future<AuthenticationModel> createUser(AuthenticationModel user,
      MongoService _mongoClient, RedisService _redisService) async {
    _rateLimit(user.email, _mongoClient, _redisService);
    if (user.email.isEmpty ||
        (user.password?.isEmpty ?? true) ||
        user.name.isEmpty) {
      throw ValidationException({
        'email': [
          'Email is required',
        ],
        'password': [
          'Password is required',
        ],
        'name': [
          'Name is required',
        ],
      });
    }
    final exists = await userExists(user.email, _mongoClient, _redisService);
    if (exists) {
      throw ValidationException({
        'email': [
          'User already exists',
        ],
      });
    }
    if (_mongoClient.db != null) {
      final refToken = JwtUtil.generateToken(user.id ?? "",
          duration: const Duration(days: 7), type: 'refresh');

      final accessToken = JwtUtil.generateToken(user.id ?? "");

      await _redisService.redisClient.set(
        key: 'refresh:${user.id}',
        value: refToken,
        ttl: const Duration(days: 7),
      );
      final collection =
          _mongoClient.db!.collection(AppConstants.usersCollection);
      await collection.insertOne(user.toJson());
      final token = JwtUtil.generateToken(user.id ?? "");
      await VerificationService.init();
      VerificationService.sendOtp(user.email, _redisService, user.id ?? "");
      return AuthenticationModel.fromJson(user.toJson())
          .copyWith(token: token, refreshToken: refToken);
    }
    throw MongoDartError('DB connection failed');
  }

  Future<AuthenticationModel> loginUser(String email, String password,
      MongoService _mongoClient, RedisService _redisService) async {
    _rateLimit(email, _mongoClient, _redisService);
    if (_mongoClient.db != null) {
      if (email.isEmpty || password.isEmpty) {
        throw ValidationException({
          'email': [
            'Email is required',
          ],
          'password': [
            'Password is required',
          ],
        });
      }

      final collection =
          _mongoClient.db!.collection(AppConstants.usersCollection);

      final user = await collection.findOne({'email': email});
      if (user == null) {
        throw BadRequestException("Invalid credentials");
      }

      final isPasswordValid = GeneralFunctions.verifyPassword(
        password,
        user['password'].toString(),
      );

      if (!isPasswordValid) {
        throw BadRequestException("Incorrect password");
      }
      await collection.updateOne(
        where.eq('email', email),
        modify.set('userMeta.lastLogin', DateTime.now()),
      );

      final userModel = AuthenticationModel.fromJson(user);

      final refToken = JwtUtil.generateToken(userModel.id ?? "",
          duration: const Duration(days: 7), type: 'refresh');

      final accessToken = JwtUtil.generateToken(userModel.id ?? "");

      await _redisService.redisClient.set(
        key: 'refresh:${userModel.id}',
        value: refToken,
        ttl: const Duration(days: 7),
      );

      if (userModel.userMeta?.isEmailVerified == false ||
          userModel.userMeta?.isEmailVerified == null) {
        await VerificationService.init();
        VerificationService.sendOtp(
            userModel.email, _redisService, userModel.id ?? "");
      }

      return AuthenticationModel.fromJson(user)
          .copyWith(token: accessToken, refreshToken: refToken);
    } else {
      throw MongoDartError('DB connection failed');
    }
  }

  Future<bool> userExists(String email, MongoService _mongoClient,
      RedisService _redisService) async {
    try {
      final collection =
          _mongoClient.db!.collection(AppConstants.usersCollection);
      final user = await collection.findOne({'email': email});
      return user != null;
    } catch (e) {
      throw DataBaseException('User exist already');
    }
  }

  Future<Map<String, dynamic>> refreshToken(
      String userId, RedisService _redisService, String token) async {
    final savedToken =
        await _redisService.redisClient.get(key: 'refresh:$userId');

    final refToken = savedToken;

    if (savedToken == null) {
      throw UnauthorizedException(message: 'Session expired');
    }

    if (savedToken != refToken) {
      throw UnauthorizedException(
          message: 'Saved token does not match $savedToken');
    }

    final newAccessToken = JwtUtil.generateToken(userId);
    final newRefreshToken = JwtUtil.generateToken(
      userId,
      duration: const Duration(days: 7),
      type: 'refresh',
    );

    await _redisService.redisClient.set(
      key: 'refresh:$userId',
      value: newRefreshToken,
      ttl: const Duration(days: 7),
    );

    return {'token': newAccessToken, "refreshToken": newRefreshToken};
  }

  Future<void> logoutUser(String userId, RedisService _redisService) async {
    await _redisService.redisClient.delete(key: 'refresh:$userId');
  }

  Future<void> _rateLimit(String email, MongoService _mongoClient,
      RedisService _redisService) async {
    final key = 'login_attempt:$email';

    final attempts = await _redisService.redisClient.increment(key: key);

    if (attempts == 1) {
      await _redisService.expire(
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
