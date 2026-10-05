import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/connected_account.dart';
import '../../data/models/event_item.dart';
import '../../data/models/tamil_daily_timings.dart';
import '../../data/repositories/calendar_repository.dart';

enum CalendarViewMode {
  week,
  day,
  month;

  String get label {
    switch (this) {
      case CalendarViewMode.week:
        return 'WEEK';
      case CalendarViewMode.day:
        return 'DAY';
      case CalendarViewMode.month:
        return 'MONTH';
    }
  }
}

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository;

  DateTime _selectedDate = DateTime.now(); // Defaults dynamically to TODAY
  CalendarViewMode _viewMode = CalendarViewMode.week;
  EventSource? _sourceFilter;
  bool _onlyCallsFilter = false;
  String _searchQuery = '';
  bool _isLoading = false;
  String _selectedSection = 'my_calendar';
  String? _selectedList;
  String? _selectedTag;
  bool _isAllDayExpanded = true;
  bool _isAiDrawerOpen = false;
  int _activeNavIndex = 0; // 0 = Calendar, 1 = Calls, 2 = AI Briefing, 3 = Accounts

  // User-created dynamic lists & tags
  final List<String> _customViews = [];
  final List<Map<String, dynamic>> _customLists = [
    {'name': 'Personal'},
    {'name': 'Home'},
    {'name': 'Books'},
  ];
  final List<Map<String, dynamic>> _customTags = [
    {'name': 'Priority', 'color': const Color(0xFFF59E0B)},
    {'name': 'Important', 'color': const Color(0xFFEF4444)},
  ];

  CalendarViewModel({required CalendarRepository repository})
      : _repository = repository;

  DateTime get selectedDate => _selectedDate;
  CalendarViewMode get viewMode => _viewMode;
  EventSource? get sourceFilter => _sourceFilter;
  bool get onlyCallsFilter => _onlyCallsFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading || _repository.isSyncing;
  String get selectedSection => _selectedSection;
  String? get selectedList => _selectedList;
  String? get selectedTag => _selectedTag;
  bool get isAllDayExpanded => _isAllDayExpanded;
  bool get isAiDrawerOpen => _isAiDrawerOpen;
  int get activeNavIndex => _activeNavIndex;

  List<String> get customViews => List.unmodifiable(_customViews);
  List<Map<String, dynamic>> get customLists => List.unmodifiable(_customLists);
  List<Map<String, dynamic>> get customTags => List.unmodifiable(_customTags);

  List<ConnectedAccount> get accounts => _repository.accounts;
  int get connectedAccountsCount => _repository.accounts.where((a) => a.isConnected).length;

  bool get showTamilHolidays => _repository.showTamilHolidays;
  bool get showTamilTimings => _repository.showTamilTimings;

  TamilDailyTimings get selectedDateTamilTimings => _repository.getTamilDailyTimings(_selectedDate);
  TamilDailyTimings getTamilTimingsFor(DateTime date) => _repository.getTamilDailyTimings(date);

  TamilDate get selectedTamilDate => _repository.getTamilDate(_selectedDate);
  TamilDate getTamilDateFor(DateTime date) => _repository.getTamilDate(date);

  Map<String, List<int>> getChandrashtamamDatesForMonth(int year, int month) =>
      _repository.getChandrashtamamDatesForMonth(year, month);

  List<int> getMuhurthamDatesForMonth(int year, int month) =>
      _repository.getMuhurthamDatesForMonth(year, month);

  Future<void> toggleTamilTimings(bool enabled) async {
    _isLoading = true;
    notifyListeners();
    await _repository.toggleTamilTimings(enabled);
    _isLoading = false;
    notifyListeners();
  }

  List<EventItem> get upcomingTamilHolidays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _repository.allEvents
        .where((e) => e.source == EventSource.tamilHoliday && !e.startTime.isBefore(today))
        .toList();
  }

  Future<void> toggleTamilHolidays(bool enabled) async {
    _isLoading = true;
    notifyListeners();
    await _repository.toggleTamilHolidays(enabled);
    _isLoading = false;
    notifyListeners();
  }

  // Dynamic Badge Counts
  int get myDayCount {
    final now = DateTime.now();
    return _repository.allEvents.where((e) =>
      e.startTime.year == now.year && e.startTime.month == now.month && e.startTime.day == now.day
    ).length;
  }

  int get next7DaysCount {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    return _repository.allEvents.where((e) =>
      (e.startTime.isAfter(start) || e.startTime.isAtSameMomentAs(start)) && e.startTime.isBefore(end)
    ).length;
  }

  int get allTasksCount => allTasks.where((t) => !t.isCompleted).length;

  int getListCount(String listName) {
    final l = listName.toLowerCase();
    return _repository.allEvents.where((e) =>
      e.title.toLowerCase().contains(l) || e.description.toLowerCase().contains(l)
    ).length;
  }

  // Dynamic Date Range header text
  String get dateRangeLabel {
    switch (_viewMode) {
      case CalendarViewMode.day:
        return DateFormat('EEE, MMM d, y').format(_selectedDate);
      case CalendarViewMode.week:
        final mon = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final sun = mon.add(const Duration(days: 6));
        if (mon.month == sun.month) {
          return '${DateFormat('MMM d').format(mon)} - ${DateFormat('d, y').format(sun)}';
        }
        return '${DateFormat('MMM d').format(mon)} - ${DateFormat('MMM d, y').format(sun)}';
      case CalendarViewMode.month:
        return DateFormat('MMMM y').format(_selectedDate);
    }
  }

  /// Dynamic Tamil Solar Date header text for simultaneous dual-calendar display
  String get tamilDateRangeLabel {
    switch (_viewMode) {
      case CalendarViewMode.day:
        final t = selectedTamilDate;
        return '${t.tamilMonth} ${t.tamilDay}, ${t.tamilYear} ஆண்டு';
      case CalendarViewMode.week:
        final mon = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final sun = mon.add(const Duration(days: 6));
        final tMon = _repository.getTamilDate(mon);
        final tSun = _repository.getTamilDate(sun);
        if (tMon.tamilMonth == tSun.tamilMonth) {
          return '${tMon.tamilMonth} ${tMon.tamilDay} - ${tSun.tamilDay}, ${tMon.tamilYear} ஆண்டு';
        }
        return '${tMon.tamilMonth} ${tMon.tamilDay} - ${tSun.tamilMonth} ${tSun.tamilDay}, ${tMon.tamilYear} ஆண்டு';
      case CalendarViewMode.month:
        final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        final tStart = _repository.getTamilDate(startOfMonth);
        final tEnd = _repository.getTamilDate(endOfMonth);
        if (tStart.tamilMonth == tEnd.tamilMonth) {
          return '${tStart.tamilMonth}, ${tStart.tamilYear} ஆண்டு';
        }
        return '${tStart.tamilMonth} - ${tEnd.tamilMonth}, ${tStart.tamilYear} ஆண்டு';
    }
  }

  // The 7 days of the current week (Mon -> Sun)
  List<DateTime> get currentWeekDates {
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  List<EventItem> get allEvents => _repository.allEvents;

  // Filtered events matching selected lists, tags, searches, sources
  List<EventItem> _applyActiveFilters(List<EventItem> list) {
    var result = list;

    if (_sourceFilter != null) {
      result = result.where((e) => e.source == _sourceFilter).toList();
    }

    if (_onlyCallsFilter) {
      result = result.where((e) => e.isCall).toList();
    }

    if (_selectedList != null && _selectedList!.isNotEmpty) {
      final l = _selectedList!.toLowerCase();
      result = result.where((e) {
        return e.title.toLowerCase().contains(l) ||
            e.description.toLowerCase().contains(l);
      }).toList();
    }

    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      if (_selectedTag == 'Priority') {
        result = result.where((e) => e.priority == EventPriority.high || e.title.toLowerCase().contains('priority')).toList();
      } else if (_selectedTag == 'Important') {
        result = result.where((e) => e.priority == EventPriority.high || e.title.toLowerCase().contains('important')).toList();
      } else {
        final t = _selectedTag!.toLowerCase();
        result = result.where((e) => e.title.toLowerCase().contains(t) || e.description.toLowerCase().contains(t)).toList();
      }
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            (e.meetingUrl?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  List<EventItem> get eventsForSelectedDay {
    final list = _repository.getEventsForDay(_selectedDate);
    return _applyActiveFilters(list);
  }

  List<EventItem> getEventsForDay(DateTime date) {
    final list = _repository.allEvents.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
    return _applyActiveFilters(list);
  }

  List<EventItem> getAllDayEventsForDay(DateTime date) {
    return getEventsForDay(date).where((e) => e.isAllDay).toList();
  }

  List<EventItem> getTimeGridEventsForDay(DateTime date) {
    return getEventsForDay(date).where((e) => !e.isAllDay).toList();
  }

  List<EventItem> get allTasks {
    final tasks = _repository.allEvents.where((e) => e.isTask || e.isAllDay).toList();
    return _applyActiveFilters(tasks);
  }

  List<EventItem> get allScheduledCalls {
    var calls = _repository.getScheduledCalls();
    if (_sourceFilter != null) {
      calls = calls.where((e) => e.source == _sourceFilter).toList();
    }
    return calls;
  }

  List<EventItem> get conflictsForSelectedDay {
    return _repository.getConflictsForDay(_selectedDate);
  }

  void setActiveNavIndex(int index) {
    _activeNavIndex = index;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void setViewMode(CalendarViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSourceFilter(EventSource? source) {
    _sourceFilter = source;
    notifyListeners();
  }

  void toggleCallsOnly() {
    _onlyCallsFilter = !_onlyCallsFilter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedSection(String section) {
    _selectedSection = section;
    _selectedList = null;
    _selectedTag = null;
    _activeNavIndex = 0; // return to calendar/tasks view

    if (section == 'my_day') {
      _viewMode = CalendarViewMode.day;
      _selectedDate = DateTime.now();
    } else if (section == 'next_7_days' || section == 'my_calendar') {
      _viewMode = CalendarViewMode.week;
    }
    notifyListeners();
  }

  void setSelectedList(String list) {
    _selectedList = list;
    _selectedSection = '';
    _selectedTag = null;
    _activeNavIndex = 0;
    notifyListeners();
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag;
    _selectedSection = '';
    _selectedList = null;
    _activeNavIndex = 0;
    notifyListeners();
  }

  void toggleAllDayExpanded() {
    _isAllDayExpanded = !_isAllDayExpanded;
    notifyListeners();
  }

  void toggleAiDrawer() {
    _isAiDrawerOpen = !_isAiDrawerOpen;
    notifyListeners();
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  void next() {
    switch (_viewMode) {
      case CalendarViewMode.day:
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        break;
      case CalendarViewMode.week:
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        break;
      case CalendarViewMode.month:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
        break;
    }
    notifyListeners();
  }

  void previous() {
    switch (_viewMode) {
      case CalendarViewMode.day:
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case CalendarViewMode.week:
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case CalendarViewMode.month:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
        break;
    }
    notifyListeners();
  }

  void nextWeek() => next();
  void previousWeek() => previous();

  void addCustomView(String name) {
    if (name.trim().isNotEmpty && !_customViews.contains(name.trim())) {
      _customViews.add(name.trim());
      setSelectedSection('custom_${name.trim()}');
    }
  }

  void addCustomList(String name) {
    if (name.trim().isNotEmpty) {
      _customLists.add({'name': name.trim(), 'count': 0});
      setSelectedList(name.trim());
    }
  }

  void addCustomTag(String name, Color color) {
    if (name.trim().isNotEmpty) {
      _customTags.add({'name': name.trim(), 'color': color});
      setSelectedTag(name.trim());
    }
  }

  Future<void> toggleTaskCompletion(String eventId) async {
    final event = _repository.allEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw Exception('Event not found'),
    );
    final updated = event.copyWith(isCompleted: !event.isCompleted);
    await _repository.updateEvent(updated);
    notifyListeners();
  }

  void clearFilters() {
    _sourceFilter = null;
    _onlyCallsFilter = false;
    _searchQuery = '';
    _selectedList = null;
    _selectedTag = null;
    _selectedSection = 'my_calendar';
    _viewMode = CalendarViewMode.week;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _repository.syncAllAccounts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(EventItem event) async {
    await _repository.addEvent(event);
    notifyListeners();
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.deleteEvent(eventId);
    notifyListeners();
  }

  CalendarRepository get repository => _repository;
}

