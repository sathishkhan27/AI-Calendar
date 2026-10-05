import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/event_item.dart';
import '../../view_models/calendar_view_model.dart';
import 'add_event_dialog.dart';

class SidebarNavigation extends StatelessWidget {
  final CalendarViewModel calendarViewModel;

  const SidebarNavigation({
    super.key,
    required this.calendarViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final accounts = calendarViewModel.repository.accounts;
    final primaryAccount = accounts.isNotEmpty
        ? accounts.firstWhere((a) => a.isConnected, orElse: () => accounts.first)
        : null;
    final userName = primaryAccount?.displayName.split(' ').first ?? 'Personal';
    final userSubtitle = primaryAccount != null ? 'Connected • ${primaryAccount.provider.displayName}' : 'Workspace';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic User Profile Header
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 16, top: 22, bottom: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        userSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.textSecondary),
                  tooltip: 'Add new event',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AddEventDialog(
                        viewModel: calendarViewModel,
                        initialDate: calendarViewModel.selectedDate,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildNavItem(
                  icon: Icons.track_changes_rounded,
                  label: 'My day',
                  badgeText: '${calendarViewModel.myDayCount}',
                  isSelected: calendarViewModel.activeNavIndex == 0 && calendarViewModel.selectedSection == 'my_day',
                  onTap: () => calendarViewModel.setSelectedSection('my_day'),
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Next 7 days',
                  badgeText: '${calendarViewModel.next7DaysCount}',
                  isSelected: calendarViewModel.activeNavIndex == 0 && calendarViewModel.selectedSection == 'next_7_days',
                  onTap: () => calendarViewModel.setSelectedSection('next_7_days'),
                ),
                _buildNavItem(
                  icon: Icons.checklist_rounded,
                  label: 'All my tasks',
                  badgeText: '${calendarViewModel.allTasksCount}',
                  isSelected: calendarViewModel.activeNavIndex == 0 && calendarViewModel.selectedSection == 'all_tasks',
                  onTap: () => calendarViewModel.setSelectedSection('all_tasks'),
                ),
                _buildNavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'My Calendar',
                  isSelected: calendarViewModel.activeNavIndex == 0 && calendarViewModel.selectedSection == 'my_calendar',
                  onTap: () => calendarViewModel.setSelectedSection('my_calendar'),
                  isPrimaryHighlight: calendarViewModel.activeNavIndex == 0 && calendarViewModel.selectedSection == 'my_calendar',
                ),
                _buildNavItem(
                  icon: Icons.video_call_rounded,
                  label: 'Video Calls',
                  badgeText: '${calendarViewModel.allScheduledCalls.length}',
                  isSelected: calendarViewModel.activeNavIndex == 1,
                  onTap: () => calendarViewModel.setActiveNavIndex(1),
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Briefing',
                  badgeText: 'AI',
                  isSelected: calendarViewModel.activeNavIndex == 2,
                  onTap: () => calendarViewModel.setActiveNavIndex(2),
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'தமிழ் நாட்காட்டி',
                  badgeText: 'தினம் & மாதம்',
                  badgeBgColor: const Color(0xFFFEF3C7),
                  badgeTextColor: const Color(0xFFB45309),
                  isSelected: calendarViewModel.activeNavIndex == 4,
                  onTap: () => calendarViewModel.setActiveNavIndex(4),
                  isPrimaryHighlight: calendarViewModel.activeNavIndex == 4,
                ),
                _buildNavItem(
                  icon: Icons.celebration_rounded,
                  label: 'Tamil Holidays',
                  badgeText: '${calendarViewModel.upcomingTamilHolidays.length}',
                  badgeBgColor: const Color(0xFFFEF3C7),
                  badgeTextColor: const Color(0xFFB45309),
                  isSelected: calendarViewModel.sourceFilter == EventSource.tamilHoliday,
                  onTap: () {
                    if (calendarViewModel.sourceFilter == EventSource.tamilHoliday) {
                      calendarViewModel.setSourceFilter(null);
                    } else {
                      calendarViewModel.setSourceFilter(EventSource.tamilHoliday);
                      calendarViewModel.setActiveNavIndex(0);
                    }
                  },
                ),
                _buildNavItem(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Tamil Timings',
                  badgeText: 'நல்ல நேரம்',
                  badgeBgColor: const Color(0xFFDCFCE7),
                  badgeTextColor: const Color(0xFF15803D),
                  isSelected: calendarViewModel.showTamilTimings,
                  onTap: () {
                    calendarViewModel.toggleTamilTimings(!calendarViewModel.showTamilTimings);
                  },
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Accounts & Sync',
                  isSelected: calendarViewModel.activeNavIndex == 3,
                  onTap: () => calendarViewModel.setActiveNavIndex(3),
                ),
                const SizedBox(height: 6),

                // Tamil Solar Calendar Quick Card (தமிழ் நாட்காட்டி) - Clickable to open full view
                InkWell(
                  onTap: () => calendarViewModel.setActiveNavIndex(4),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: calendarViewModel.activeNavIndex == 4
                            ? const Color(0xFFE65100)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        width: calendarViewModel.activeNavIndex == 4 ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🗓️', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            const Text(
                              'தமிழ் நாட்காட்டி',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFFB45309)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          calendarViewModel.selectedTamilDate.fullTamilDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF78350F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ஆண்டு: ${calendarViewModel.selectedTamilDate.tamilYear} • மாதம்: ${calendarViewModel.selectedTamilDate.tamilMonth}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Custom Views added by user
                for (final view in calendarViewModel.customViews)
                  _buildNavItem(
                    icon: Icons.view_agenda_outlined,
                    label: view,
                    isSelected: calendarViewModel.selectedSection == 'custom_$view',
                    onTap: () => calendarViewModel.setSelectedSection('custom_$view'),
                  ),

                _buildClickableTextAction(
                  '+ Add new view',
                  onTap: () => _showAddViewDialog(context),
                ),
                const SizedBox(height: 20),

                // My lists
                Row(
                  children: [
                    const Text(
                      'My lists',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textMuted),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Add new list',
                      onPressed: () => _showAddListDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                for (final list in calendarViewModel.customLists)
                  _buildListItem(
                    label: list['name'] as String,
                    badgeText: '${calendarViewModel.getListCount(list['name'] as String)}',
                    isSelected: calendarViewModel.selectedList == list['name'],
                    onTap: () => calendarViewModel.setSelectedList(list['name'] as String),
                  ),


                _buildClickableTextAction(
                  '+ Add new list',
                  onTap: () => _showAddListDialog(context),
                ),
                const SizedBox(height: 20),

                // Tags Section
                Row(
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Add new tag',
                      onPressed: () => _showAddTagDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                for (final tag in calendarViewModel.customTags)
                  _buildTagItem(
                    tag: tag['name'] as String,
                    color: tag['color'] as Color,
                    isSelected: calendarViewModel.selectedTag == tag['name'],
                    onTap: () => calendarViewModel.setSelectedTag(tag['name'] as String),
                  ),
              ],
            ),
          ),

          // Bottom Account & Sync Pill
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => calendarViewModel.setActiveNavIndex(3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: calendarViewModel.connectedAccountsCount > 0
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        calendarViewModel.connectedAccountsCount > 0
                            ? '${calendarViewModel.connectedAccountsCount} Account(s) Synced'
                            : 'Connect Calendar Account',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync_rounded, size: 16, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      tooltip: 'Sync accounts',
                      onPressed: () async {
                        if (calendarViewModel.connectedAccountsCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing connected accounts...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          await calendarViewModel.refresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No accounts connected. Navigating to Accounts & Sync...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          calendarViewModel.setActiveNavIndex(3);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNavItem({
    required IconData icon,
    required String label,
    String? badgeText,
    Color? badgeBgColor,
    Color? badgeTextColor,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPrimaryHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isPrimaryHighlight
            ? AppColors.primarySoft
            : isSelected
                ? AppColors.bg
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Icon(
          icon,
          size: 18,
          color: isPrimaryHighlight
              ? AppColors.primary
              : isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isPrimaryHighlight || isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isPrimaryHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBgColor ?? const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor ?? AppColors.textMuted,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildListItem({
    required String label,
    required String badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagItem({
    required String tag,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              '#',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableTextAction(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showAddViewDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Calendar View'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Work Sprints, Fitness, Quarterly Review',
            labelText: 'View Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                calendarViewModel.addCustomView(controller.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add View'),
          ),
        ],
      ),
    );
  }

  void _showAddListDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Projects, Groceries, Study',
            labelText: 'List Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                calendarViewModel.addCustomList(controller.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create List'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF3B82F6); // Blue
    final colors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Urgent, Design, Marketing',
                  labelText: 'Tag Name',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Pick Color:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final color in colors)
                    GestureDetector(
                      onTap: () => setModalState(() => selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black87 : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  calendarViewModel.addCustomTag(controller.text.trim(), selectedColor);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Create Tag'),
            ),
          ],
        ),
      ),
    );
  }
}

