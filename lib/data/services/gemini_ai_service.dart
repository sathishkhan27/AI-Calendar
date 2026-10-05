import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/daily_briefing.dart';
import '../models/event_item.dart';
import 'tamil_panchangam_service.dart';

class GeminiAiService {
  final http.Client _client;

  GeminiAiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generates an executive daily briefing analyzing calls, events, and action items
  Future<DailyBriefing> generateDailyBriefing({
    required DateTime date,
    required List<EventItem> dayEvents,
    String? apiKey,
  }) async {
    final calls = dayEvents.where((e) => e.isCall).toList();
    final totalDuration = dayEvents.fold<int>(
      0,
      (sum, e) => sum + e.duration.inMinutes,
    );
    // Work day assumed 8 hours = 480 mins
    final focusTime = (480 - totalDuration).clamp(0, 480);

    // Conflict detection
    final conflicts = <String>[];
    for (int i = 0; i < dayEvents.length; i++) {
      for (int j = i + 1; j < dayEvents.length; j++) {
        if (dayEvents[i].conflictsWith(dayEvents[j])) {
          final timeStr = DateFormat('h:mm a').format(dayEvents[i].startTime);
          conflicts.add(
            'Conflict at $timeStr: "${dayEvents[i].title}" overlaps with "${dayEvents[j].title}"',
          );
        }
      }
    }

    // If Gemini API key is provided, try calling the live Gemini API
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final briefing = await _callGeminiBriefingApi(
          apiKey: apiKey,
          date: date,
          events: dayEvents,
          calls: calls,
          conflicts: conflicts,
          totalDuration: totalDuration,
          focusTime: focusTime,
        );
        if (briefing != null) return briefing;
      } catch (_) {
        // Fall back to local AI engine
      }
    }

    // High quality built-in heuristic analysis engine
    return _generateLocalIntelligentBriefing(
      date: date,
      dayEvents: dayEvents,
      calls: calls,
      conflicts: conflicts,
      totalDuration: totalDuration,
      focusTime: focusTime,
    );
  }

  DailyBriefing _generateLocalIntelligentBriefing({
    required DateTime date,
    required List<EventItem> dayEvents,
    required List<EventItem> calls,
    required List<String> conflicts,
    required int totalDuration,
    required int focusTime,
  }) {
    final dateStr = DateFormat('EEEE, MMM d').format(date);

    final holidays = dayEvents.where((e) => e.isHoliday || e.source == EventSource.tamilHoliday).toList();

    String summary;
    if (holidays.isNotEmpty) {
      summary = '🚩 State Holiday: Today is ${holidays.first.title}. Official Tamil Nadu gazetted public holiday with schools, banks, and government offices closed.';
    } else if (dayEvents.isEmpty) {
      summary = 'Your calendar is completely open for $dateStr. Great time for deep focused work!';
    } else if (calls.length >= 3) {
      summary =
          'You have a meeting-heavy schedule today with ${calls.length} scheduled calls across Google Meet and Teams. Plan 10-minute breathers between sessions.';
    } else if (conflicts.isNotEmpty) {
      summary =
          'Attention needed: You have ${conflicts.length} overlapping schedule conflict(s) today. Review your priorities to reschedule or delegate.';
    } else {
      summary =
          'You have a balanced day on $dateStr with ${dayEvents.length} items (${calls.length} calls) and ~$focusTime minutes of uninterrupted focus time.';
    }

    final highlights = <String>[];
    final actions = <String>[];

    final panchangam = const TamilPanchangamService().getDailyTimings(date);
    highlights.add('✨ நல்ல நேரம்: ${panchangam.nallaNeramMorning.timeFormatted} & ${panchangam.nallaNeramEvening.timeFormatted}');
    highlights.add('⚠️ இராகு காலம் (Rahu Kalam): ${panchangam.rahuKalam.timeFormatted}');

    for (final h in holidays) {
      highlights.add('🚩 Public Holiday: ${h.title}');
      actions.add('Observe official Tamil Nadu state holiday: ${h.title}');
    }

    for (final e in dayEvents) {
      if (e.isHoliday || e.source == EventSource.tamilHoliday) continue;
      final timeFormatted =
          '${DateFormat('h:mm a').format(e.startTime)} - ${DateFormat('h:mm a').format(e.endTime)}';
      if (e.isCall) {
        highlights.add('${e.callType.displayName} ($timeFormatted): ${e.title}');
        if (e.aiPrepNotes != null) {
          actions.add('Prep for "${e.title}": ${e.aiPrepNotes}');
        } else {
          actions.add('Review agenda & attendees for "${e.title}"');
        }
      } else {
        highlights.add('$timeFormatted: ${e.title}');
      }
    }

    if (actions.isEmpty && dayEvents.isNotEmpty) {
      actions.add('Complete pre-meeting briefs before lunch');
      actions.add('Block 30 minutes for asynchronous email triaging');
    }

    String tip = focusTime > 180
        ? '💡 High productivity window: Use your morning block for deep architectural design.'
        : '💡 Meeting density is high: Keep your camera off in listening-only syncs to conserve energy.';

    return DailyBriefing(
      date: date,
      executiveSummary: summary,
      scheduleHighlights: highlights,
      actionItems: actions,
      conflictAlerts: conflicts,
      totalEvents: dayEvents.length,
      totalCalls: calls.length,
      meetingDurationMinutes: totalDuration,
      focusTimeMinutes: focusTime,
      productivityTip: tip,
    );
  }

  Future<DailyBriefing?> _callGeminiBriefingApi({
    required String apiKey,
    required DateTime date,
    required List<EventItem> events,
    required List<EventItem> calls,
    required List<String> conflicts,
    required int totalDuration,
    required int focusTime,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final eventDescriptions = events
        .map((e) =>
            '- ${e.title} (${e.startTime.toIso8601String()} to ${e.endTime.toIso8601String()}), Source: ${e.source.displayName}, Call: ${e.callType.displayName}')
        .join('\n');

    final prompt = '''
You are an executive AI Calendar Assistant. Analyze the user's schedule for ${DateFormat('yyyy-MM-dd').format(date)}:
Events:
$eventDescriptions

Provide a JSON response with this exact structure:
{
  "executiveSummary": "Concise 2-sentence summary of the day",
  "scheduleHighlights": ["Highlight 1", "Highlight 2"],
  "actionItems": ["Specific action item 1", "Action item 2"],
  "productivityTip": "A customized productivity tip"
}
Output only pure JSON without markdown code fences.
''';

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'responseMimeType': 'application/json'}
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final candidate = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (candidate != null) {
        final parsed = jsonDecode(candidate) as Map<String, dynamic>;
        return DailyBriefing(
          date: date,
          executiveSummary: parsed['executiveSummary'] as String? ?? 'Your daily schedule is prepared.',
          scheduleHighlights: (parsed['scheduleHighlights'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          actionItems: (parsed['actionItems'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          conflictAlerts: conflicts,
          totalEvents: events.length,
          totalCalls: calls.length,
          meetingDurationMinutes: totalDuration,
          focusTimeMinutes: focusTime,
          productivityTip: parsed['productivityTip'] as String? ?? 'Stay focused and organized.',
        );
      }
    }
    return null;
  }

  /// Parses natural language query into an EventItem
  EventItem parseNaturalLanguageEvent(String input, DateTime referenceDate) {
    final lower = input.toLowerCase();

    // Default duration 30 mins
    int durationMinutes = 30;
    if (lower.contains('45 min') || lower.contains('45m')) {
      durationMinutes = 45;
    } else if (lower.contains('1 hour') || lower.contains('60 min') || lower.contains('1h')) {
      durationMinutes = 60;
    } else if (lower.contains('15 min') || lower.contains('15m')) {
      durationMinutes = 15;
    } else if (lower.contains('2 hour')) {
      durationMinutes = 120;
    }

    // Call type
    CallType callType = CallType.none;
    String? meetingUrl;
    if (lower.contains('meet') || lower.contains('google meet')) {
      callType = CallType.googleMeet;
      meetingUrl = 'https://meet.google.com/new';
    } else if (lower.contains('teams') || lower.contains('microsoft teams')) {
      callType = CallType.msTeams;
      meetingUrl = 'https://teams.microsoft.com/l/meetup-join/new';
    } else if (lower.contains('zoom')) {
      callType = CallType.zoom;
      meetingUrl = 'https://zoom.us/join';
    } else if (lower.contains('call') || lower.contains('sync')) {
      callType = CallType.googleMeet;
      meetingUrl = 'https://meet.google.com/new';
    }

    // Determine target day
    DateTime targetDate = referenceDate;
    if (lower.contains('tomorrow')) {
      targetDate = referenceDate.add(const Duration(days: 1));
    }

    // Parse hour and minute
    int hour = 14; // default 2 PM
    int minute = 0;

    // First search for "at <time>" pattern like "at 3pm" or "at 3:30 pm"
    final atTimeRegex = RegExp(r'\bat\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b', caseSensitive: false);
    final atMatch = atTimeRegex.firstMatch(input);

    RegExpMatch? match = atMatch;
    if (match == null) {
      // Fallback: search for numbers explicitly followed by am/pm like "3pm" or "10:30am"
      final amPmTimeRegex = RegExp(r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b', caseSensitive: false);
      match = amPmTimeRegex.firstMatch(input);
    }

    if (match != null) {
      int parsedHour = int.tryParse(match.group(1) ?? '') ?? 14;
      minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final amPm = match.group(3)?.toLowerCase();

      if (amPm == 'pm' && parsedHour < 12) {
        parsedHour += 12;
      } else if (amPm == 'am' && parsedHour == 12) {
        parsedHour = 0;
      } else if (amPm == null && parsedHour >= 1 && parsedHour <= 7) {
        // Assume afternoon for 1 to 7 without AM/PM specified
        parsedHour += 12;
      }
      hour = parsedHour;
    }

    final startTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    // Extract title
    String title = input;
    // Clean up common prefix keywords
    title = title.replaceAll(RegExp(r'^(schedule|create|add|set up|book)\s+', caseSensitive: false), '');

    return EventItem(
      id: 'ai_created_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Scheduled Meeting' : title,
      description: 'Created via AI Calendar Assistant: "$input"',
      startTime: startTime,
      endTime: endTime,
      source: EventSource.local,
      callType: callType,
      meetingUrl: meetingUrl,
      aiSummary: 'Auto-scheduled by AI assistant.',
      priority: EventPriority.medium,
    );
  }
}
