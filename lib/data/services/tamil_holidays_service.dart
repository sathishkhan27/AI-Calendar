import '../models/event_item.dart';

/// Service providing official Government of Tamil Nadu Public Holidays (தமிழ்நாடு அரசு பொது விடுமுறை நாட்கள்)
/// Includes both Gregorian and Tamil calendar festivals with bilingual titles and cultural descriptions.
class TamilHolidaysService {
  /// Returns all public holidays for a given year.
  List<EventItem> getHolidaysForYear(int year) {
    if (year == 2025) {
      return _getHolidays2025();
    } else if (year == 2026) {
      return _getHolidays2026();
    } else if (year == 2027) {
      return _getHolidays2027();
    } else {
      return _getHolidaysDynamic(year);
    }
  }

  /// Returns public holidays for a date range
  List<EventItem> getHolidaysForRange(DateTime start, DateTime end) {
    final holidays = <EventItem>[];
    for (int y = start.year; y <= end.year; y++) {
      holidays.addAll(getHolidaysForYear(y));
    }
    return holidays.where((h) => 
      !h.startTime.isBefore(start) && !h.startTime.isAfter(end)
    ).toList();
  }

  // --- Official Tamil Nadu Holidays for 2026 ---
  List<EventItem> _getHolidays2026() {
    return [
      _createHoliday(
        id: 'tn_holiday_2026_01',
        title: "New Year's Day (ஆங்கிலப் புத்தாண்டு)",
        description: 'First day of the Gregorian calendar year. Official Tamil Nadu Public Holiday.',
        year: 2026,
        month: 1,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_02',
        title: 'Pongal (தைப்பொங்கல்)',
        description: 'Tamil harvest festival dedicated to Surya Bagavan (Sun God), marking the auspicious beginning of the month of Thai.',
        year: 2026,
        month: 1,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_03',
        title: 'Thiruvalluvar Day (திருவள்ளுவர் தினம்)',
        description: 'Honoring the great Tamil sage, poet, and philosopher Thiruvalluvar, author of the Tirukkural.',
        year: 2026,
        month: 1,
        day: 16,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_04',
        title: 'Uzhavar Thirunal (உழவர் திருநாள்)',
        description: "Farmers' Day and Mattu Pongal celebrating cattle and agriculture across Tamil Nadu.",
        year: 2026,
        month: 1,
        day: 17,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_05',
        title: 'Republic Day (இந்திய குடியரசு தினம்)',
        description: 'National holiday commemorating the adoption of the Constitution of India in 1950.',
        year: 2026,
        month: 1,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_06',
        title: 'Thaipoosam (தைப்பூசம்)',
        description: 'Auspicious Hindu festival dedicated to Lord Murugan, celebrated on the full moon in the Tamil month of Thai.',
        year: 2026,
        month: 2,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_07',
        title: 'Ramzan / Eid-ul-Fitr (ரமலான் / ஈகைத் திருநாள்)',
        description: 'Islamic festival marking the end of Ramadan, the holy month of fasting.',
        year: 2026,
        month: 3,
        day: 21,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_08',
        title: 'Telugu New Year (தெலுங்கு வருடப்பிறப்பு / யுகாதி)',
        description: 'Ugadi / Telugu New Year celebrating the first day of the Chaitra month.',
        year: 2026,
        month: 3,
        day: 20,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_09',
        title: 'Good Friday (புனித வெள்ளி)',
        description: 'Christian holy day commemorating the crucifixion of Jesus Christ at Calvary.',
        year: 2026,
        month: 4,
        day: 3,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_10',
        title: 'Tamil New Year & Dr. Ambedkar Jayanthi (தமிழ்ப் புத்தாண்டு & அம்பேத்கர் பிறந்தநாள்)',
        description: 'First day of the Tamil calendar year (Chithirai 1) & birth anniversary of Dr. B. R. Ambedkar, Father of the Indian Constitution.',
        year: 2026,
        month: 4,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_11',
        title: 'May Day (மே தினம் / உழைப்பாளர் நாள்)',
        description: 'International Workers\' Day honoring the contributions of workers and laborers.',
        year: 2026,
        month: 5,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_12',
        title: 'Bakrid / Eid al-Adha (பக்ரீத் பண்டிகை)',
        description: 'Islamic feast of the sacrifice commemorating Ibrahim\'s willingness to sacrifice his son.',
        year: 2026,
        month: 5,
        day: 27,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_13',
        title: 'Muharram (மொகரம் பண்டிகை)',
        description: 'The first month of the Islamic calendar and an official public holiday in Tamil Nadu.',
        year: 2026,
        month: 6,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_14',
        title: 'Independence Day (சுதந்திர தினம்)',
        description: 'National holiday commemorating India\'s independence from British rule in 1947.',
        year: 2026,
        month: 8,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_15',
        title: 'Milad-un-Nabi (மிலாது நபி)',
        description: 'Observance of the birthday of the Islamic prophet Muhammad.',
        year: 2026,
        month: 8,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_16',
        title: 'Krishna Jayanthi (கிருஷ்ண ஜெயந்தி)',
        description: 'Hindu festival celebrating the birth of Lord Krishna, the eighth avatar of Vishnu.',
        year: 2026,
        month: 9,
        day: 4,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_17',
        title: 'Vinayakar Chathurthi (விநாயகர் சதுர்த்தி)',
        description: 'Grand festival celebrating the birth and arrival of Lord Ganesha.',
        year: 2026,
        month: 9,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_18',
        title: 'Gandhi Jayanthi (காந்தி ஜெயந்தி)',
        description: 'National holiday commemorating the birthday of Mahatma Gandhi, Father of the Nation.',
        year: 2026,
        month: 10,
        day: 2,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_19',
        title: 'Ayutha Pooja & Saraswathi Pooja (ஆயுத பூஜை & சரஸ்வதி பூஜை)',
        description: 'Worship of tools, machinery, and books dedicated to Goddess Saraswati during Navaratri.',
        year: 2026,
        month: 10,
        day: 19,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_20',
        title: 'Vijaya Dasami (விஜயதசமி)',
        description: 'Tenth day of Navaratri celebrating the victory of good over evil.',
        year: 2026,
        month: 10,
        day: 20,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_21',
        title: 'Deepavali (தீபாவளி பண்டிகை)',
        description: 'Festival of Lights celebrating the victory of light over darkness and knowledge over ignorance.',
        year: 2026,
        month: 11,
        day: 8,
      ),
      _createHoliday(
        id: 'tn_holiday_2026_22',
        title: 'Christmas (கிறிஸ்துமஸ்)',
        description: 'Christian festival commemorating the birth of Jesus Christ.',
        year: 2026,
        month: 12,
        day: 25,
      ),
    ];
  }

