import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/models/daily_briefing.dart';

class DailyBriefingCard extends StatelessWidget {
  final DailyBriefing briefing;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(String) onToggleAction;
  final Set<String> completedActions;

  const DailyBriefingCard({
    super.key,
    required this.briefing,
    required this.isLoading,
    required this.onRefresh,
    required this.onToggleAction,
    required this.completedActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI Sparkle gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.aiSparkleSoft,
                  AppColors.primarySoft,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.aiSparkle.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.aiSparkle,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Executive Briefing',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateTimeUtils.formatDate(briefing.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Regenerate Briefing',
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18, color: AppColors.aiSparkle),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive summary
                Text(
                  briefing.executiveSummary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),

                // Metrics Row
                Row(
                  children: [
                    _buildMetricChip(
                      label: 'Scheduled Calls',
                      value: '${briefing.totalCalls}',
                      icon: Icons.video_call_rounded,
                      color: AppColors.googleBlue,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      label: 'All Events',
                      value: '${briefing.totalEvents}',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricChip(
                      label: 'Focus Time',
                      value: '${briefing.focusTimeMinutes ~/ 60}h ${briefing.focusTimeMinutes % 60}m',
                      icon: Icons.timer_outlined,
                      color: AppColors.success,
                    ),
                  ],
                ),

                // Conflict Warnings if present
                if (briefing.conflictAlerts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.error),
                            SizedBox(width: 6),
                            Text(
                              'Schedule Overlap Detected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        for (final alert in briefing.conflictAlerts)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '• $alert',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Action Items Section
                if (briefing.actionItems.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Smart Action Items & Prep',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final item in briefing.actionItems)
                    InkWell(
                      onTap: () => onToggleAction(item),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              completedActions.contains(item)
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 16,
                              color: completedActions.contains(item)
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: completedActions.contains(item)
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: completedActions.contains(item)
                                      ? TextDecoration.lineThrough
                                      : null,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
