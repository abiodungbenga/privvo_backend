import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/model/google_sign_in.dart';
import '../../data/mongo/mongo_service.dart';
import '../../exceptions/app_exceptions.dart';
import '../../services/jwt/jwt_util.dart';
import '../../services/redis/redis_service.dart';

class GoogleSigninRepository {
  var client = http.Client();

  Future<GoogleSignInModel?> initiateGoogleSignIn({String? idToken}) async {
    try {
      final url = Uri.parse(
          'https://oauth2.googleapis.com/tokeninfo?id_token=$idToken');
      final response = await client.get(url);

      log("Google Signin Response: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GoogleSignInModel.fromJson(
            json.decode(response.body) as Map<String, dynamic>);
      }
    } catch (e) {
      throw BadRequestException('Invalid IdToken $e');
    }
  }

  Future<AuthenticationModel?> signInWithGoogle(
      AuthenticationModel user,
      String idToken,
      GoogleSignInModel? googleUser,
      MongoService mongoService,
      RedisService redisService) async {
    final collection =
        mongoService.db!.collection(AppConstants.usersCollection);

    final existingUser = await collection.findOne({
      'id': user.id,
    });

    if (existingUser != null && googleUser != null) {
      final refToken = JwtUtil.generateToken(user.id ?? "",
          duration: const Duration(days: 7), type: 'refresh');

      await redisService.redisClient.set(
        key: 'refresh:${user.id}',
        value: refToken,
        ttl: const Duration(days: 7),
      );

      final token = JwtUtil.generateToken(user.id ?? "");
      return AuthenticationModel.fromJson(existingUser)
          .copyWith(token: token, refreshToken: refToken);
    }
    if (googleUser != null) {
      if (mongoService.db != null) {
        final refToken = JwtUtil.generateToken(user.id ?? "",
            duration: const Duration(days: 7), type: 'refresh');

        await redisService.redisClient.set(
          key: 'refresh:${user.id}',
          value: refToken,
          ttl: const Duration(days: 7),
        );

        final token = JwtUtil.generateToken(user.id ?? "");
        final collection =
            mongoService.db!.collection(AppConstants.usersCollection);
        await collection.insertOne(user.toJson());
        return AuthenticationModel.fromJson(user.toJson())
            .copyWith(token: token, refreshToken: refToken);
      }
    }
    throw BadRequestException('Could not create user');
  }
}
