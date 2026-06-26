import 'subscription_plan_model.dart';
import 'user_meta.dart';

class UserModel {
  UserModel({
    this.id,
    this.userMeta,
    this.userSubscription,
    required this.name,
    required this.email,
    this.encryptionKey,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      encryptionKey: json['encryptionKey'] as String,
      userMeta: json['userMeta'] != null
          ? UserMeta.fromJson(
              json['userMeta'] as Map<String, dynamic>,
            )
          : null,
      userSubscription: json['userSubscription'] != null
          ? UserSubscription.fromJson(
              json['userSubscription'] as Map<String, dynamic>)
          : null,
      email: json['email'] as String,
    );
  }
  final String? id;
  final String name;
  final String email;

  final String? encryptionKey;
  final UserMeta? userMeta;
  final UserSubscription? userSubscription;

  UserModel copyWith({
    String? name,
    String? id,
    UserMeta? userMeta,
    UserSubscription? userSubscription,
  }) {
    return UserModel(
      name: name ?? '',
      userMeta: userMeta,
      userSubscription: userSubscription,
      id: id,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'encryptionKey': encryptionKey,
      'userMeta': userMeta?.toJson(),
      'userSubscription': userSubscription?.toJson(),
      'email': email,
    };
  }
}
