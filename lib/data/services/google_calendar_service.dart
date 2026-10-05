import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/connected_account.dart';
import '../models/event_item.dart';

class GoogleCalendarService {
  final http.Client _client;

  GoogleCalendarService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<EventItem>> fetchEvents({
    required ConnectedAccount account,
    required DateTime timeMin,
    required DateTime timeMax,
  }) async {
    if (account.accessToken != null && account.accessToken!.isNotEmpty) {
      try {
        final uri = Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/primary/events?'
          'timeMin=${timeMin.toUtc().toIso8601String()}&'
          'timeMax=${timeMax.toUtc().toIso8601String()}&'
          'singleEvents=true&'
          'orderBy=startTime',
        );

        final response = await _client.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${account.accessToken}',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];
          return items
              .map((item) => _parseGoogleEvent(item as Map<String, dynamic>, account.email))
              .toList();
        }
      } catch (_) {}
    }

    return [];
  }

  EventItem _parseGoogleEvent(Map<String, dynamic> json, String accountEmail) {
    final startRaw = json['start']?['dateTime'] ?? json['start']?['date'];
    final endRaw = json['end']?['dateTime'] ?? json['end']?['date'];
    final isAllDay = json['start']?['date'] != null;

    final startTime = startRaw != null ? DateTime.parse(startRaw as String) : DateTime.now();
    final endTime = endRaw != null
        ? DateTime.parse(endRaw as String)
        : startTime.add(const Duration(hours: 1));

    String? meetingUrl;
    CallType callType = CallType.none;

    final conferenceData = json['conferenceData'];
    if (conferenceData != null) {
      final entryPoints = conferenceData['entryPoints'] as List<dynamic>?;
      if (entryPoints != null && entryPoints.isNotEmpty) {
        for (final ep in entryPoints) {
          final uri = ep['uri'] as String?;
          if (uri != null && uri.contains('meet.google.com')) {
            meetingUrl = uri;
            callType = CallType.googleMeet;
            break;
          }
        }
      }
    }

    if (meetingUrl == null && json['hangoutLink'] != null) {
      meetingUrl = json['hangoutLink'] as String;
      callType = CallType.googleMeet;
    }

    final rawLocation = json['location'] as String?;
    final attendeesList = <Attendee>[];
    final rawAttendees = json['attendees'] as List<dynamic>?;
    if (rawAttendees != null) {
      for (final a in rawAttendees) {
        attendeesList.add(
          Attendee(
            name: a['displayName'] as String? ?? (a['email'] as String? ?? 'Guest'),
            email: a['email'] as String? ?? '',
            isOrganizer: a['organizer'] as bool? ?? false,
          ),
        );
      }
    }

    return EventItem(
      id: json['id'] as String? ?? 'g_${DateTime.now().millisecondsSinceEpoch}',
      title: json['summary'] as String? ?? 'Google Calendar Event',
      description: json['description'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      source: EventSource.google,
      callType: callType,
      meetingUrl: meetingUrl,
      location: rawLocation,
      attendees: attendeesList,
      accountEmail: accountEmail,
      isAllDay: isAllDay,
      colorTheme: callType == CallType.googleMeet ? EventPastelColor.peach : EventPastelColor.mint,
    );
  }
}
