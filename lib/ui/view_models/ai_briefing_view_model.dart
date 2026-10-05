import 'package:flutter/material.dart';
import '../../data/models/daily_briefing.dart';
import '../../data/models/event_item.dart';
import '../../data/repositories/calendar_repository.dart';

class AiBriefingViewModel extends ChangeNotifier {
  final CalendarRepository _repository;

  DailyBriefing? _briefing;
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _completedActions = {};

  AiBriefingViewModel({required CalendarRepository repository})
      : _repository = repository;

  DailyBriefing? get briefing => _briefing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get completedActions => _completedActions;

  Future<void> loadBriefingForDate(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _briefing = await _repository.getDailyBriefing(date);
    } catch (e) {
      _errorMessage = 'Failed to generate briefing: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleActionItem(String action) {
    if (_completedActions.contains(action)) {
      _completedActions.remove(action);
    } else {
      _completedActions.add(action);
    }
    notifyListeners();
  }

  EventItem parseNaturalLanguage(String text, DateTime targetDate) {
    return _repository.parseNaturalLanguage(text, targetDate);
  }

  Future<void> scheduleFromNaturalLanguage(String text, DateTime targetDate) async {
    final event = _repository.parseNaturalLanguage(text, targetDate);
    await _repository.addEvent(event);
    await loadBriefingForDate(targetDate);
  }
}
