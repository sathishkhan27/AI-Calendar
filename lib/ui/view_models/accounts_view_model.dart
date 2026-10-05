import 'package:flutter/material.dart';
import '../../data/models/connected_account.dart';
import '../../data/repositories/calendar_repository.dart';

class AccountsViewModel extends ChangeNotifier {
  final CalendarRepository _repository;
  bool _isSaving = false;

  AccountsViewModel({required CalendarRepository repository})
      : _repository = repository;

  List<ConnectedAccount> get accounts => _repository.accounts;
  bool get isSaving => _isSaving;

  Future<void> toggleAccountSync(String accountId, bool enabled) async {
    await _repository.toggleAccountSync(accountId, enabled);
    notifyListeners();
  }

  Future<void> removeAccount(String accountId) async {
    await _repository.removeAccount(accountId);
    notifyListeners();
  }

  Future<void> connectNewAccount({
    required String email,
    required String displayName,
    required AccountProvider provider,
    String? accessToken,
  }) async {
    _isSaving = true;
    notifyListeners();

    final newAcc = ConnectedAccount(
      id: 'acc_${provider.name}_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      provider: provider,
      accessToken: accessToken,
      isConnected: true,
      lastSyncedAt: DateTime.now(),
    );

    await _repository.addAccount(newAcc);
    _isSaving = false;
    notifyListeners();
  }

  Future<void> syncAll() async {
    _isSaving = true;
    notifyListeners();
    await _repository.syncAllAccounts();
    _isSaving = false;
    notifyListeners();
  }

  Future<String?> getGeminiApiKey() => _repository.storage.getGeminiApiKey();
  Future<void> setGeminiApiKey(String key) => _repository.storage.setGeminiApiKey(key);
}
