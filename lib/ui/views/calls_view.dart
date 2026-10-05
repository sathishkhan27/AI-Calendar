import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/event_item.dart';
import '../view_models/calendar_view_model.dart';
import 'widgets/add_event_dialog.dart';
import 'widgets/event_details_dialog.dart';
import 'widgets/meeting_call_card.dart';

class CallsView extends StatefulWidget {
  final CalendarViewModel calendarViewModel;

  const CallsView({
    super.key,
    required this.calendarViewModel,
  });

  @override
  State<CallsView> createState() => _CallsViewState();
}

class _CallsViewState extends State<CallsView> {
  CallType? _selectedCallType;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.calendarViewModel,
      builder: (context, _) {
        var calls = widget.calendarViewModel.allScheduledCalls;

        if (_selectedCallType != null) {
          calls = calls.where((c) => c.callType == _selectedCallType).toList();
        }

        final now = DateTime.now();
        final currentCall = calls.where((c) => c.isHappeningAt(now)).toList();
        final upcomingCalls = calls.where((c) => c.startTime.isAfter(now)).toList();
        final totalCallMins = calls.fold<int>(0, (sum, c) => sum + c.duration.inMinutes);

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Scheduled Calls & Meetings', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Sync Calls',
                onPressed: () => widget.calendarViewModel.refresh(),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AddEventDialog(
                        viewModel: widget.calendarViewModel,
                        initialDate: DateTime.now(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call_rounded, size: 18),
                  label: const Text('Schedule Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Summary Banner: Call Metrics
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildStatCol(
                      label: 'Active Scheduled Calls',
                      value: '${calls.length}',
                      icon: Icons.video_camera_front_rounded,
                      color: AppColors.googleBlue,
                    ),
                    _buildDivider(),
                    _buildStatCol(
                      label: 'Total Call Duration',
                      value: '${totalCallMins ~/ 60}h ${totalCallMins % 60}m',
                      icon: Icons.timer_outlined,
                      color: AppColors.teamsPurple,
                    ),
                    _buildDivider(),
                    _buildStatCol(
                      label: 'Live Now',
                      value: currentCall.isNotEmpty ? '1 Active Call' : 'None',
                      icon: Icons.sensors_rounded,
                      color: currentCall.isNotEmpty ? AppColors.success : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Tabs (All, Google Meet, Microsoft Teams, Zoom)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Calls'),
                      selected: _selectedCallType == null,
                      onSelected: (_) => setState(() => _selectedCallType = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.video_camera_front, size: 16, color: AppColors.googleBlue),
                      label: const Text('Google Meet'),
                      selected: _selectedCallType == CallType.googleMeet,
                      onSelected: (val) => setState(() => _selectedCallType = val ? CallType.googleMeet : null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.groups, size: 16, color: AppColors.teamsPurple),
                      label: const Text('Microsoft Teams'),
                      selected: _selectedCallType == CallType.msTeams,
                      onSelected: (val) => setState(() => _selectedCallType = val ? CallType.msTeams : null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.videocam, size: 16, color: AppColors.zoomBlue),
                      label: const Text('Zoom'),
                      selected: _selectedCallType == CallType.zoom,
                      onSelected: (val) => setState(() => _selectedCallType = val ? CallType.zoom : null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // If a call is happening right now, highlight it in a special hero box
              if (currentCall.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HAPPENING RIGHT NOW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final liveCall in currentCall)
                  MeetingCallCard(
                    event: liveCall,
                    onTap: () => EventDetailsDialog.show(context, liveCall, widget.calendarViewModel),
                    onDelete: () => widget.calendarViewModel.deleteEvent(liveCall.id),
                  ),
                const SizedBox(height: 24),
              ],

              // Upcoming Calls section
              Row(
                children: [
                  const Text(
                    'Upcoming Calls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${upcomingCalls.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (upcomingCalls.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'No upcoming calls in your queue. All synced calls from Gmail and Outlook will appear here.',
                      style: TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                for (final call in upcomingCalls)
                  MeetingCallCard(
                    event: call,
                    onTap: () => EventDetailsDialog.show(context, call, widget.calendarViewModel),
                    onDelete: () => widget.calendarViewModel.deleteEvent(call.id),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCol({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.border,
    );
  }
}