  // --- Official Tamil Nadu Holidays for 2025 ---
  List<EventItem> _getHolidays2025() {
    return [
      _createHoliday(
        id: 'tn_holiday_2025_01',
        title: "New Year's Day (ஆங்கிலப் புத்தாண்டு)",
        description: 'Official Tamil Nadu Public Holiday.',
        year: 2025,
        month: 1,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_02',
        title: 'Pongal (தைப்பொங்கல்)',
        description: 'Tamil harvest festival.',
        year: 2025,
        month: 1,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_03',
        title: 'Thiruvalluvar Day (திருவள்ளுவர் தினம்)',
        description: 'Honoring Thiruvalluvar, author of Tirukkural.',
        year: 2025,
        month: 1,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_04',
        title: 'Uzhavar Thirunal (உழவர் திருநாள்)',
        description: 'Tamil Farmers\' Festival and Mattu Pongal.',
        year: 2025,
        month: 1,
        day: 16,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_05',
        title: 'Republic Day (இந்திய குடியரசு தினம்)',
        description: 'National Republic Day.',
        year: 2025,
        month: 1,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_06',
        title: 'Thaipoosam (தைப்பூசம்)',
        description: 'Festival dedicated to Lord Murugan.',
        year: 2025,
        month: 2,
        day: 11,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_07',
        title: 'Telugu New Year (தெலுங்கு வருடப்பிறப்பு)',
        description: 'Ugadi festival.',
        year: 2025,
        month: 3,
        day: 30,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_08',
        title: 'Ramzan / Eid-ul-Fitr (ரமலான்)',
        description: 'End of Ramadan holy fasting.',
        year: 2025,
        month: 3,
        day: 31,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_09',
        title: 'Tamil New Year & Ambedkar Jayanthi (தமிழ்ப் புத்தாண்டு)',
        description: 'Tamil New Year (Chithirai 1) and Dr. B.R. Ambedkar Jayanthi.',
        year: 2025,
        month: 4,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_10',
        title: 'Good Friday (புனித வெள்ளி)',
        description: 'Christian Holy Friday.',
        year: 2025,
        month: 4,
        day: 18,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_11',
        title: 'May Day (மே தினம்)',
        description: 'International Workers\' Day.',
        year: 2025,
        month: 5,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_12',
        title: 'Bakrid / Eid al-Adha (பக்ரீத்)',
        description: 'Feast of the Sacrifice.',
        year: 2025,
        month: 6,
        day: 7,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_13',
        title: 'Muharram (மொகரம்)',
        description: 'First month of Islamic calendar.',
        year: 2025,
        month: 7,
        day: 6,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_14',
        title: 'Independence Day (சுதந்திர தினம்)',
        description: 'Indian Independence Day.',
        year: 2025,
        month: 8,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_15',
        title: 'Krishna Jayanthi (கிருஷ்ண ஜெயந்தி)',
        description: 'Birth of Lord Krishna.',
        year: 2025,
        month: 8,
        day: 16,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_16',
        title: 'Vinayakar Chathurthi (விநாயகர் சதுர்த்தி)',
        description: 'Ganesha Chaturthi celebration.',
        year: 2025,
        month: 8,
        day: 27,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_17',
        title: 'Milad-un-Nabi (மிலாது நபி)',
        description: 'Prophet Muhammad birthday.',
        year: 2025,
        month: 9,
        day: 5,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_18',
        title: 'Gandhi Jayanthi (காந்தி ஜெயந்தி)',
        description: 'Mahatma Gandhi Birthday.',
        year: 2025,
        month: 10,
        day: 2,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_19',
        title: 'Ayutha Pooja (ஆயுத பூஜை)',
        description: 'Worship of implements and vehicles.',
        year: 2025,
        month: 10,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_20',
        title: 'Vijaya Dasami (விஜயதசமி)',
        description: 'Tenth day victory festival.',
        year: 2025,
        month: 10,
        day: 2,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_21',
        title: 'Deepavali (தீபாவளி)',
        description: 'Festival of Lights.',
        year: 2025,
        month: 10,
        day: 20,
      ),
      _createHoliday(
        id: 'tn_holiday_2025_22',
        title: 'Christmas (கிறிஸ்துமஸ்)',
        description: 'Celebration of Christmas.',
        year: 2025,
        month: 12,
        day: 25,
      ),
    ];
  }

