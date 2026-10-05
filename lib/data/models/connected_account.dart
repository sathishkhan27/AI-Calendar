enum AccountProvider {
  google,
  microsoft;

  String get displayName {
    switch (this) {
      case AccountProvider.google:
        return 'Google Calendar & Meet';
      case AccountProvider.microsoft:
        return 'Outlook & Microsoft Teams';
    }
  }

  String get iconAsset {
    switch (this) {
      case AccountProvider.google:
        return 'google';
      case AccountProvider.microsoft:
        return 'microsoft';
    }
  }
}

class ConnectedAccount {
  final String id;
  final String email;
  final String displayName;
  final AccountProvider provider;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;
  final bool isConnected;
  final DateTime? lastSyncedAt;
  final bool syncEnabled;
  final int syncedEventsCount;

  const ConnectedAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.provider,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
    this.isConnected = true,
    this.lastSyncedAt,
    this.syncEnabled = true,
    this.syncedEventsCount = 0,
  });

  ConnectedAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    AccountProvider? provider,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    bool? isConnected,
    DateTime? lastSyncedAt,
    bool? syncEnabled,
    int? syncedEventsCount,
  }) {
    return ConnectedAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      isConnected: isConnected ?? this.isConnected,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncedEventsCount: syncedEventsCount ?? this.syncedEventsCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'provider': provider.name,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
        'isConnected': isConnected,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'syncEnabled': syncEnabled,
        'syncedEventsCount': syncedEventsCount,
      };

  factory ConnectedAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedAccount(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? json['email'] as String,
      provider: AccountProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AccountProvider.google,
      ),
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'] as String)
          : null,
      isConnected: json['isConnected'] as bool? ?? true,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      syncEnabled: json['syncEnabled'] as bool? ?? true,
      syncedEventsCount: json['syncedEventsCount'] as int? ?? 0,
    );
  }
}
