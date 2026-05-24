class UserMeta {
  final String? profileUrl;
  final int? storageUsed;
  final int? storageLimit;
  final String? language;
  final DateTime? createdAt;
  final DateTime? lastLoggedIn;

  UserMeta({
    this.profileUrl,
    this.createdAt,
    this.language,
    this.lastLoggedIn,
    this.storageUsed,
    this.storageLimit,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      profileUrl: json['profileUrl'] as String?,
      storageUsed: json['storageUsed'] as int?,
      storageLimit: json['storageLimit'] as int?,
      language: json['language'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoggedIn: json['lastLoggedIn'] != null
          ? DateTime.parse(json['lastLoggedIn'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileUrl': profileUrl,
      'storageUsed': storageUsed,
      'storageLimit': storageLimit,
      'language': language,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoggedIn': lastLoggedIn?.toIso8601String(),
    };
  }
}
