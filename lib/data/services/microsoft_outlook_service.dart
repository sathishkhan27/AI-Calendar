import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/connected_account.dart';
import '../models/event_item.dart';

class MicrosoftOutlookService {
  final http.Client _client;

  MicrosoftOutlookService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<EventItem>> fetchEvents({
    required ConnectedAccount account,
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    if (account.accessToken != null && account.accessToken!.isNotEmpty) {
      try {
        final startIso = timeMin.toUtc().toIso8601String();
        final endIso = timeMax.toUtc().toIso8601String();
        final uri = Uri.parse(
          'https://graph.microsoft.com/v1.0/me/calendarView?'
          'startDateTime=$startIso&'
          'endDateTime=$endIso&'
          '\$select=id,subject,bodyPreview,start,end,isOnlineMeeting,onlineMeeting,onlineMeetingProvider,location,attendees&'
          '\$orderby=start/dateTime',
        );

        final response = await _client.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${account.accessToken}',
            'Accept': 'application/json',
            'Prefer': 'outlook.timezone="UTC"',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final items = data['value'] as List<dynamic>? ?? [];
          return items
              .map((item) => _parseOutlookEvent(item as Map<String, dynamic>, account.email))
              .toList();
        }
      } catch (_) {}
    }

    return [];
  }

  EventItem _parseOutlookEvent(Map<String, dynamic> json, String accountEmail) {
    final startRaw = json['start']?['dateTime'] as String?;
    final endRaw = json['end']?['dateTime'] as String?;
    final isAllDay = json['isAllDay'] as bool? ?? false;

    final startTime = startRaw != null ? DateTime.parse(startRaw) : DateTime.now();
    final endTime =
        endRaw != null ? DateTime.parse(endRaw) : startTime.add(const Duration(hours: 1));

    String? meetingUrl;
    CallType callType = CallType.none;

    final isOnlineMeeting = json['isOnlineMeeting'] as bool? ?? false;
    final onlineMeeting = json['onlineMeeting'] as Map<String, dynamic>?;

    if (onlineMeeting != null && onlineMeeting['joinUrl'] != null) {
      meetingUrl = onlineMeeting['joinUrl'] as String;
      callType = CallType.msTeams;
    } else if (isOnlineMeeting) {
      callType = CallType.msTeams;
    }

    final attendeesList = <Attendee>[];
    final rawAttendees = json['attendees'] as List<dynamic>?;
    if (rawAttendees != null) {
      for (final a in rawAttendees) {
        final emailAddress = a['emailAddress'] as Map<String, dynamic>?;
        attendeesList.add(
          Attendee(
            name: emailAddress?['name'] as String? ?? 'Team Member',
            email: emailAddress?['address'] as String? ?? '',
            isOrganizer: a['type'] == 'organizer',
          ),
        );
      }
    }

    return EventItem(
      id: json['id'] as String? ?? 'ms_${DateTime.now().millisecondsSinceEpoch}',
      title: json['subject'] as String? ?? 'Outlook Meeting',
      description: json['bodyPreview'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      source: EventSource.outlook,
      callType: callType,
      meetingUrl: meetingUrl,
      location: json['location']?['displayName'] as String?,
      attendees: attendeesList,
      accountEmail: accountEmail,
      isAllDay: isAllDay,
      colorTheme: callType == CallType.msTeams ? EventPastelColor.lavender : EventPastelColor.sky,
    );
  }
}
