class UserPreferences {
  final String userId;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final String language;
  final String theme;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.language = 'ar',
    this.theme = 'dark',
    required this.lastUpdated,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] ?? '',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      emailNotifications: json['email_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      pushNotifications: json['push_notifications'] ?? true,
      language: json['language'] ?? 'ar',
      theme: json['theme'] ?? 'dark',
      lastUpdated: json['last_updated'] is String
          ? DateTime.tryParse(json['last_updated']) ?? DateTime.now()
          : json['last_updated'] != null
              ? (json['last_updated'] as dynamic).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'push_notifications': pushNotifications,
      'language': language,
      'theme': theme,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  UserPreferences copyWith({
    String? userId,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    String? language,
    String? theme,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
