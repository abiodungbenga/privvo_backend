class UserMeta {
  UserMeta({
    this.profileUrl,
    this.signInMethod = "sf-auth",
    this.isDark = false,
    this.isEmailVerified = false,
    this.createdAt,
    this.language,
    this.lastLoggedIn,
    this.updatedAt,
    this.storageUsedMb,
    this.storageLimitMb,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      profileUrl: json['profileUrl'] as String?,
      signInMethod: json['signInMethod'] as String?,
      isDark: json['isDark'] as bool,
      isEmailVerified: json['isEmailVerified'] as bool,
      storageLimitMb: json['storageLimitMb'] as int?,
      storageUsedMb: json['storageUsedMb'] as int?,
      language: json['language'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoggedIn: json['lastLoggedIn'] != null
          ? DateTime.parse(json['lastLoggedIn'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  final String? profileUrl;
  final int? storageUsedMb;
  final int? storageLimitMb;
  final String? language;
  final String? signInMethod;
  final bool isDark;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoggedIn;

  Map<String, dynamic> toJson() {
    return {
      'profileUrl': profileUrl,
      'isDark': isDark,
      'signInMethod': signInMethod,
      'isEmailVerified': isEmailVerified,
      'storageUsedMb': storageUsedMb,
      'storageLimitMb': storageLimitMb,
      'language': language,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoggedIn': lastLoggedIn?.toIso8601String(),
    };
  }
}
