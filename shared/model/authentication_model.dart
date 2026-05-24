import 'subscription_plan_model.dart';
import 'user_meta.dart';

class AuthenticationModel {
  final String? id;
  final String? token;
  final String? refreshToken;
  final String name;
  final String email;
  final String? password;
  final UserMeta? userMeta;
  final UserSubscription? userSubscription;

  AuthenticationModel({
    this.id,
    this.refreshToken,
    this.userMeta,
    this.userSubscription,
    this.token,
    required this.name,
    required this.email,
    this.password,
  });

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      id: json['id'] as String?,
      userMeta: json['userMeta'] != null
          ? UserMeta.fromJson(
              json['userMeta'] as Map<String, dynamic>,
            )
          : null,
      userSubscription: json['userSubscription'] != null
          ? UserSubscription.fromJson(
              json['userSubscription'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String,
      refreshToken: json['refreshToken'] as String?,
      token: json['token'] as String?,
      email: json['email'] as String,
    );
  }

  AuthenticationModel copyWith({String? token, String? refreshToken}) {
    return AuthenticationModel(
        name: name,
        password: password,
        id: id,
        email: email,
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      if (userMeta != null) 'userMeta': password,
      if (userSubscription != null) 'userSubscription': password,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
