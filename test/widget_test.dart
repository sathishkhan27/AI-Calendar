import 'package:flutter_test/flutter_test.dart';
import 'package:ai_calendar_app/data/models/event_item.dart';
import 'package:ai_calendar_app/data/repositories/calendar_repository.dart';
import 'package:ai_calendar_app/data/services/gemini_ai_service.dart';
import 'package:ai_calendar_app/data/services/tamil_holidays_service.dart';
import 'package:ai_calendar_app/data/services/tamil_panchangam_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('EventItem conflicts detection works correctly', () {
    final now = DateTime.now();
    final event1 = EventItem(
      id: 'e1',
      title: 'Sprint Planning',
      description: '',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      source: EventSource.google,
      callType: CallType.googleMeet,
    );

    final event2 = EventItem(
      id: 'e2',
      title: 'Client Demo',
      description: '',
      startTime: now.add(const Duration(minutes: 30)),
      endTime: now.add(const Duration(hours: 1, minutes: 30)),
      source: EventSource.outlook,
      callType: CallType.msTeams,
    );

    expect(event1.conflictsWith(event2), isTrue);
    expect(event2.conflictsWith(event1), isTrue);
  });

  test('GeminiAiService natural language parsing works', () {
    final service = GeminiAiService();
    final ref = DateTime(2026, 10, 5, 9, 0);
    final event = service.parseNaturalLanguageEvent(
      'Schedule a 45 min design review tomorrow at 3pm on Google Meet',
      ref,
    );

    expect(event.callType, CallType.googleMeet);
    expect(event.startTime.day, 6);
    expect(event.startTime.hour, 15);
    expect(event.duration.inMinutes, 45);
    expect(event.meetingUrl, contains('meet.google.com'));
  });

  test('TamilHolidaysService generates official Tamil Nadu public holidays', () {
    final service = TamilHolidaysService();
    final holidays2026 = service.getHolidaysForYear(2026);

    expect(holidays2026.isNotEmpty, isTrue);

    // Verify Pongal
    final pongal = holidays2026.firstWhere((h) => h.title.contains('Pongal'));
    expect(pongal.title, contains('தைப்பொங்கல்'));
    expect(pongal.startTime.month, 1);
    expect(pongal.isHoliday, isTrue);
    expect(pongal.source, EventSource.tamilHoliday);
    expect(pongal.colorTheme, EventPastelColor.holidayGold);

    // Verify Tamil New Year
    final puthandu = holidays2026.firstWhere((h) => h.title.contains('Tamil New Year'));
    expect(puthandu.title, contains('தமிழ்ப் புத்தாண்டு'));
    expect(puthandu.startTime.month, 4);
    expect(puthandu.startTime.day, 14);

    // Verify Deepavali
    final deepavali = holidays2026.firstWhere((h) => h.title.contains('Deepavali'));
    expect(deepavali.title, contains('தீபாவளி'));
    expect(deepavali.startTime.month, 11);
  });

  test('TamilPanchangamService computes correct good and bad timings for Monday', () {
    final service = const TamilPanchangamService();
    // 2026-10-05 is a Monday
    final monday = DateTime(2026, 10, 5);
    final timings = service.getDailyTimings(monday);

    expect(timings.tamilDayName, 'திங்கட்கிழமை');
    expect(timings.englishDayName, 'Monday');

    // Monday Rahu Kalam: 7:30 AM - 9:00 AM
    expect(timings.rahuKalam.startTime.hour, 7);
    expect(timings.rahuKalam.startTime.minute, 30);
    expect(timings.rahuKalam.endTime.hour, 9);
    expect(timings.rahuKalam.endTime.minute, 0);
    expect(timings.rahuKalam.isGood, isFalse);

    // Monday Morning Nalla Neram: 6:30 AM - 7:30 AM
    expect(timings.nallaNeramMorning.startTime.hour, 6);
    expect(timings.nallaNeramMorning.startTime.minute, 30);
    expect(timings.nallaNeramMorning.endTime.hour, 7);
    expect(timings.nallaNeramMorning.endTime.minute, 30);
    expect(timings.nallaNeramMorning.isGood, isTrue);

    // Bad timing conflict check
    final meetingDuringRahu = timings.getConflictingBadTiming(
      DateTime(2026, 10, 5, 8, 0),
      DateTime(2026, 10, 5, 8, 45),
    );
    expect(meetingDuringRahu, isNotNull);
    expect(meetingDuringRahu?.tamilLabel, 'இராகு காலம்');

    // Good timing match check
    final meetingDuringNallaNeram = timings.getMatchingGoodTiming(
      DateTime(2026, 10, 5, 6, 45),
      DateTime(2026, 10, 5, 7, 15),
    );
    expect(meetingDuringNallaNeram, isNotNull);
    expect(meetingDuringNallaNeram?.tamilLabel, 'காலை நல்ல நேரம்');
  });

  test('CalendarRepository does not contain hardcoded Google or Outlook accounts', () async {
    final repo = CalendarRepository();
    await repo.initialize();

    expect(repo.accounts.any((a) => a.id.startsWith('acc_google_primary')), isFalse);
    expect(repo.accounts.any((a) => a.id.startsWith('acc_outlook_primary')), isFalse);
    expect(repo.accounts.any((a) => a.email.contains('sathish.work@gmail.com')), isFalse);
    expect(repo.accounts.any((a) => a.email.contains('sathish@outlook.com')), isFalse);
  });

  test('TamilPanchangamService computes accurate Tamil solar calendar dates and 60-year cycle', () {
    const service = TamilPanchangamService();

    // 2026-10-05: Purattasi 19, Parabhava Year
    final oct5 = service.getTamilDate(DateTime(2026, 10, 5));
    expect(oct5.tamilMonth, 'புரட்டாசி');
    expect(oct5.tamilMonthEnglish, 'Purattasi');
    expect(oct5.tamilDay, 19);
    expect(oct5.tamilYear, 'பராபவ');
    expect(oct5.shortTamilDate, 'புரட்டாசி 19');
    expect(oct5.fullTamilDate, 'புரட்டாசி 19, பராபவ ஆண்டு');

    // 2026-01-14: Thai 1 (Pongal), Visvavasu Year
    final thai1 = service.getTamilDate(DateTime(2026, 1, 14));
    expect(thai1.tamilMonth, 'தை');
    expect(thai1.tamilDay, 1);
    expect(thai1.tamilYear, 'விசுவாசு');
    expect(thai1.shortTamilDate, 'தை 1');

    // 2026-04-14: Chithirai 1 (Tamil New Year), Parabhava Year
    final chithirai1 = service.getTamilDate(DateTime(2026, 4, 14));
    expect(chithirai1.tamilMonth, 'சித்திரை');
    expect(chithirai1.tamilDay, 1);
    expect(chithirai1.tamilYear, 'பராபவ');
  });
}
