import '../models/connected_account.dart';
import '../models/daily_briefing.dart';
import '../models/event_item.dart';
import '../models/tamil_daily_timings.dart';
import '../services/gemini_ai_service.dart';
import '../services/google_calendar_service.dart';
import '../services/microsoft_outlook_service.dart';
import '../services/storage_service.dart';
import '../services/tamil_holidays_service.dart';
import '../services/tamil_panchangam_service.dart';

class CalendarRepository {
  final StorageService _storageService;
  final GoogleCalendarService _googleService;
  final MicrosoftOutlookService _outlookService;
  final GeminiAiService _aiService;
  final TamilHolidaysService _tamilHolidaysService;
  final TamilPanchangamService _panchangamService;

  List<ConnectedAccount> _accounts = [];
  List<EventItem> _allEvents = [];
  bool _isSyncing = false;
  bool _showTamilHolidays = true;
  bool _showTamilTimings = true;

  CalendarRepository({
    StorageService? storageService,
    GoogleCalendarService? googleService,
    MicrosoftOutlookService? outlookService,
    GeminiAiService? aiService,
    TamilHolidaysService? tamilHolidaysService,
    TamilPanchangamService? panchangamService,
  })  : _storageService = storageService ?? StorageService(),
        _googleService = googleService ?? GoogleCalendarService(),
        _outlookService = outlookService ?? MicrosoftOutlookService(),
        _aiService = aiService ?? GeminiAiService(),
        _tamilHolidaysService = tamilHolidaysService ?? TamilHolidaysService(),
        _panchangamService = panchangamService ?? const TamilPanchangamService();

  List<ConnectedAccount> get accounts => List.unmodifiable(_accounts);
  List<EventItem> get allEvents => List.unmodifiable(_allEvents);
  bool get isSyncing => _isSyncing;
  bool get showTamilHolidays => _showTamilHolidays;
  bool get showTamilTimings => _showTamilTimings;

  TamilDailyTimings getTamilDailyTimings(DateTime date) => _panchangamService.getDailyTimings(date);
  TamilDate getTamilDate(DateTime date) => _panchangamService.getTamilDate(date);

  Map<String, List<int>> getChandrashtamamDatesForMonth(int year, int month) =>
      _panchangamService.getChandrashtamamDatesForMonth(year, month);

  List<int> getMuhurthamDatesForMonth(int year, int month) =>
      _panchangamService.getMuhurthamDatesForMonth(year, month);

  Future<void> toggleTamilTimings(bool enabled) async {
    _showTamilTimings = enabled;
    await _storageService.setTamilTimingsEnabled(enabled);
  }

  Future<void> initialize() async {
    final loaded = await _storageService.loadAccounts();
    // Strip out any previously seeded hardcoded demo accounts
    _accounts = loaded
        .where((a) =>
            !a.id.startsWith('acc_google_primary') &&
            !a.id.startsWith('acc_outlook_primary'))
        .toList();
    if (_accounts.length != loaded.length) {
      await _storageService.saveAccounts(_accounts);
    }

    _showTamilHolidays = await _storageService.getTamilHolidaysEnabled();
    _showTamilTimings = await _storageService.getTamilTimingsEnabled();

    await syncAllAccounts();
  }

