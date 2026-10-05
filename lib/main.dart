import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/calendar_repository.dart';
import 'ui/view_models/accounts_view_model.dart';
import 'ui/view_models/ai_briefing_view_model.dart';
import 'ui/view_models/calendar_view_model.dart';
import 'ui/views/adaptive_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = CalendarRepository();
  await repository.initialize();

  final calendarViewModel = CalendarViewModel(repository: repository);
  final aiBriefingViewModel = AiBriefingViewModel(repository: repository);
  final accountsViewModel = AccountsViewModel(repository: repository);

  runApp(
    AiCalendarApp(
      calendarViewModel: calendarViewModel,
      aiBriefingViewModel: aiBriefingViewModel,
      accountsViewModel: accountsViewModel,
    ),
  );
}

class AiCalendarApp extends StatelessWidget {
  final CalendarViewModel calendarViewModel;
  final AiBriefingViewModel aiBriefingViewModel;
  final AccountsViewModel accountsViewModel;

  const AiCalendarApp({
    super.key,
    required this.calendarViewModel,
    required this.aiBriefingViewModel,
    required this.accountsViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Calendar - Events & Scheduled Calls',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AdaptiveShell(
        calendarViewModel: calendarViewModel,
        aiBriefingViewModel: aiBriefingViewModel,
        accountsViewModel: accountsViewModel,
      ),
    );
  }
}
