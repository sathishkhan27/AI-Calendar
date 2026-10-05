import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/event_item.dart';
import '../../view_models/calendar_view_model.dart';

class EventDetailsDialog extends StatelessWidget {
  final EventItem event;
  final CalendarViewModel viewModel;

  const EventDetailsDialog({
    super.key,
    required this.event,
    required this.viewModel,
  });

  static Future<void> show(BuildContext context, EventItem event, CalendarViewModel viewModel) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EventDetailsDialog(
        event: event,
        viewModel: viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHoliday = event.isHoliday || event.source == EventSource.tamilHoliday;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Banner with source styling
              _buildHeader(context, isHoliday),

              // Content Body (Scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Key Metadata Grid (Date, Time, Duration, Location)
                      _buildMetadataSection(isHoliday),
                      const SizedBox(height: 16),

                      // Special Tamil Holiday Card
                      if (isHoliday) ...[
                        _buildTamilHolidayBanner(),
                        const SizedBox(height: 16),
                      ],

                      // Description Section
                      if (event.description.trim().isNotEmpty) ...[
                        _buildSectionHeader('ABOUT & NOTES', Icons.notes_rounded),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // AI Prep & Executive Summary (if available)
                      if (event.aiSummary != null || event.aiPrepNotes != null) ...[
                        _buildAiInsightsSection(),
                        const SizedBox(height: 16),
                      ],

                      // Attendees Section (if any)
                      if (event.attendees.isNotEmpty) ...[
                        _buildSectionHeader('ATTENDEES (${event.attendees.length})', Icons.people_outline_rounded),
                        const SizedBox(height: 8),
                        _buildAttendeesList(),
                        const SizedBox(height: 16),
                      ],

                      // Video Call Join Action Button
                      if (event.meetingUrl != null && event.meetingUrl!.isNotEmpty) ...[
                        _buildJoinCallButton(),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer Action Bar
              const Divider(height: 1, color: AppColors.border),
              _buildFooterActions(context, isHoliday),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isHoliday) {
    Color headerBg;
    Color headerBorder;
    Widget sourceBadge;

    if (isHoliday) {
      headerBg = const Color(0xFFFEF3C7);
      headerBorder = const Color(0xFFFDE68A);
      sourceBadge = Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('🚩', style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text(
            'Tamil Nadu Public Holiday',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      );
    } else {
      headerBg = event.colorTheme.bgColor.withValues(alpha: 0.5);
      headerBorder = event.colorTheme.borderColor.withValues(alpha: 0.5);
      sourceBadge = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            event.callType.isCall
                ? (event.callType == CallType.googleMeet ? Icons.videocam_rounded : Icons.groups_rounded)
                : (event.isTask ? Icons.check_circle_outline_rounded : Icons.calendar_today_rounded),
            size: 14,
            color: event.colorTheme.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            event.source.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: event.colorTheme.textColor,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: headerBorder, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: headerBorder),
            ),
            child: sourceBadge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            splashRadius: 18,
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(bool isHoliday) {
    final startTimeStr = event.isAllDay ? 'All Day' : DateFormat('h:mm a').format(event.startTime);
    final endTimeStr = event.isAllDay ? '' : ' - ${DateFormat('h:mm a').format(event.endTime)}';
    final dateStr = DateFormat('EEEE, MMMM d, y').format(event.startTime);
    final tamilDate = viewModel.getTamilDateFor(event.startTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Date & Time Row (Dual Gregorian & Tamil Calendar)
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.primary,
            label: 'When',
            value: '$dateStr\n🗓️ ${tamilDate.shortTamilDate}, ${tamilDate.tamilYear} ஆண்டு\n$startTimeStr$endTimeStr',
          ),

          if (event.duration.inMinutes > 0 && !event.isAllDay) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildDetailRow(
              icon: Icons.timelapse_rounded,
              iconColor: AppColors.secondary,
              label: 'Duration',
              value: '${event.duration.inMinutes} minutes',
            ),
          ],

          if (event.location != null && event.location!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFEF4444),
              label: 'Location',
              value: event.location!,
            ),
          ],

          if (!isHoliday) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _buildDetailRow(
              icon: Icons.flag_outlined,
              iconColor: const Color(0xFFF59E0B),
              label: 'Priority',
              valueWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: event.colorTheme.bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: event.colorTheme.borderColor, width: 0.8),
                ),
                child: Text(
                  event.priority.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: event.colorTheme.textColor,
                  ),
                ),
              ),
            ),
          ],

          // Tamil Panchangam Auspicious / Inauspicious timing assessment
          Builder(
            builder: (context) {
              final timings = viewModel.getTamilTimingsFor(event.startTime);
              final badSlot = timings.getConflictingBadTiming(event.startTime, event.endTime);
              final goodSlot = timings.getMatchingGoodTiming(event.startTime, event.endTime);

              if (badSlot != null) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildDetailRow(
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFDC2626),
                      label: 'Tamil Timing',
                      value: 'Overlaps with ${badSlot.tamilLabel} (${badSlot.label}: ${badSlot.timeFormatted})',
                    ),
                  ],
                );
              } else if (goodSlot != null) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildDetailRow(
                      icon: Icons.wb_sunny_rounded,
                      iconColor: const Color(0xFF16A34A),
                      label: 'Tamil Timing',
                      value: 'Auspicious: ${goodSlot.tamilLabel} (${goodSlot.timeFormatted})',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildTamilHolidayBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🏛️', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Official Tamil Nadu Gazetted Holiday',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'தமிழ்நாடு அரசு பொது விடுமுறை நாள் • Declared under Negotiable Instruments Act. All Government offices, educational institutions, treasuries, and commercial banks in Tamil Nadu observe holiday.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: Color(0xFFB45309),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'AI Smart Briefing & Preparation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6D28D9),
                ),
              ),
            ],
          ),
          if (event.aiSummary != null) ...[
            const SizedBox(height: 8),
            Text(
              event.aiSummary!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4C1D95), height: 1.4),
            ),
          ],
          if (event.aiPrepNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.aiPrepNotes!,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendeesList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in event.attendees)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    a.name.isNotEmpty ? a.name[0].toUpperCase() : 'A',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  a.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                if (a.isOrganizer) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Host', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildJoinCallButton() {
    final isMeet = event.callType == CallType.googleMeet;
    final buttonColor = isMeet ? AppColors.googleRed : AppColors.teamsPurple;

    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(event.meetingUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(Icons.video_call_rounded, size: 20),
      label: Text(
        'Join with ${event.callType.displayName}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, bool isHoliday) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (event.isTask)
            OutlinedButton.icon(
              onPressed: () {
                viewModel.toggleTaskCompletion(event.id);
                Navigator.of(context).pop();
              },
              icon: Icon(
                event.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 16,
                color: event.isCompleted ? AppColors.success : AppColors.textMuted,
              ),
              label: Text(
                event.isCompleted ? 'Mark Pending' : 'Mark Done',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

          if (!isHoliday)
            TextButton.icon(
              onPressed: () {
                viewModel.deleteEvent(event.id);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),

          const Spacer(),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
