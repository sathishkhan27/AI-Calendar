import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/event_item.dart';
import '../../../data/models/tamil_daily_timings.dart';
import '../../view_models/calendar_view_model.dart';
import 'add_event_dialog.dart';
import 'event_details_dialog.dart';
import 'tamil_timings_banner.dart';

class TimeGridView extends StatelessWidget {
  final CalendarViewModel viewModel;

  const TimeGridView({
    super.key,
    required this.viewModel,
  });

  static const double hourRowHeight = 56.0;
  static const int startHour = 1; // 1 AM
  static const int endHour = 24; // 24 hours scrollable

  @override
  Widget build(BuildContext context) {
    // 1. If "All my tasks" is selected in sidebar, display dedicated Tasks checklist view
    if (viewModel.selectedSection == 'all_tasks') {
      return _buildAllTasksView(context);
    }

    // 2. If Month view mode is active, display full interactive Month view
    if (viewModel.viewMode == CalendarViewMode.month) {
      return _buildMonthView(context);
    }

    // 3. Otherwise, display Day or Week grid
    final isDayView = viewModel.viewMode == CalendarViewMode.day;
    final displayDays = isDayView ? [viewModel.selectedDate] : viewModel.currentWeekDates;
    final selectedDate = viewModel.selectedDate;

    return Column(
      children: [
        // Tamil Panchangam Good & Bad Timings Banner
        if (viewModel.showTamilTimings)
          TamilTimingsBanner(viewModel: viewModel),

        // Week Days / Day Header Row
        _buildDaysHeader(displayDays, selectedDate),
        const Divider(height: 1, thickness: 1, color: AppColors.border),

        // All-Day Section
        if (viewModel.isAllDayExpanded)
          _buildAllDaySection(context, displayDays, selectedDate),
        const Divider(height: 1, thickness: 1, color: AppColors.border),

        // Hourly Scrollable Grid
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: (endHour - startHour) * hourRowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Hour Labels Gutter
                  _buildHourLabelsColumn(),
                  const VerticalDivider(width: 1, color: AppColors.border),

                  // Day Columns
                  for (int i = 0; i < displayDays.length; i++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: i < displayDays.length - 1
                                  ? AppColors.border
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        child: _buildDayColumn(context, displayDays[i], selectedDate),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- DAYS HEADER ---
  Widget _buildDaysHeader(List<DateTime> displayDays, DateTime selectedDate) {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs();
    final mins = offset.inMinutes.abs() % 60;
    final tzString = mins == 0 ? 'GMT$sign$hours' : 'GMT$sign$hours:${mins.toString().padLeft(2, '0')}';

    return Container(
      color: AppColors.surface,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic Local Timezone box
            SizedBox(
              width: 70,
              child: Center(
                child: Text(
                  tzString,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),

            // Day Headers
            for (int i = 0; i < displayDays.length; i++)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: i < displayDays.length - 1 ? AppColors.border : Colors.transparent,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => viewModel.selectDate(displayDays[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _buildDayHeaderCell(displayDays[i], selectedDate),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeaderCell(DateTime day, DateTime selectedDate) {
    final now = DateTime.now();
    final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
    final isSelected = day.year == selectedDate.year &&
        day.month == selectedDate.month &&
        day.day == selectedDate.day;

    final dayName = DateFormat('E').format(day).toUpperCase();
    final dayLabel = day.day == 1 ? DateFormat('MMM d').format(day).toUpperCase() : '${day.day}';
    final tamilDate = viewModel.getTamilDateFor(day);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isToday || isSelected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 3),
        if (isToday)
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          )
        else if (isSelected)
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 26,
            child: Center(
              child: Text(
                dayLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 3),
        // Tamil Calendar Date Pill (தமிழ் தேதி)
        Tooltip(
          message: tamilDate.fullTamilDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              tamilDate.shortTamilDate,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- ALL DAY SECTION ---
  Widget _buildAllDaySection(BuildContext context, List<DateTime> displayDays, DateTime selectedDate) {
    return Container(
      color: AppColors.surface,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "ALL DAY ^" Gutter
            SizedBox(
              width: 70,
              child: Tooltip(
                message: 'Toggle all-day events row',
                child: InkWell(
                  onTap: () => viewModel.toggleAllDayExpanded(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Column(
                      children: const [
                        Text(
                          'ALL DAY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up_rounded, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.border),

            // All Day Columns
            for (int i = 0; i < displayDays.length; i++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: i < displayDays.length - 1 ? AppColors.border : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in viewModel.getAllDayEventsForDay(displayDays[i]))
                        _buildAllDayItemChip(context, item),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDayItemChip(BuildContext context, EventItem item) {
    if (item.isHoliday || item.source == EventSource.tamilHoliday) {
      return InkWell(
        onTap: () => _showEventDetailsDialog(context, item),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.only(bottom: 3),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7), // Festive saffron/gold
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚩', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E), // Warm rich amber
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (item.isTask) {
      return Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => viewModel.toggleTaskCompletion(item.id),
              child: Icon(
                item.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 13,
                color: item.isCompleted ? AppColors.success : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: () => _showEventDetailsDialog(context, item),
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: item.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _showEventDetailsDialog(context, item),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: item.colorTheme.bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: item.colorTheme.borderColor, width: 0.8),
        ),
        child: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: item.colorTheme.textColor,
          ),
        ),
      ),
    );
  }

  // --- TIME LABELS GUTTER ---
  Widget _buildHourLabelsColumn() {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          for (int h = startHour; h < endHour; h++)
            SizedBox(
              height: hourRowHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatHourLabel(h),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatHourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  // --- DAY COLUMN & HOURLY SLOTS ---
  Widget _buildDayColumn(BuildContext context, DateTime day, DateTime selectedDate) {
    final dayEvents = viewModel.getTimeGridEventsForDay(day);
    final now = DateTime.now();
    final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
    final currentHourDecimal = now.hour + (now.minute / 60.0);
    final lineTop = (currentHourDecimal - startHour) * hourRowHeight;

    final timings = viewModel.getTamilTimingsFor(day);

    return Stack(
      children: [
        // Horizontal hour grid lines (CLICKABLE: click any slot to add an event at that hour!)
        Column(
          children: [
            for (int h = startHour; h < endHour; h++)
              InkWell(
                onTap: () {
                  final targetTime = DateTime(day.year, day.month, day.day, h, 0);
                  showDialog(
                    context: context,
                    builder: (ctx) => AddEventDialog(
                      viewModel: viewModel,
                      initialDate: targetTime,
                    ),
                  );
                },
                child: Container(
                  height: hourRowHeight,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Tamil Good & Bad Timings on the time grid
        if (viewModel.showTamilTimings) ...[
          _buildTamilTimeSlotIndicator(timings.nallaNeramMorning),
          _buildTamilTimeSlotIndicator(timings.nallaNeramEvening),
          _buildTamilTimeSlotIndicator(timings.rahuKalam),
          _buildTamilTimeSlotIndicator(timings.yamagandam),
        ],

        // Events positioned on the hourly grid
        for (final event in dayEvents)
          _buildPositionedEvent(context, event),

        // Current Time Red Indicator Line with circular dot (shown on today's column at the live current time)
        if (isToday && lineTop >= 0 && lineTop <= (endHour - startHour) * hourRowHeight)
          Positioned(
            top: lineTop,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.currentTimeLine,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: AppColors.currentTimeLine,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTamilTimeSlotIndicator(TamilTimeSlot slot) {
    final startDec = slot.startTime.hour + (slot.startTime.minute / 60.0);
    final endDec = slot.endTime.hour + (slot.endTime.minute / 60.0);
    final top = (startDec - startHour) * hourRowHeight;
    final height = (endDec - startDec) * hourRowHeight;

    if (top < 0 || height <= 0) return const SizedBox.shrink();

    return Positioned(
      top: top,
      height: height,
      left: 1,
      right: 1,
      child: Tooltip(
        message: '${slot.tamilLabel} (${slot.label})\n${slot.timeFormatted}',
        child: Container(
          decoration: BoxDecoration(
            color: slot.badgeColor.withValues(alpha: 0.35),
            border: Border(
              left: BorderSide(color: slot.textColor.withValues(alpha: 0.75), width: 3),
            ),
          ),
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: Text(
            '${slot.tamilLabel} • ${slot.timeFormatted}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: slot.textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedEvent(BuildContext context, EventItem event) {
    final startDecimal = event.startTime.hour + (event.startTime.minute / 60.0);
    final endDecimal = event.endTime.hour + (event.endTime.minute / 60.0);
    final top = (startDecimal - startHour) * hourRowHeight;
    final height = (endDecimal - startDecimal) * hourRowHeight;

    if (top < 0) return const SizedBox.shrink();

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      height: height.clamp(28.0, 400.0),
      child: InkWell(
        onTap: () => _showEventDetailsDialog(context, event),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: event.colorTheme.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: event.colorTheme.borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.isTask) ...[
                Row(
                  children: [
                    InkWell(
                      onTap: () => viewModel.toggleTaskCompletion(event.id),
                      child: Icon(
                        event.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                        size: 11,
                        color: event.isCompleted ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    if (event.callType == CallType.googleMeet) ...[
                      const Icon(Icons.videocam_rounded, size: 11, color: AppColors.googleRed),
                      const SizedBox(width: 3),
                    ] else if (event.callType == CallType.msTeams) ...[
                      const Icon(Icons.groups_rounded, size: 11, color: AppColors.teamsPurple),
                      const SizedBox(width: 3),
                    ],
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: height > 60 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: event.colorTheme.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (height > 40) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('h:mm').format(event.startTime)}-${DateFormat('h:mma').format(event.endTime).toLowerCase()}',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: event.colorTheme.textColor.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (event.callType.isCall && height > 70) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'via ${event.callType.displayName}',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: event.colorTheme.textColor,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- MONTH VIEW ---
  Widget _buildMonthView(BuildContext context) {
    final year = viewModel.selectedDate.year;
    final month = viewModel.selectedDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final prevMonthDays = DateTime(year, month, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Mon ... 7 = Sun

    final weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final totalSlots = ((startWeekday - 1 + daysInMonth + 6) ~/ 7) * 7;

    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Weekday Column Headers with clean alignment
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                for (int i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekDayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: i >= 5 ? AppColors.primary : AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Month Days Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: totalSlots > 35 ? 1.05 : 1.25,
              ),
              itemCount: totalSlots,
              itemBuilder: (context, index) {
                final dayOffset = index - (startWeekday - 1);
                final isCurrentMonth = dayOffset >= 0 && dayOffset < daysInMonth;

                DateTime thisDate;
                int displayDayNumber;

                if (dayOffset < 0) {
                  // Previous month day
                  displayDayNumber = prevMonthDays + dayOffset + 1;
                  thisDate = DateTime(year, month - 1, displayDayNumber);
                } else if (dayOffset >= daysInMonth) {
                  // Next month day
                  displayDayNumber = dayOffset - daysInMonth + 1;
                  thisDate = DateTime(year, month + 1, displayDayNumber);
                } else {
                  // Current month day
                  displayDayNumber = dayOffset + 1;
                  thisDate = DateTime(year, month, displayDayNumber);
                }

                final isToday = thisDate.year == now.year &&
                    thisDate.month == now.month &&
                    thisDate.day == now.day;
                final isSelected = thisDate.year == viewModel.selectedDate.year &&
                    thisDate.month == viewModel.selectedDate.month &&
                    thisDate.day == viewModel.selectedDate.day;

                final dayEvents = viewModel.getEventsForDay(thisDate);
                EventItem? holiday;
                for (final e in dayEvents) {
                  if (e.isHoliday || e.source == EventSource.tamilHoliday) {
                    holiday = e;
                    break;
                  }
                }
                final hasHoliday = holiday != null;

                return InkWell(
                  onTap: () {
                    viewModel.selectDate(thisDate);
                  },
                  onDoubleTap: () {
                    viewModel.selectDate(thisDate);
                    viewModel.setViewMode(CalendarViewMode.day);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySoft.withValues(alpha: 0.6)
                          : isCurrentMonth
                              ? AppColors.surface
                              : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.border,
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Number + Holiday / Today indicator: English date + Tamil Solar Date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : isSelected
                                        ? AppColors.primarySoft
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$displayDayNumber',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isToday
                                      ? Colors.white
                                      : !isCurrentMonth
                                          ? AppColors.textMuted.withValues(alpha: 0.5)
                                          : isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Tamil Solar Date indicator
                            Tooltip(
                              message: viewModel.getTamilDateFor(thisDate).fullTamilDate,
                              child: Builder(
                                builder: (context) {
                                  final tamilDate = viewModel.getTamilDateFor(thisDate);
                                  final isTamilMonthFirstDay = tamilDate.tamilDay == 1;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isTamilMonthFirstDay
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isTamilMonthFirstDay
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFFDE68A).withValues(alpha: 0.6),
                                        width: isTamilMonthFirstDay ? 1 : 0.6,
                                      ),
                                    ),
                                    child: Text(
                                      isTamilMonthFirstDay
                                          ? '${tamilDate.tamilMonth} 1'
                                          : '${tamilDate.tamilDay}',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: isTamilMonthFirstDay ? FontWeight.w800 : FontWeight.w600,
                                        color: isCurrentMonth
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFFB45309).withValues(alpha: 0.5),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Spacer(),
                            if (hasHoliday)
                              Tooltip(
                                message: holiday.title,
                                child: const Text('🚩', style: TextStyle(fontSize: 10)),
                              )
                            else if (viewModel.getTamilDateFor(thisDate).hasSpecialEvent)
                              Builder(
                                builder: (_) {
                                  final t = viewModel.getTamilDateFor(thisDate);
                                  if (t.isPournami) return const Tooltip(message: 'பௌர்ணமி (Pournami)', child: Text('⚪', style: TextStyle(fontSize: 9)));
                                  if (t.isAmavasya) return const Tooltip(message: 'அமாவாசை (Amavasya)', child: Text('⚫', style: TextStyle(fontSize: 9)));
                                  if (t.isSashti) return const Tooltip(message: 'சஷ்டி விரதம் (Sashti)', child: Text('🔱', style: TextStyle(fontSize: 10)));
                                  if (t.isEkadashi) return const Tooltip(message: 'ஏகாதசி (Ekadashi)', child: Text('🪷', style: TextStyle(fontSize: 10)));
                                  if (t.isPradosham) return const Tooltip(message: 'பிரதோஷம் (Pradosham)', child: Text('🕉️', style: TextStyle(fontSize: 10)));
                                  if (t.isKarthigai) return const Tooltip(message: 'கார்த்திகை (Karthigai)', child: Text('🪔', style: TextStyle(fontSize: 10)));
                                  return const SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Interactive Event pills inside the month cell
                        Expanded(
                          child: ClipRect(
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                for (final ev in dayEvents.take(2))
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.5),
                                    child: InkWell(
                                      onTap: () => _showEventDetailsDialog(context, ev),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: ev.colorTheme.bgColor,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: ev.colorTheme.borderColor,
                                            width: 0.7,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (ev.isHoliday || ev.source == EventSource.tamilHoliday)
                                              const Padding(
                                                padding: EdgeInsets.only(right: 2),
                                                child: Text('•', style: TextStyle(fontSize: 8, color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                                              )
                                            else if (ev.callType.isCall)
                                              const Padding(
                                                padding: EdgeInsets.only(right: 3),
                                                child: Icon(Icons.videocam_rounded, size: 8.5, color: AppColors.primary),
                                              ),
                                            Expanded(
                                              child: Text(
                                                ev.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: ev.colorTheme.textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (dayEvents.length > 2)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, top: 1),
                                    child: Text(
                                      '+${dayEvents.length - 2} more',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ALL TASKS VIEW ---
  Widget _buildAllTasksView(BuildContext context) {
    final tasks = viewModel.allTasks;
    final completedCount = tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checklist_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All My Tasks & Action Items',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${tasks.length} tasks completed',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: tasks.isEmpty ? 0 : completedCount / tasks.length,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AddEventDialog(
                        viewModel: viewModel,
                        initialDate: DateTime.now(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tasks List
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No tasks found for the current filter.',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            for (final task in tasks)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: task.isCompleted ? AppColors.success : AppColors.textMuted,
                      size: 22,
                    ),
                    onPressed: () => viewModel.toggleTaskCompletion(task.id),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${DateFormat('EEE, MMM d').format(task.startTime)} • ${task.source.displayName}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.colorTheme.bgColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: task.colorTheme.borderColor),
                        ),
                        child: Text(
                          task.priority.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: task.colorTheme.textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                        tooltip: 'Delete task',
                        onPressed: () => viewModel.deleteEvent(task.id),
                      ),
                    ],
                  ),
                  onTap: () => _showEventDetailsDialog(context, task),
                ),
              ),
        ],
      ),
    );
  }

  // --- EVENT DETAILS DIALOG ---
  void _showEventDetailsDialog(BuildContext context, EventItem event) {
    EventDetailsDialog.show(context, event, viewModel);
  }
}
