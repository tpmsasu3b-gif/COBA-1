class AppSettings {
  final int lowStockThreshold;
  final int expiryWarningDays;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language;

  AppSettings({
    this.lowStockThreshold = 2,
    this.expiryWarningDays = 30,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.language = 'id',
  });

  Map<String, dynamic> toJson() => {
        'lowStockThreshold': lowStockThreshold,
        'expiryWarningDays': expiryWarningDays,
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'soundEnabled': soundEnabled,
        'language': language,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        lowStockThreshold: json['lowStockThreshold'] ?? 2,
        expiryWarningDays: json['expiryWarningDays'] ?? 30,
        isDarkMode: json['isDarkMode'] ?? false,
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        soundEnabled: json['soundEnabled'] ?? true,
        language: json['language'] ?? 'id',
      );

  AppSettings copyWith({
    int? lowStockThreshold,
    int? expiryWarningDays,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
  }) {
    return AppSettings(
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      expiryWarningDays: expiryWarningDays ?? this.expiryWarningDays,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
    );
  }
}
