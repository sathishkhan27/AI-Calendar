import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/models/event_item.dart';

class MeetingCallCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const MeetingCallCard({
    super.key,
    required this.event,
    this.onDelete,
    this.onTap,
  });

  Future<void> _launchMeetingUrl(BuildContext context) async {
    if (event.meetingUrl == null || event.meetingUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting link available for this call')),
      );
      return;
    }
    final uri = Uri.parse(event.meetingUrl!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: ${event.meetingUrl}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching call: $e')),
        );
      }
    }
  }

  Color _getProviderColor() {
    switch (event.callType) {
      case CallType.googleMeet:
        return AppColors.googleRed;
      case CallType.msTeams:
        return AppColors.teamsPurple;
      case CallType.zoom:
        return AppColors.zoomBlue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getProviderIcon() {
    switch (event.callType) {
      case CallType.googleMeet:
        return Icons.videocam_rounded;
      case CallType.msTeams:
        return Icons.groups_rounded;
      case CallType.zoom:
        return Icons.videocam_rounded;
      case CallType.phone:
        return Icons.phone_in_talk_rounded;
      default:
        return Icons.video_call_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isHappeningNow = event.isHappeningAt(now);
    final providerColor = _getProviderColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHappeningNow ? providerColor : AppColors.border,
          width: isHappeningNow ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHappeningNow
                ? providerColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Provider badge, relative status, and join button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: providerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: providerColor.withValues(alpha: 0.3)),
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getProviderIcon(), size: 14, color: providerColor),
                      const SizedBox(width: 5),
                      Text(
                        event.callType.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: providerColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    event.source.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: event.source == EventSource.google
                          ? AppColors.googleRed
                          : AppColors.outlookBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateTimeUtils.getRelativeTimeStatus(event.startTime, event.endTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isHappeningNow ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title and Description
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Time and Duration
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${DateTimeUtils.formatTime(event.startTime)} - ${DateTimeUtils.formatTime(event.endTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${DateTimeUtils.formatDuration(event.duration)})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            // AI Prep Notes if available
            if (event.aiPrepNotes != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.aiSparkleSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.aiSparkle.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: AppColors.aiSparkle),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.aiPrepNotes!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Attendees and Action Buttons
            const SizedBox(height: 12),
            Row(
              children: [
                if (event.attendees.isNotEmpty) ...[
                  Row(
                    children: [
                      for (int i = 0; i < event.attendees.take(3).length; i++)
                        Align(
                          widthFactor: 0.7,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: [
                                Colors.blueGrey,
                                Colors.indigo,
                                Colors.teal,
                              ][i % 3],
                              child: Text(
                                event.attendees[i].name.isNotEmpty
                                    ? event.attendees[i].name[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (event.attendees.length > 3) ...[
                        const SizedBox(width: 6),
                        Text(
                          '+${event.attendees.length - 3}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const Spacer(),
                if (event.meetingUrl != null && event.meetingUrl!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _launchMeetingUrl(context),
                    icon: Icon(
                      isHappeningNow ? Icons.call_rounded : Icons.link_rounded,
                      size: 15,
                    ),
                    label: Text(
                      isHappeningNow
                          ? 'Join Call Now'
                          : 'Join ${event.callType.displayName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHappeningNow ? AppColors.success : providerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
