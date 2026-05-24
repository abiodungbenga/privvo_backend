import 'subscription_plan_model.dart';
import 'user_meta.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final UserMeta? userMeta;
  final UserSubscription? userSubscription;

  UserModel({
    this.id,
    this.userMeta,
    this.userSubscription,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String,
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

  UserModel copyWith() {
    return UserModel(
      name: name,
      id: id,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userMeta': userMeta,
      'userSubscription': userSubscription,
      'email': email,
    };
  }
}
