class UserMeta {
  final String? profileUrl;
  final int? storageUsedMb;
  final int? storageLimitMb;
  final String? language;
  final bool isDark;
  final DateTime? createdAt;
  final DateTime? lastLoggedIn;

  UserMeta({
    this.profileUrl,
    this.isDark = false,
    this.createdAt,
    this.language,
    this.lastLoggedIn,
    this.storageUsedMb,
    this.storageLimitMb,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      profileUrl: json['profileUrl'] as String?,
      isDark: json['isDark'] as bool,
      storageLimitMb: json['storageLimitMb'] as int?,
      storageUsedMb: json['storageUsedMb'] as int?,
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
      'isDark': isDark,
      'storageUsedMb': storageUsedMb,
      'storageLimitMb': storageLimitMb,
      'language': language,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoggedIn': lastLoggedIn?.toIso8601String(),
    };
  }
}
