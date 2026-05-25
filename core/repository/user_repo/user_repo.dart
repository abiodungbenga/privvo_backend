import 'package:mongo_dart/mongo_dart.dart';

import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/user_model.dart';
import '../../data/mongo/mongo_service.dart';
import '../../exceptions/app_exceptions.dart';
import '../../services/redis/redis_service.dart';
import '../../services/verification/verification_service.dart';

class UserRepo {
  Future<UserModel> getUser(String userId, MongoService _mongoClient) async {
    final collection =
        _mongoClient.db!.collection(AppConstants.usersCollection);
    final user = await collection.findOne({'id': userId});
    return UserModel.fromJson(user!);
  }

  Future<List<UserModel>> getAllUsers(MongoService _mongoClient) async {
    final collection =
        _mongoClient.db!.collection(AppConstants.usersCollection);
    final users = await collection.find().toList();
    return users.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<bool> verifyUser(
    String otp,
    String userId,
    RedisService _redisService,
    MongoService mongoClient,
  ) async {
    final bool otpCorrect = VerificationService.verifyOtp(otp);
    final collection = mongoClient.db!.collection(AppConstants.usersCollection);
    final String? redisString =
        await _redisService.redisClient.get(key: 'otp:$userId');
    if (redisString == null) {
      throw BadRequestException('OTP expired please resend');
    }
    if (otpCorrect && otp == redisString) {
      await collection.updateOne(
          where.eq('id', userId), modify.set('userMeta.isEmailVerified', true));
      return otpCorrect;
    }
    return otpCorrect;
  }

  Future<UserModel> updateUser(
    UserModel user,
    String userId,
    MongoService mongoClient,
  ) async {
    final collection = mongoClient.db!.collection(AppConstants.usersCollection);

    final prevData = await getUser(userId, mongoClient);
    await collection.updateOne(
      where.eq('id', userId),
      modify
          .set('name', user.name.isEmpty)
          .set("userMeta", user.userMeta?.toJson())
          .set("userSubscription", user.userSubscription?.toJson()),
    );

    final data = user.copyWith(
      id: prevData.id,
      name: user.name.isEmpty ? prevData.name : user.name,
      userMeta: user.userMeta ?? prevData.userMeta,
      userSubscription: user.userSubscription ?? prevData.userSubscription,
    );

    return data;
  }

  Future<void> deleteUser(String userId, MongoService _mongoClient) async {
    final collection =
        _mongoClient.db!.collection(AppConstants.usersCollection);
    await collection.deleteOne({'id': userId});
  }
}
