class DailyBriefing {
  final DateTime date;
  final String executiveSummary;
  final List<String> scheduleHighlights;
  final List<String> actionItems;
  final List<String> conflictAlerts;
  final int totalEvents;
  final int totalCalls;
  final int meetingDurationMinutes;
  final int focusTimeMinutes;
  final String productivityTip;

  const DailyBriefing({
    required this.date,
    required this.executiveSummary,
    required this.scheduleHighlights,
    required this.actionItems,
    this.conflictAlerts = const [],
    required this.totalEvents,
    required this.totalCalls,
    required this.meetingDurationMinutes,
    required this.focusTimeMinutes,
    required this.productivityTip,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'executiveSummary': executiveSummary,
        'scheduleHighlights': scheduleHighlights,
        'actionItems': actionItems,
        'conflictAlerts': conflictAlerts,
        'totalEvents': totalEvents,
        'totalCalls': totalCalls,
        'meetingDurationMinutes': meetingDurationMinutes,
        'focusTimeMinutes': focusTimeMinutes,
        'productivityTip': productivityTip,
      };

  factory DailyBriefing.fromJson(Map<String, dynamic> json) {
    return DailyBriefing(
      date: DateTime.parse(json['date'] as String),
      executiveSummary: json['executiveSummary'] as String? ?? '',
      scheduleHighlights: (json['scheduleHighlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      conflictAlerts: (json['conflictAlerts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      totalEvents: json['totalEvents'] as int? ?? 0,
      totalCalls: json['totalCalls'] as int? ?? 0,
      meetingDurationMinutes: json['meetingDurationMinutes'] as int? ?? 0,
      focusTimeMinutes: json['focusTimeMinutes'] as int? ?? 0,
      productivityTip: json['productivityTip'] as String? ?? '',
    );
  }
}
