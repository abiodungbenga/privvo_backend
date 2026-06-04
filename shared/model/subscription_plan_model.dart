class UserSubscription {
  UserSubscription({
    required this.plan,
    required this.status,
    this.startedAt,
    this.expiresAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: json['status'].toString(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : null,
    );
  }
  final SubscriptionPlan plan;
  final String status;
  final DateTime? startedAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.name,
      'status': status,
      'startedAt': startedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

enum SubscriptionPlan {
  free,
  basic,
  pro,
  enterprise,
}
