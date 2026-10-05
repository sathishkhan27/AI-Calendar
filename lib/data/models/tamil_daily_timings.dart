import 'package:flutter/material.dart';

class TamilDate {
  final DateTime gregorianDate;
  final int tamilDay;
  final String tamilMonth; // e.g. 'புரட்டாசி'
  final String tamilMonthEnglish; // e.g. 'Purattasi'
  final String tamilYear; // e.g. 'பராபவ'
  final int totalDaysInMonth;

  // Authentic Panchangam Details matching traditional Daily Sheet (தின நாட்காட்டி)
  final String nakshatram; // e.g. 'உத்திரட்டாதி'
  final String nakshatramTime; // e.g. '12:11 AM'
  final String tithi; // e.g. 'திரயோதசி கிருஷ்ண'
  final String tithiTime; // e.g. '12:11 AM'
  final String karanam; // e.g. 'கரசை'
  final String yogam; // e.g. 'ஐந்திரம்'
  final String chandrashtamam; // e.g. 'சிம்மம்'
  final String soolam; // e.g. 'கிழக்கு'
  final String pariharam; // e.g. 'தயிர்'

  // Special Vratams & Festivals (விரதங்கள் & பண்டிகைகள்)
  final bool isAmavasya;
  final bool isPournami;
  final bool isSashti;
  final bool isEkadashi;
  final bool isPradosham;
  final bool isKarthigai;
  final String? festival; // e.g. 'தமிழ்ப் புத்தாண்டு', 'தைப்பொங்கல்', 'தீபாவளி'

  const TamilDate({
    required this.gregorianDate,
    required this.tamilDay,
    required this.tamilMonth,
    required this.tamilMonthEnglish,
    required this.tamilYear,
    required this.totalDaysInMonth,
    this.nakshatram = 'உத்திரட்டாதி',
    this.nakshatramTime = '12:11 AM',
    this.tithi = 'திரயோதசி கிருஷ்ண',
    this.tithiTime = '12:11 AM',
    this.karanam = 'கரசை',
    this.yogam = 'ஐந்திரம்',
    this.chandrashtamam = 'சிம்மம்',
    this.soolam = 'கிழக்கு',
    this.pariharam = 'தயிர்',
    this.isAmavasya = false,
    this.isPournami = false,
    this.isSashti = false,
    this.isEkadashi = false,
    this.isPradosham = false,
    this.isKarthigai = false,
    this.festival,
  });

  String get shortTamilDate => '$tamilMonth $tamilDay';
  String get shortTamilDateWithEnglish => '$tamilMonth ($tamilMonthEnglish) $tamilDay';
  String get fullTamilDate => '$tamilMonth $tamilDay, $tamilYear ஆண்டு';
  String get dayOnlyString => '$tamilDay';

  bool get hasSpecialEvent =>
      isAmavasya || isPournami || isSashti || isEkadashi || isPradosham || isKarthigai || festival != null;
}

class TamilTimeSlot {
  final String label;
  final String tamilLabel;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isGood; // true for Nalla Neram / Gowri, false for Rahu / Yamagandam
  final Color badgeColor;
  final Color textColor;

  const TamilTimeSlot({
    required this.label,
    required this.tamilLabel,
    required this.startTime,
    required this.endTime,
    required this.isGood,
    required this.badgeColor,
    required this.textColor,
  });

  String get timeFormatted {
    final startHour = startTime.hourOfPeriod == 0 ? 12 : startTime.hourOfPeriod;
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final startPeriod = startTime.period == DayPeriod.am ? 'AM' : 'PM';

    final endHour = endTime.hourOfPeriod == 0 ? 12 : endTime.hourOfPeriod;
    final endMin = endTime.minute.toString().padLeft(2, '0');
    final endPeriod = endTime.period == DayPeriod.am ? 'AM' : 'PM';

    return '$startHour:$startMin $startPeriod - $endHour:$endMin $endPeriod';
  }

  DateTime toStartDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  }

  DateTime toEndDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
  }

  bool contains(DateTime dateTime) {
    final start = toStartDateTime(dateTime);
    final end = toEndDateTime(dateTime);
    return (dateTime.isAfter(start) || dateTime.isAtSameMomentAs(start)) &&
        dateTime.isBefore(end);
  }

  bool overlapsWith(DateTime start, DateTime end) {
    final slotStart = toStartDateTime(start);
    final slotEnd = toEndDateTime(start);
    return start.isBefore(slotEnd) && end.isAfter(slotStart);
  }
}

class TamilDailyTimings {
  final DateTime date;
  final String tamilDayName; // e.g. 'திங்கட்கிழமை'
  final String englishDayName; // e.g. 'Monday'
  final String tamilMonthSeason; // e.g. 'புரட்டாசி'
  final TamilDate? tamilDate;

  // Good Timings (நல்ல நேரம்)
  final TamilTimeSlot nallaNeramMorning;
  final TamilTimeSlot nallaNeramEvening;
  final TamilTimeSlot gowriNallaNeramMorning;
  final TamilTimeSlot gowriNallaNeramEvening;

  // Bad Timings (கெட்ட நேரம் / அசுப நேரம்)
  final TamilTimeSlot rahuKalam;
  final TamilTimeSlot yamagandam;
  final TamilTimeSlot kuligai;

  const TamilDailyTimings({
    required this.date,
    required this.tamilDayName,
    required this.englishDayName,
    required this.tamilMonthSeason,
    this.tamilDate,
    required this.nallaNeramMorning,
    required this.nallaNeramEvening,
    required this.gowriNallaNeramMorning,
    required this.gowriNallaNeramEvening,
    required this.rahuKalam,
    required this.yamagandam,
    required this.kuligai,
  });

  List<TamilTimeSlot> get goodTimings => [
        nallaNeramMorning,
        nallaNeramEvening,
        gowriNallaNeramMorning,
        gowriNallaNeramEvening,
      ];

  List<TamilTimeSlot> get badTimings => [
        rahuKalam,
        yamagandam,
      ];

  List<TamilTimeSlot> get allKeySlots => [
        nallaNeramMorning,
        nallaNeramEvening,
        rahuKalam,
        yamagandam,
        kuligai,
        gowriNallaNeramMorning,
      ];

  /// Check if a given event time conflicts with Bad Timing (Rahu Kalam or Yamagandam)
  TamilTimeSlot? getConflictingBadTiming(DateTime start, DateTime end) {
    if (rahuKalam.overlapsWith(start, end)) return rahuKalam;
    if (yamagandam.overlapsWith(start, end)) return yamagandam;
    return null;
  }

  /// Check if a given event time coincides with Good Timing (Nalla Neram)
  TamilTimeSlot? getMatchingGoodTiming(DateTime start, DateTime end) {
    for (final slot in goodTimings) {
      if (slot.overlapsWith(start, end)) return slot;
    }
    return null;
  }
}
