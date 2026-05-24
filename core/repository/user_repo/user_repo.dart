import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/user_model.dart';
import '../../data/mongo/mongo_service.dart';

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

  Future<UserModel> updateUser(
      UserModel user, MongoService _mongoClient) async {
    final collection =
        _mongoClient.db!.collection(AppConstants.usersCollection);
    await collection.update({'id': user.id}, user.toJson());
    return user;
  }

  Future<void> deleteUser(String userId, MongoService _mongoClient) async {
    final collection =
        _mongoClient.db!.collection(AppConstants.usersCollection);
    await collection.deleteOne({'id': userId});
  }
}
