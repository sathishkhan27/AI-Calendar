import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/event_item.dart';
import '../../view_models/calendar_view_model.dart';

class AddEventDialog extends StatefulWidget {
  final CalendarViewModel viewModel;
  final DateTime initialDate;

  const AddEventDialog({
    super.key,
    required this.viewModel,
    required this.initialDate,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  bool _useAiPrompt = true;
  final _aiController = TextEditingController(
    text: 'Sync with product design tomorrow at 3:00 PM on Google Meet',
  );

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingUrlController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _durationMinutes = 30;
  CallType _callType = CallType.googleMeet;
  EventSource _source = EventSource.local;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _aiController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _meetingUrlController.dispose();
    super.dispose();
  }

  void _handleAiSchedule() {
    final prompt = _aiController.text.trim();
    if (prompt.isEmpty) return;

    final event = widget.viewModel.repository.parseNaturalLanguage(
      prompt,
      _selectedDate,
    );
    widget.viewModel.addEvent(event);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.aiSparkle, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Scheduled: "${event.title}" on ${DateFormat('EEE, MMM d @ h:mm a').format(event.startTime)}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleManualSchedule() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title')),
      );
      return;
    }

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final end = start.add(Duration(minutes: _durationMinutes));

    String? meetingUrl = _meetingUrlController.text.trim();
    if (meetingUrl.isEmpty) {
      if (_callType == CallType.googleMeet) {
        meetingUrl = 'https://meet.google.com/new';
      } else if (_callType == CallType.msTeams) {
        meetingUrl = 'https://teams.microsoft.com/l/meetup-join/new';
      } else if (_callType == CallType.zoom) {
        meetingUrl = 'https://zoom.us/join';
      } else {
        meetingUrl = null;
      }
    }

    final event = EventItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startTime: start,
      endTime: end,
      source: _source,
      callType: _callType,
      meetingUrl: meetingUrl,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      priority: EventPriority.medium,
      colorTheme: _callType == CallType.googleMeet
          ? EventPastelColor.peach
          : _callType == CallType.msTeams
              ? EventPastelColor.lavender
              : EventPastelColor.mint,
    );

    widget.viewModel.addEvent(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_task_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Schedule Event or Call',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle AI vs Manual Form
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _useAiPrompt = true),
                          borderRadius: BorderRadius.circular(9),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _useAiPrompt ? AppColors.aiSparkleSoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: _useAiPrompt ? Border.all(color: AppColors.aiSparkle) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 15,
                                  color: _useAiPrompt ? AppColors.aiSparkle : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Natural Language',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _useAiPrompt ? AppColors.aiSparkle : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _useAiPrompt = false),
                          borderRadius: BorderRadius.circular(9),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_useAiPrompt ? AppColors.primarySoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: !_useAiPrompt ? Border.all(color: AppColors.primary) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 15,
                                  color: !_useAiPrompt ? AppColors.primary : AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Manual Custom',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: !_useAiPrompt ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_useAiPrompt) ...[
                  const Text(
                    'Tell the AI what you want to schedule:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aiController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. "Weekly design review tomorrow at 3 PM on Google Meet for 45 minutes"',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildQuickPromptChip('Quick 15m Google Meet sync'),
                      _buildQuickPromptChip('1-hour Microsoft Teams sprint review'),
                      _buildQuickPromptChip('Holiday plan meeting w/ Carla on Meet'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleAiSchedule,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Parse & Schedule with AI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  // Manual Form
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'e.g. Architecture Deep Dive',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Call Platform Selector
                  const Text('Meeting Type / Call Platform', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<CallType>(
                    initialValue: _callType,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(),
                    items: CallType.values.map((ct) {
                      return DropdownMenuItem(
                        value: ct,
                        child: Text(ct.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _callType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Calendar Account Source
                  const Text('Assign To Calendar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<EventSource>(
                    initialValue: _source,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(),
                    items: EventSource.values.map((src) {
                      return DropdownMenuItem(
                        value: src,
                        child: Text(src.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _source = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Date and Time selectors
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule, size: 16),
                          label: Text(_selectedTime.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) setState(() => _selectedTime = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dual Tamil Date Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Text('🗓️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            'Tamil Date: ${widget.viewModel.getTamilDateFor(_selectedDate).fullTamilDate}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Duration chips
                  Row(
                    children: [15, 30, 45, 60, 90].map((mins) {
                      final isSelected = _durationMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${mins}m'),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _durationMinutes = mins);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Tamil Panchangam timing feedback for selected slot
                  Builder(
                    builder: (context) {
                      final startDt = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      final endDt = startDt.add(Duration(minutes: _durationMinutes));
                      final timings = widget.viewModel.getTamilTimingsFor(_selectedDate);
                      final badSlot = timings.getConflictingBadTiming(startDt, endDt);
                      final goodSlot = timings.getMatchingGoodTiming(startDt, endDt);

                      if (badSlot != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFDC2626)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Timing Notice: Overlaps with ${badSlot.tamilLabel} (${badSlot.label}: ${badSlot.timeFormatted}). Inauspicious period for new ventures or contracts.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (goodSlot != null) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF16A34A)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Auspicious Time: Scheduled during ${goodSlot.tamilLabel} (${goodSlot.timeFormatted}). Good for agreements and key actions.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description / Agenda (Optional)',
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleManualSchedule,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Save Event'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPromptChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      backgroundColor: AppColors.bg,
      side: const BorderSide(color: AppColors.border),
      onPressed: () => setState(() => _aiController.text = text),
    );
  }
}