  // --- Official Tamil Nadu Holidays for 2027 ---
  List<EventItem> _getHolidays2027() {
    return [
      _createHoliday(
        id: 'tn_holiday_2027_01',
        title: "New Year's Day (ஆங்கிலப் புத்தாண்டு)",
        description: 'Tamil Nadu Public Holiday.',
        year: 2027,
        month: 1,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_02',
        title: 'Pongal (தைப்பொங்கல்)',
        description: 'Harvest festival of Tamil Nadu.',
        year: 2027,
        month: 1,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_03',
        title: 'Thiruvalluvar Day (திருவள்ளுவர் தினம்)',
        description: 'Tribute to sage Thiruvalluvar.',
        year: 2027,
        month: 1,
        day: 16,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_04',
        title: 'Uzhavar Thirunal (உழவர் திருநாள்)',
        description: 'Farmers and Cattle festival.',
        year: 2027,
        month: 1,
        day: 17,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_05',
        title: 'Republic Day (இந்திய குடியரசு தினம்)',
        description: 'National Republic Day.',
        year: 2027,
        month: 1,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_06',
        title: 'Thaipoosam (தைப்பூசம்)',
        description: 'Lord Murugan festival.',
        year: 2027,
        month: 1,
        day: 22,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_07',
        title: 'Good Friday (புனித வெள்ளி)',
        description: 'Good Friday observance.',
        year: 2027,
        month: 3,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_08',
        title: 'Telugu New Year (தெலுங்கு வருடப்பிறப்பு)',
        description: 'Ugadi festival.',
        year: 2027,
        month: 4,
        day: 8,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_09',
        title: 'Tamil New Year & Ambedkar Jayanthi (தமிழ்ப் புத்தாண்டு)',
        description: 'Tamil New Year and Dr. Ambedkar Jayanthi.',
        year: 2027,
        month: 4,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_10',
        title: 'May Day (மே தினம்)',
        description: 'May Day.',
        year: 2027,
        month: 5,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_11',
        title: 'Independence Day (சுதந்திர தினம்)',
        description: 'Independence Day.',
        year: 2027,
        month: 8,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_12',
        title: 'Vinayakar Chathurthi (விநாயகர் சதுர்த்தி)',
        description: 'Ganesha festival.',
        year: 2027,
        month: 9,
        day: 4,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_13',
        title: 'Gandhi Jayanthi (காந்தி ஜெயந்தி)',
        description: 'Gandhi Jayanthi.',
        year: 2027,
        month: 10,
        day: 2,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_14',
        title: 'Ayutha Pooja (ஆயுத பூஜை)',
        description: 'Ayutha Pooja.',
        year: 2027,
        month: 10,
        day: 9,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_15',
        title: 'Vijaya Dasami (விஜயதசமி)',
        description: 'Vijaya Dasami celebration.',
        year: 2027,
        month: 10,
        day: 10,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_16',
        title: 'Deepavali (தீபாவளி)',
        description: 'Deepavali Festival of Lights.',
        year: 2027,
        month: 10,
        day: 29,
      ),
      _createHoliday(
        id: 'tn_holiday_2027_17',
        title: 'Christmas (கிறிஸ்துமஸ்)',
        description: 'Christmas Day.',
        year: 2027,
        month: 12,
        day: 25,
      ),
    ];
  }