  Future<void> syncAllAccounts() async {
    _isSyncing = true;
    final now = DateTime.now();
    final timeMin = now.subtract(const Duration(days: 7));
    final timeMax = now.add(const Duration(days: 30));

    final aggregated = <EventItem>[];

    // Load custom/local events
    final localEvents = await _storageService.loadCustomEvents();
    aggregated.addAll(localEvents);

    // Fetch from connected accounts
    final updatedAccounts = <ConnectedAccount>[];

    for (final acc in _accounts) {
      if (!acc.isConnected || !acc.syncEnabled) {
        updatedAccounts.add(acc);
        continue;
      }

      List<EventItem> fetched = [];
      if (acc.provider == AccountProvider.google) {
        fetched = await _googleService.fetchEvents(
          account: acc,
          timeMin: timeMin,
          timeMax: timeMax,
        );
      } else if (acc.provider == AccountProvider.microsoft) {
        fetched = await _outlookService.fetchEvents(
          account: acc,
          timeMin: timeMin,
          timeMax: timeMax,
        );
      }

      aggregated.addAll(fetched);
      updatedAccounts.add(
        acc.copyWith(
          lastSyncedAt: DateTime.now(),
          syncedEventsCount: fetched.length,
        ),
      );
    }

    _accounts = updatedAccounts;
    await _storageService.saveAccounts(_accounts);

    // Ingest Tamil Nadu Public Holidays if enabled
    if (_showTamilHolidays) {
      final holidays = [
        ..._tamilHolidaysService.getHolidaysForYear(now.year - 1),
        ..._tamilHolidaysService.getHolidaysForYear(now.year),
        ..._tamilHolidaysService.getHolidaysForYear(now.year + 1),
      ];
      aggregated.addAll(holidays);
    }

    // Sort chronologically
    aggregated.sort((a, b) => a.startTime.compareTo(b.startTime));
    _allEvents = aggregated;
    _isSyncing = false;
  }

  Future<void> toggleTamilHolidays(bool enabled) async {
    _showTamilHolidays = enabled;
    await _storageService.setTamilHolidaysEnabled(enabled);
    await syncAllAccounts();
  }

  Future<void> addAccount(ConnectedAccount account) async {
    _accounts.add(account);
    await _storageService.saveAccounts(_accounts);
    await syncAllAccounts();
  }

  Future<void> removeAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    await _storageService.saveAccounts(_accounts);
    await syncAllAccounts();
  }

  Future<void> toggleAccountSync(String accountId, bool enabled) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(syncEnabled: enabled);
      await _storageService.saveAccounts(_accounts);
      await syncAllAccounts();
    }
  }

  Future<void> addEvent(EventItem event) async {
    final customEvents = await _storageService.loadCustomEvents();
    customEvents.add(event);
    await _storageService.saveCustomEvents(customEvents);
    await syncAllAccounts();
  }

  Future<void> updateEvent(EventItem event) async {
    final customEvents = await _storageService.loadCustomEvents();
    final index = customEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      customEvents[index] = event;
      await _storageService.saveCustomEvents(customEvents);
    }
    final allIdx = _allEvents.indexWhere((e) => e.id == event.id);
    if (allIdx != -1) {
      _allEvents[allIdx] = event;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final customEvents = await _storageService.loadCustomEvents();
    customEvents.removeWhere((e) => e.id == eventId);
    await _storageService.saveCustomEvents(customEvents);
    _allEvents.removeWhere((e) => e.id == eventId);
  }

  List<EventItem> getEventsForDay(DateTime date) {
    return _allEvents.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  List<EventItem> getScheduledCalls({DateTime? fromDate}) {
    final start = fromDate ?? DateTime.now().subtract(const Duration(hours: 2));
    return _allEvents.where((e) {
      return e.isCall && e.endTime.isAfter(start);
    }).toList();
  }

  List<EventItem> getConflictsForDay(DateTime date) {
    final dayEvents = getEventsForDay(date);
    final conflictEvents = <EventItem>{};

    for (int i = 0; i < dayEvents.length; i++) {
      for (int j = i + 1; j < dayEvents.length; j++) {
        if (dayEvents[i].conflictsWith(dayEvents[j])) {
          conflictEvents.add(dayEvents[i]);
          conflictEvents.add(dayEvents[j]);
        }
      }
    }

    return conflictEvents.toList();
  }

  Future<DailyBriefing> getDailyBriefing(DateTime date) async {
    final dayEvents = getEventsForDay(date);
    final apiKey = await _storageService.getGeminiApiKey();
    return _aiService.generateDailyBriefing(
      date: date,
      dayEvents: dayEvents,
      apiKey: apiKey,
    );
  }

  EventItem parseNaturalLanguage(String input, DateTime targetDate) {
    return _aiService.parseNaturalLanguageEvent(input, targetDate);
  }

  StorageService get storage => _storageService;
}
