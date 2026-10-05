import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/connected_account.dart';
import '../models/event_item.dart';

class StorageService {
  static const String _accountsKey = 'connected_accounts_v1';
  static const String _eventsKey = 'custom_events_v1';
  static const String _geminiApiKey = 'gemini_api_key';
  static const String _googleClientIdKey = 'google_client_id';
  static const String _outlookClientIdKey = 'outlook_client_id';

  Future<List<ConnectedAccount>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_accountsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ConnectedAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAccounts(List<ConnectedAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await prefs.setString(_accountsKey, raw);
  }

  Future<List<EventItem>> loadCustomEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => EventItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomEvents(List<EventItem> events) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_eventsKey, raw);
  }

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKey);
  }

  Future<void> setGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKey, key);
  }

  Future<String?> getGoogleClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleClientIdKey);
  }

  Future<void> setGoogleClientId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_googleClientIdKey, id);
  }

  Future<String?> getOutlookClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_outlookClientIdKey);
  }

  Future<void> setOutlookClientId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outlookClientIdKey, id);
  }

  static const String _tamilHolidaysEnabledKey = 'tamil_holidays_enabled';
  static const String _tamilTimingsEnabledKey = 'tamil_timings_enabled';

  Future<bool> getTamilHolidaysEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tamilHolidaysEnabledKey) ?? true;
  }

  Future<void> setTamilHolidaysEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tamilHolidaysEnabledKey, enabled);
  }

  Future<bool> getTamilTimingsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tamilTimingsEnabledKey) ?? true;
  }

  Future<void> setTamilTimingsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tamilTimingsEnabledKey, enabled);
  }
}
