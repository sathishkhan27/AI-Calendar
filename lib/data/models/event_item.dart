import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum EventSource {
  google,
  outlook,
  local,
  tamilHoliday;

  String get displayName {
    switch (this) {
      case EventSource.google:
        return 'Google Calendar';
      case EventSource.outlook:
        return 'Outlook / Teams';
      case EventSource.local:
        return 'Personal Calendar';
      case EventSource.tamilHoliday:
        return 'Tamil Nadu Public Holiday';
    }
  }
}

enum CallType {
  googleMeet,
  msTeams,
  zoom,
  phone,
  none;

  String get displayName {
    switch (this) {
      case CallType.googleMeet:
        return 'Google Meet';
      case CallType.msTeams:
        return 'Microsoft Teams';
      case CallType.zoom:
        return 'Zoom';
      case CallType.phone:
        return 'Phone Call';
      case CallType.none:
        return 'In Person / Task';
    }
  }

  bool get isCall => this != CallType.none;
}

enum EventPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case EventPriority.high:
        return 'High Priority';
      case EventPriority.medium:
        return 'Normal';
      case EventPriority.low:
        return 'Low';
    }
  }
}

enum EventPastelColor {
  peach,
  lavender,
  mint,
  sky,
  pink,
  whiteTask,
  holidayGold;

  Color get bgColor {
    switch (this) {
      case EventPastelColor.peach:
        return AppColors.pastelPeach;
      case EventPastelColor.lavender:
        return AppColors.pastelLavender;
      case EventPastelColor.mint:
        return AppColors.pastelMint;
      case EventPastelColor.sky:
        return AppColors.pastelSky;
      case EventPastelColor.pink:
        return AppColors.pastelPink;
      case EventPastelColor.whiteTask:
        return AppColors.surface;
      case EventPastelColor.holidayGold:
        return const Color(0xFFFEF3C7); // Warm Saffron / Gold
    }
  }

  Color get borderColor {
    switch (this) {
      case EventPastelColor.peach:
        return AppColors.pastelPeachBorder;
      case EventPastelColor.lavender:
        return AppColors.pastelLavenderBorder;
      case EventPastelColor.mint:
        return AppColors.pastelMintBorder;
      case EventPastelColor.sky:
        return AppColors.pastelSkyBorder;
      case EventPastelColor.pink:
        return AppColors.pastelPinkBorder;
      case EventPastelColor.whiteTask:
        return AppColors.border;
      case EventPastelColor.holidayGold:
        return const Color(0xFFF59E0B); // Amber / Gold Border
    }
  }

  Color get textColor {
    switch (this) {
      case EventPastelColor.peach:
        return AppColors.pastelPeachText;
      case EventPastelColor.lavender:
        return AppColors.pastelLavenderText;
      case EventPastelColor.mint:
        return AppColors.pastelMintText;
      case EventPastelColor.sky:
        return AppColors.pastelSkyText;
      case EventPastelColor.pink:
        return AppColors.pastelPinkText;
      case EventPastelColor.whiteTask:
        return AppColors.textPrimary;
      case EventPastelColor.holidayGold:
        return const Color(0xFFB45309); // Deep Amber Text
    }
  }
}


class Attendee {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOrganizer;

  const Attendee({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOrganizer = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'isOrganizer': isOrganizer,
      };

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      name: json['name'] as String? ?? 'Attendee',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isOrganizer: json['isOrganizer'] as bool? ?? false,
    );
  }
}

class EventItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventSource source;
  final CallType callType;
  final String? meetingUrl;
  final String? location;
  final List<Attendee> attendees;
  final String? aiSummary;
  final String? aiPrepNotes;
  final EventPriority priority;
  final bool isCompleted;
  final String? accountEmail;
  final bool isAllDay;
  final bool isTask;
  final bool isHoliday;
  final EventPastelColor colorTheme;

  const EventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.callType = CallType.none,
    this.meetingUrl,
    this.location,
    this.attendees = const [],
    this.aiSummary,
    this.aiPrepNotes,
    this.priority = EventPriority.medium,
    this.isCompleted = false,
    this.accountEmail,
    this.isAllDay = false,
    this.isTask = false,
    this.isHoliday = false,
    this.colorTheme = EventPastelColor.peach,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isCall => callType.isCall || (meetingUrl != null && meetingUrl!.isNotEmpty);

  bool isHappeningAt(DateTime time) {
    return (time.isAfter(startTime) || time.isAtSameMomentAs(startTime)) &&
        time.isBefore(endTime);
  }

  bool conflictsWith(EventItem other) {
    if (id == other.id) return false;
    if (isAllDay || other.isAllDay) return false;
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  EventItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventSource? source,
    CallType? callType,
    String? meetingUrl,
    String? location,
    List<Attendee>? attendees,
    String? aiSummary,
    String? aiPrepNotes,
    EventPriority? priority,
    bool? isCompleted,
    String? accountEmail,
    bool? isAllDay,
    bool? isTask,
    bool? isHoliday,
    EventPastelColor? colorTheme,
  }) {
    return EventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      callType: callType ?? this.callType,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      aiSummary: aiSummary ?? this.aiSummary,
      aiPrepNotes: aiPrepNotes ?? this.aiPrepNotes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      accountEmail: accountEmail ?? this.accountEmail,
      isAllDay: isAllDay ?? this.isAllDay,
      isTask: isTask ?? this.isTask,
      isHoliday: isHoliday ?? this.isHoliday,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'source': source.name,
        'callType': callType.name,
        'meetingUrl': meetingUrl,
        'location': location,
        'attendees': attendees.map((a) => a.toJson()).toList(),
        'aiSummary': aiSummary,
        'aiPrepNotes': aiPrepNotes,
        'priority': priority.name,
        'isCompleted': isCompleted,
        'accountEmail': accountEmail,
        'isAllDay': isAllDay,
        'isTask': isTask,
        'isHoliday': isHoliday,
        'colorTheme': colorTheme.name,
      };

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      source: EventSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => EventSource.local,
      ),
      callType: CallType.values.firstWhere(
        (e) => e.name == json['callType'],
        orElse: () => CallType.none,
      ),
      meetingUrl: json['meetingUrl'] as String?,
      location: json['location'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((a) => Attendee.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
      aiSummary: json['aiSummary'] as String?,
      aiPrepNotes: json['aiPrepNotes'] as String?,
      priority: EventPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => EventPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      accountEmail: json['accountEmail'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      isTask: json['isTask'] as bool? ?? false,
      isHoliday: json['isHoliday'] as bool? ?? false,
      colorTheme: EventPastelColor.values.firstWhere(
        (c) => c.name == json['colorTheme'],
        orElse: () => EventPastelColor.peach,
      ),
    );
  }
}
