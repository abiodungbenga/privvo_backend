import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/authentication_model.dart';
import '../../../shared/model/google_sign_in.dart';
import '../../data/mongo/mongo_service.dart';
import '../../exceptions/app_exceptions.dart';
import '../../services/redis/redis_service.dart';
import '../auth/auth_repo.dart';

class GoogleSigninRepository {
  var client = http.Client();

  Future<GoogleSignInModel?> initiateGoogleSignIn({String? idToken}) async {
    var url =
        Uri.parse('https://oauth2.googleapis.com/tokeninfo?id_token=$idToken');
    var response = await client.post(url);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return GoogleSignInModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw UnimplementedError("Invalid id token");
  }

  Future<AuthenticationModel?> signInWithGoogle(
      AuthRepository authRepo,
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

    if (existingUser != null) {
      return AuthenticationModel.fromJson(existingUser);
    }
    if (googleUser != null) {
      final createdUser = authRepo.createUser(user, mongoService, redisService);
      return createdUser;
    }
    throw BadRequestException("Could not create user");
  }
}
