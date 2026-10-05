import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/models/event_item.dart';
import '../view_models/ai_briefing_view_model.dart';
import '../view_models/calendar_view_model.dart';
import 'widgets/add_event_dialog.dart';
import 'widgets/daily_briefing_card.dart';
import 'widgets/time_grid_view.dart';

class CalendarView extends StatefulWidget {
  final CalendarViewModel calendarViewModel;
  final AiBriefingViewModel aiBriefingViewModel;

  const CalendarView({
    super.key,
    required this.calendarViewModel,
    required this.aiBriefingViewModel,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final _searchController = TextEditingController();
  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.aiBriefingViewModel.loadBriefingForDate(widget.calendarViewModel.selectedDate);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.calendarViewModel, widget.aiBriefingViewModel]),
      builder: (context, _) {
        final isDesktop = ResponsiveUtils.isDesktop(context);
        final viewModel = widget.calendarViewModel;

        return Scaffold(
          backgroundColor: AppColors.bg,
          // Top Navigation Bar matching sample screen
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SafeArea(
                child: Row(
                  children: [
                    // TODAY button
                    OutlinedButton(
                      onPressed: () => viewModel.goToToday(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Left/Right Chevron Navigation
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: 'Previous',
                      onPressed: () => viewModel.previous(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: 'Next',
                      onPressed: () => viewModel.next(),
                    ),
                    const SizedBox(width: 14),

                    // Dynamic Date Range: Gregorian Calendar + Tamil Solar Calendar (Dual Display)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewModel.dateRangeLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: 'Open Tamil Calendar (தமிழ் நாட்காட்டி)',
                          child: InkWell(
                            onTap: () => viewModel.setActiveNavIndex(4),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🗓️ ', style: TextStyle(fontSize: 11)),
                                  Text(
                                    viewModel.tamilDateRangeLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF92400E)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Active Filter Chip (if list, tag, call, or source filter is active)
                    if (viewModel.selectedList != null ||
                        viewModel.selectedTag != null ||
                        viewModel.onlyCallsFilter ||
                        viewModel.sourceFilter != null) ...[
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: viewModel.sourceFilter == EventSource.tamilHoliday
                              ? const Color(0xFFFEF3C7)
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: viewModel.sourceFilter == EventSource.tamilHoliday
                                ? const Color(0xFFF59E0B)
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewModel.sourceFilter != null
                                  ? (viewModel.sourceFilter == EventSource.tamilHoliday
                                      ? '🚩 TN Holidays'
                                      : 'Source: ${viewModel.sourceFilter!.displayName}')
                                  : viewModel.selectedList != null
                                      ? 'List: ${viewModel.selectedList}'
                                      : viewModel.selectedTag != null
                                          ? '#${viewModel.selectedTag}'
                                          : 'Calls Only',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: viewModel.sourceFilter == EventSource.tamilHoliday
                                    ? const Color(0xFFB45309)
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => viewModel.clearFilters(),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: viewModel.sourceFilter == EventSource.tamilHoliday
                                    ? const Color(0xFFB45309)
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Search field if expanded
                    if (_showSearchField)
                      Container(
                        width: 180,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => viewModel.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close, size: 14),
                              onPressed: () {
                                setState(() => _showSearchField = false);
                                _searchController.clear();
                                viewModel.setSearchQuery('');
                              },
                            ),
                          ),
                        ),
                      ),

                    // WEEK ⌄ dropdown pill button
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CalendarViewMode>(
                          value: viewModel.viewMode,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                          items: CalendarViewMode.values.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(mode.label),
                            );
                          }).toList(),
                          onChanged: (mode) {
                            if (mode != null) viewModel.setViewMode(mode);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Top Action Icons
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.textSecondary),
                      tooltip: 'More options',
                      onSelected: (val) {
                        switch (val) {
                          case 'add_event':
                            showDialog(
                              context: context,
                              builder: (ctx) => AddEventDialog(
                                viewModel: viewModel,
                                initialDate: viewModel.selectedDate,
                              ),
                            );
                            break;
                          case 'resync':
                            viewModel.refresh();
                            break;
                          case 'audio_briefing':
                            _showAiAudioBriefingModal(context);
                            break;
                          case 'clear_filters':
                            viewModel.clearFilters();
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'add_event',
                          child: Row(
                            children: [
                              Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text('Create New Event'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'resync',
                          child: Row(
                            children: [
                              Icon(Icons.sync_rounded, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 10),
                              Text('Force Sync Accounts'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'audio_briefing',
                          child: Row(
                            children: [
                              Icon(Icons.headphones_rounded, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 10),
                              Text('AI Voice Briefing'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'clear_filters',
                          child: Row(
                            children: [
                              Icon(Icons.filter_alt_off_rounded, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 10),
                              Text('Clear All Filters'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Sync calendar',
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Syncing calendar events...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        await viewModel.refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.headphones_outlined, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Audio AI briefing',
                      onPressed: () => _showAiAudioBriefingModal(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_sidebar_outlined, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Toggle AI Panel',
                      onPressed: () => viewModel.toggleAiDrawer(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Search',
                      onPressed: () => setState(() => _showSearchField = !_showSearchField),
                    ),
                  ],
                ),
              ),
            ),
          ),


          body: Stack(
            children: [
              // Main content: either Time Grid or split with AI drawer
              Row(
                children: [
                  Expanded(
                    child: TimeGridView(viewModel: viewModel),
                  ),

                  // Right-side collapsible AI Intelligence Sidebar
                  if (viewModel.isAiDrawerOpen && isDesktop) ...[
                    const VerticalDivider(width: 1, color: AppColors.border),
                    SizedBox(
                      width: 380,
                      child: Container(
                        color: AppColors.surface,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.aiSparkleSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: AppColors.aiSparkle, size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'AI Insights & Suggestions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => viewModel.toggleAiDrawer(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.aiBriefingViewModel.briefing != null)
                              DailyBriefingCard(
                                briefing: widget.aiBriefingViewModel.briefing!,
                                isLoading: widget.aiBriefingViewModel.isLoading,
                                onRefresh: () => widget.aiBriefingViewModel.loadBriefingForDate(viewModel.selectedDate),
                                onToggleAction: widget.aiBriefingViewModel.toggleActionItem,
                                completedActions: widget.aiBriefingViewModel.completedActions,
                              ),
                            const SizedBox(height: 16),
                            _buildQuickAiScheduler(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Floating AI Button with Lightbulb icon & notification badge '12' (matching sample screen)
              Positioned(
                right: 0,
                top: 240,
                child: InkWell(
                  onTap: () {
                    if (isDesktop) {
                      viewModel.toggleAiDrawer();
                    } else {
                      _showAiModalSheet(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(-2, 2),
                        ),
                      ],
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${widget.aiBriefingViewModel.briefing?.actionItems.length ?? widget.calendarViewModel.myDayCount}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildQuickAiScheduler(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule with Natural Language',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g. "Review with team tomorrow at 3pm on Meet"',
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  widget.aiBriefingViewModel.scheduleFromNaturalLanguage(
                    txt,
                    widget.calendarViewModel.selectedDate,
                  );
                  controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI scheduled meeting into your calendar!')),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome, size: 14),
              label: const Text('Schedule with AI'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiAudioBriefingModal(BuildContext context) {
    final briefing = widget.aiBriefingViewModel.briefing;
    final events = widget.calendarViewModel.eventsForSelectedDay;
    final calls = events.where((e) => e.isCall).toList();

    final audioText = briefing != null
        ? '${briefing.executiveSummary} ${briefing.productivityTip}'
        : 'Good day! You have ${events.length} event(s) and ${calls.length} scheduled call(s) for ${widget.calendarViewModel.dateRangeLabel}.';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.headphones_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('AI Voice Executive Briefing'),
          ],
        ),
        content: Text(
          'Synthesized audio briefing:\n\n"$audioText"',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showAiModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  '12 AI Suggestions & Action Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.aiBriefingViewModel.briefing != null)
              DailyBriefingCard(
                briefing: widget.aiBriefingViewModel.briefing!,
                isLoading: widget.aiBriefingViewModel.isLoading,
                onRefresh: () => widget.aiBriefingViewModel.loadBriefingForDate(widget.calendarViewModel.selectedDate),
                onToggleAction: widget.aiBriefingViewModel.toggleActionItem,
                completedActions: widget.aiBriefingViewModel.completedActions,
              ),
          ],
        ),
      ),
    );
  }
}
