import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../view_models/accounts_view_model.dart';
import '../view_models/ai_briefing_view_model.dart';
import '../view_models/calendar_view_model.dart';
import 'accounts_view.dart';
import 'ai_briefing_view.dart';
import 'calendar_view.dart';
import 'calls_view.dart';
import 'tamil_calendar_view.dart';
import 'widgets/sidebar_navigation.dart';

class AdaptiveShell extends StatefulWidget {
  final CalendarViewModel calendarViewModel;
  final AiBriefingViewModel aiBriefingViewModel;
  final AccountsViewModel accountsViewModel;

  const AdaptiveShell({
    super.key,
    required this.calendarViewModel,
    required this.aiBriefingViewModel,
    required this.accountsViewModel,
  });

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  Widget _buildCurrentPage(int activeIndex) {
    switch (activeIndex) {
      case 0:
        return CalendarView(
          calendarViewModel: widget.calendarViewModel,
          aiBriefingViewModel: widget.aiBriefingViewModel,
        );
      case 1:
        return CallsView(
          calendarViewModel: widget.calendarViewModel,
        );
      case 2:
        return AiBriefingView(
          aiBriefingViewModel: widget.aiBriefingViewModel,
          calendarViewModel: widget.calendarViewModel,
        );
      case 3:
        return AccountsView(
          accountsViewModel: widget.accountsViewModel,
          calendarViewModel: widget.calendarViewModel,
        );
      case 4:
        return TamilCalendarView(
          calendarViewModel: widget.calendarViewModel,
        );
      default:
        return CalendarView(
          calendarViewModel: widget.calendarViewModel,
          aiBriefingViewModel: widget.aiBriefingViewModel,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.calendarViewModel,
      builder: (context, _) {
        final activeIndex = widget.calendarViewModel.activeNavIndex;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= ResponsiveUtils.mobileBreakpoint;

            if (isDesktop) {
              // Desktop / Tablet layout: Sidebar + Content
              return Scaffold(
                backgroundColor: AppColors.bg,
                body: Row(
                  children: [
                    SidebarNavigation(
                      calendarViewModel: widget.calendarViewModel,
                    ),
                    Expanded(child: _buildCurrentPage(activeIndex)),
                  ],
                ),
              );
            } else {
              // Mobile Layout: Scaffold with Bottom Navigation
              return Scaffold(
                backgroundColor: AppColors.bg,
                body: _buildCurrentPage(activeIndex),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: activeIndex,
                  onDestinationSelected: (index) => widget.calendarViewModel.setActiveNavIndex(index),
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primarySoft,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.video_call_outlined),
                      selectedIcon: Icon(Icons.video_call_rounded, color: AppColors.googleBlue),
                      label: 'Calls',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.aiSparkle),
                      label: 'AI Briefing',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.sync_alt_outlined),
                      selectedIcon: Icon(Icons.sync_alt_rounded, color: AppColors.primary),
                      label: 'Accounts',
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}

