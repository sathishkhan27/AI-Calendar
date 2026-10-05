import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../view_models/ai_briefing_view_model.dart';
import '../view_models/calendar_view_model.dart';
import 'widgets/daily_briefing_card.dart';

class AiBriefingView extends StatefulWidget {
  final AiBriefingViewModel aiBriefingViewModel;
  final CalendarViewModel calendarViewModel;

  const AiBriefingView({
    super.key,
    required this.aiBriefingViewModel,
    required this.calendarViewModel,
  });

  @override
  State<AiBriefingView> createState() => _AiBriefingViewState();
}

class _AiBriefingViewState extends State<AiBriefingView> {
  final _aiPromptController = TextEditingController();
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentDate = widget.calendarViewModel.selectedDate;
    widget.aiBriefingViewModel.loadBriefingForDate(_currentDate);
  }

  @override
  void dispose() {
    _aiPromptController.dispose();
    super.dispose();
  }

  void _submitPrompt() {
    final text = _aiPromptController.text.trim();
    if (text.isEmpty) return;

    widget.aiBriefingViewModel.scheduleFromNaturalLanguage(text, _currentDate);
    _aiPromptController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: const [
            Icon(Icons.auto_awesome, color: AppColors.aiSparkle, size: 18),
            SizedBox(width: 10),
            Text('AI processed request and updated schedule!', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.aiBriefingViewModel,
      builder: (context, _) {
        final briefing = widget.aiBriefingViewModel.briefing;
        final isLoading = widget.aiBriefingViewModel.isLoading;

        return Scaffold(
          backgroundColor: AppColors.darkBg,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.aiSparkle, size: 22),
                const SizedBox(width: 10),
                const Text('AI Intelligence & Daily Briefing', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                tooltip: 'Select Date',
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _currentDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _currentDate = picked);
                    widget.aiBriefingViewModel.loadBriefingForDate(picked);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Regenerate',
                onPressed: () => widget.aiBriefingViewModel.loadBriefingForDate(_currentDate),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Natural language command bar
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.aiSparkle.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.aiSparkle.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Calendar Assistant',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ask AI to schedule calls, detect conflicts, or synthesize agenda prep notes.',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aiPromptController,
                            onSubmitted: (_) => _submitPrompt(),
                            decoration: InputDecoration(
                              hintText: 'e.g., "Schedule a 30m design review tomorrow with Sarah at 2 PM on Meet"',
                              prefixIcon: const Icon(Icons.psychology_rounded, color: AppColors.aiSparkle, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_upward_rounded, color: AppColors.aiSparkle),
                                onPressed: _submitPrompt,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildPromptSuggestion('Sync tomorrow at 4pm on Google Meet'),
                        _buildPromptSuggestion('1-hour sprint planning on Teams'),
                        _buildPromptSuggestion('Quick 15-minute sync with lead'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Briefing Card
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (briefing != null) ...[
                DailyBriefingCard(
                  briefing: briefing,
                  isLoading: isLoading,
                  onRefresh: () => widget.aiBriefingViewModel.loadBriefingForDate(_currentDate),
                  onToggleAction: widget.aiBriefingViewModel.toggleActionItem,
                  completedActions: widget.aiBriefingViewModel.completedActions,
                ),
                const SizedBox(height: 24),

                // Highlights breakdown
                if (briefing.scheduleHighlights.isNotEmpty) ...[
                  const Text(
                    'Schedule Chronological Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < briefing.scheduleHighlights.length; i++)
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.darkBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                            title: Text(
                              briefing.scheduleHighlights[i],
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromptSuggestion(String text) {
    return InkWell(
      onTap: () {
        _aiPromptController.text = text;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
        ),
      ),
    );
  }
}