  // Fallback for any other year with solar fixed-calendar Tamil Holidays
  List<EventItem> _getHolidaysDynamic(int year) {
    return [
      _createHoliday(
        id: 'tn_holiday_${year}_01',
        title: "New Year's Day (ஆங்கிலப் புத்தாண்டு)",
        description: 'Tamil Nadu Public Holiday.',
        year: year,
        month: 1,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_02',
        title: 'Pongal (தைப்பொங்கல்)',
        description: 'Tamil harvest festival.',
        year: year,
        month: 1,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_03',
        title: 'Thiruvalluvar Day (திருவள்ளுவர் தினம்)',
        description: 'Honoring Thiruvalluvar, author of Tirukkural.',
        year: year,
        month: 1,
        day: 16,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_04',
        title: 'Uzhavar Thirunal (உழவர் திருநாள்)',
        description: 'Tamil Farmers\' Festival.',
        year: year,
        month: 1,
        day: 17,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_05',
        title: 'Republic Day (இந்திய குடியரசு தினம்)',
        description: 'National Republic Day.',
        year: year,
        month: 1,
        day: 26,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_06',
        title: 'Tamil New Year & Ambedkar Jayanthi (தமிழ்ப் புத்தாண்டு)',
        description: 'Tamil New Year (Chithirai 1) and Dr. B.R. Ambedkar Jayanthi.',
        year: year,
        month: 4,
        day: 14,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_07',
        title: 'May Day (மே தினம்)',
        description: 'International Workers\' Day.',
        year: year,
        month: 5,
        day: 1,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_08',
        title: 'Independence Day (சுதந்திர தினம்)',
        description: 'Indian Independence Day.',
        year: year,
        month: 8,
        day: 15,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_09',
        title: 'Gandhi Jayanthi (காந்தி ஜெயந்தி)',
        description: 'Mahatma Gandhi Birthday.',
        year: year,
        month: 10,
        day: 2,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_10',
        title: 'Deepavali (தீபாவளி)',
        description: 'Deepavali Festival of Lights.',
        year: year,
        month: 11,
        day: 4,
      ),
      _createHoliday(
        id: 'tn_holiday_${year}_11',
        title: 'Christmas (கிறிஸ்துமஸ்)',
        description: 'Christmas celebration.',
        year: year,
        month: 12,
        day: 25,
      ),
    ];
  }

  EventItem _createHoliday({
    required String id,
    required String title,
    required String description,
    required int year,
    required int month,
    required int day,
  }) {
    final start = DateTime(year, month, day, 0, 0, 0);
    final end = DateTime(year, month, day, 23, 59, 59);

    return EventItem(
      id: id,
      title: title,
      description: description,
      startTime: start,
      endTime: end,
      source: EventSource.tamilHoliday,
      isAllDay: true,
      isHoliday: true,
      colorTheme: EventPastelColor.holidayGold,
      priority: EventPriority.medium,
      location: 'Tamil Nadu, India',
    );
  }
}
