import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/event_item.dart';
import '../../data/models/tamil_daily_timings.dart';
import '../view_models/calendar_view_model.dart';
import 'widgets/add_event_dialog.dart';
import 'widgets/event_details_dialog.dart';

/// Authentic Traditional Tamil Calendar View (தமிழ் நாட்காட்டி)
/// Faithful implementation of both:
/// 1. Daily Sheet (தினம்) matching Image 1
/// 2. Monthly Sheet (மாதம்) with Legend and Festivals matching Image 2
class TamilCalendarView extends StatefulWidget {
  final CalendarViewModel calendarViewModel;

  const TamilCalendarView({
    super.key,
    required this.calendarViewModel,
  });

  @override
  State<TamilCalendarView> createState() => _TamilCalendarViewState();
}

class _TamilCalendarViewState extends State<TamilCalendarView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _tamilOrange = Color(0xFFE65100); // Traditional Deep Orange
  static const Color _tamilAmber = Color(0xFFEA580C);
  static const Color _tamilHeaderBg = Color(0xFFE65100);

  bool _useWallCalendar = true; // Default to authentic Wall Calendar sheet matching user screenshot

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousDay() {
    final cur = widget.calendarViewModel.selectedDate;
    widget.calendarViewModel.selectDate(cur.subtract(const Duration(days: 1)));
  }

  void _nextDay() {
    final cur = widget.calendarViewModel.selectedDate;
    widget.calendarViewModel.selectDate(cur.add(const Duration(days: 1)));
  }

  void _previousMonth() {
    final cur = widget.calendarViewModel.selectedDate;
    widget.calendarViewModel.selectDate(DateTime(cur.year, cur.month - 1, 1));
  }

  void _nextMonth() {
    final cur = widget.calendarViewModel.selectedDate;
    widget.calendarViewModel.selectDate(DateTime(cur.year, cur.month + 1, 1));
  }

  Future<void> _showMonthPicker(BuildContext context, DateTime currentDate) async {
    int selectedYear = currentDate.year;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: _tamilOrange),
                    onPressed: () {
                      setDialogState(() {
                        selectedYear--;
                      });
                    },
                  ),
                  Text(
                    '$selectedYear',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: _tamilOrange),
                    onPressed: () {
                      setDialogState(() {
                        selectedYear++;
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Buttons: Today vs Jan 2027 Sample
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _tamilOrange,
                              side: const BorderSide(color: _tamilOrange),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              final now = DateTime.now();
                              widget.calendarViewModel.selectDate(now);
                              Navigator.pop(ctx);
                            },
                            child: const Text('இன்று (Today)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              widget.calendarViewModel.selectDate(DateTime(2027, 1, 15));
                              Navigator.pop(ctx);
                            },
                            child: const Text('மாதிரி (Jan 2027)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 12 Months Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, i) {
                        final m = i + 1;
                        final isSel = selectedYear == currentDate.year && m == currentDate.month;
                        final tamilM = _getTamilGregorianMonth(m);
                        final engM = DateFormat('MMM').format(DateTime(2024, m, 1));

                        return InkWell(
                          onTap: () {
                            widget.calendarViewModel.selectDate(DateTime(selectedYear, m, 1));
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSel ? _tamilOrange : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? _tamilOrange : const Color(0xFFE2E8F0),
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    tamilM,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isSel ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    engM,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSel ? Colors.white70 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.calendarViewModel,
      builder: (context, _) {
        final selectedDate = widget.calendarViewModel.selectedDate;
        final tamilTimings = widget.calendarViewModel.getTamilTimingsFor(selectedDate);
        final tamilDate = widget.calendarViewModel.getTamilDateFor(selectedDate);

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Column(
            children: [
              // Top Orange App Bar matching Image 1 & 2 ("நாட்காட்டி")
              _buildTopBar(context),

              // Navigation & Tabs
              _buildSubHeaderAndTabs(context, selectedDate),

              // Content Body (Daily Sheet / Month Grid / Horai)
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: தினம் (Daily Tamil Sheet - Image 1)
                    _buildDailySheet(context, selectedDate, tamilTimings, tamilDate),

                    // Tab 2: மாதம் (Monthly Calendar Grid - Image 2 & 3)
                    _buildMonthlyGrid(context, selectedDate),

                    // Tab 3: ஹோரை (Horai / Planetary Hours)
                    _buildHoraiView(context, selectedDate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TOP BAR ("நாட்காட்டி") ---
  Widget _buildTopBar(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      color: _tamilHeaderBg,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text(
              'நாட்காட்டி',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Tamil Calendar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const Spacer(),

            // Preset sample button - hide label on mobile
            if (!isMobile)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
                onPressed: () {
                  widget.calendarViewModel.selectDate(DateTime(2027, 1, 15));
                  _tabController.animateTo(1);
                },
                child: const Text('மாதிரி (Jan 2027)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            if (!isMobile) const SizedBox(width: 8),

            // Today button
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _tamilOrange,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
              ),
              onPressed: () => widget.calendarViewModel.goToToday(),
              child: Text(
                isMobile ? 'இன்று' : 'இன்று (Today)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 6),

            // Back to Standard Workspace button
            IconButton(
              icon: const Icon(Icons.view_agenda_outlined, color: Colors.white, size: 20),
              tooltip: 'Switch to Standard Calendar View',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => widget.calendarViewModel.setActiveNavIndex(0),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUBHEADER & TABS BAR ---
  Widget _buildSubHeaderAndTabs(BuildContext context, DateTime selectedDate) {
    final isMonthTab = _tabController.index == 1;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    final selectedTamil = widget.calendarViewModel.getTamilDateFor(selectedDate);
    final firstDayTamil = widget.calendarViewModel.getTamilDateFor(DateTime(selectedDate.year, selectedDate.month, 1));
    final lastDayTamil = widget.calendarViewModel.getTamilDateFor(DateTime(selectedDate.year, selectedDate.month + 1, 0));

    // Shorter title on mobile
    final titleText = isMonthTab
        ? (isMobile
            ? '${_getTamilGregorianMonth(selectedDate.month)} ${selectedDate.year}'
            : '${_getTamilGregorianMonth(selectedDate.month)} ${selectedDate.year} (${DateFormat('MMMM yyyy').format(selectedDate)})')
        : (isMobile
            ? DateFormat('EEE, d MMM').format(selectedDate)
            : DateFormat('EEE, MMM d, yyyy').format(selectedDate));

    final subtitleBadge = isMonthTab
        ? '${firstDayTamil.tamilMonth} - ${lastDayTamil.tamilMonth} • ${firstDayTamil.tamilYear} வருடம்'
        : 'இன்று திதி: ${selectedTamil.tithi}';

    return Container(
      decoration: const BoxDecoration(
        color: _tamilAmber,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Switcher Row
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 4 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: isMonthTab ? 'Previous Month' : 'Previous Day',
                  onPressed: () {
                    if (isMonthTab) {
                      _previousMonth();
                    } else {
                      _previousDay();
                    }
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (isMonthTab) {
                        await _showMonthPicker(context, selectedDate);
                      } else {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          widget.calendarViewModel.selectDate(picked);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_note_rounded, color: Colors.white, size: isMobile ? 16 : 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  titleText,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 20),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              subtitleBadge,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: isMonthTab ? 'Next Month' : 'Next Day',
                  onPressed: () {
                    if (isMonthTab) {
                      _nextMonth();
                    } else {
                      _nextDay();
                    }
                  },
                ),
              ],
            ),
          ),

          // Tabs: தினம் | மாதம் | ஹோரை
          Container(
            color: const Color(0xFF475569),
            child: TabBar(
              controller: _tabController,
              indicatorColor: _tamilOrange,
              indicatorWeight: 3.5,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: isMobile ? 'தினம்' : 'தினம் (Daily)'),
                Tab(text: isMobile ? 'மாதம்' : 'மாதம் (Monthly)'),
                Tab(text: isMobile ? 'ஹோரை' : 'ஹோரை (Horai)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: தினம் (DAILY SHEET - MATCHING IMAGE 1)
  // ===========================================================================
  Widget _buildDailySheet(
    BuildContext context,
    DateTime date,
    TamilDailyTimings timings,
    TamilDate tamilDate,
  ) {
    final dayEvents = widget.calendarViewModel.getEventsForDay(date);
    final dayHolidays = dayEvents.where((e) => e.isHoliday || e.source == EventSource.tamilHoliday).toList();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final hPad = isMobile ? 10.0 : 16.0;
    final maxW = isMobile ? double.infinity : 580.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Traditional Calendar Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row: Year, Month | Big Day Number | Weekday, Gregorian Month
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left column: Tamil Year & Tamil Month
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tamilDate.tamilYear,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tamilDate.tamilMonth,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _tamilOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center: Orange rounded box with Tamil day number
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: _tamilOrange,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _tamilOrange.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${tamilDate.tamilDay}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Right column: Weekday & English Month
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timings.tamilDayName.replaceAll('க்கிழமை', ''),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getTamilGregorianMonth(date.month),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Deity / Sacred Icons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text('🐂', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text('🕉️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text('🔱', style: TextStyle(fontSize: 18)),
                          const Spacer(),
                          if (dayHolidays.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Text(
                                '🎉 விடுமுறை: ${_getDisplayFestivalTitle(dayHolidays.first.title)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ] else if (date.weekday == DateTime.sunday) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: const Text(
                                '🔴 வார விடுமுறை (Sunday)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (tamilDate.hasSpecialEvent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                tamilDate.isPournami
                                    ? '⚪ பௌர்ணமி'
                                    : tamilDate.isAmavasya
                                        ? '⚫ அமாவாசை'
                                        : tamilDate.isSashti
                                            ? '🔱 சஷ்டி விரதம்'
                                            : tamilDate.isEkadashi
                                                ? '🪷 ஏகாதசி'
                                                : tamilDate.isPradosham
                                                    ? '🕉️ பிரதோஷம்'
                                                    : tamilDate.isKarthigai
                                                        ? '🪔 கார்த்திகை'
                                                        : tamilDate.festival ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Panchangam Details: நட், திதி, கர, யோ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
                          _buildPanchangamRow('நட்', '${tamilDate.nakshatram} ${tamilDate.nakshatramTime}'),
                          const SizedBox(height: 6),
                          _buildPanchangamRow('திதி', '${tamilDate.tithi} ${tamilDate.tithiTime}'),
                          const SizedBox(height: 6),
                          _buildPanchangamRow('கர', tamilDate.karanam),
                          const SizedBox(height: 6),
                          _buildPanchangamRow('யோ', tamilDate.yogam),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Inauspicious & Auspicious Timings Cards (Matching Image 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card 1 (Left): ராகு, எம, குளி
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                children: [
                                  _buildTimingLine('ராகு', timings.rahuKalam.timeFormatted),
                                  const SizedBox(height: 6),
                                  _buildTimingLine('எம', timings.yamagandam.timeFormatted),
                                  const SizedBox(height: 6),
                                  _buildTimingLine('குளி', timings.kuligai.timeFormatted),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Card 2 (Right): கௌரி ந.நேரம் (கா, மா)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(9),
                                        topRight: Radius.circular(9),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'கௌரி ந.நேரம்',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        _buildTimingLine('கா', timings.gowriNallaNeramMorning.timeFormatted),
                                        const SizedBox(height: 6),
                                        _buildTimingLine('மா', timings.gowriNallaNeramEvening.timeFormatted),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bottom Bar: சந்திராஷ்டமம் & சூலம் / பரிகாரம்
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                children: [
                                  const TextSpan(
                                    text: 'சந்திராஷ்டமம்: ',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  TextSpan(
                                    text: tamilDate.chandrashtamam,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: _tamilOrange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                children: [
                                  const TextSpan(
                                    text: 'சூல ',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  TextSpan(
                                    text: '${tamilDate.soolam} (${tamilDate.pariharam})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Events Scheduled on this Day
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Events on this Day (${dayEvents.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddEventDialog(
                          viewModel: widget.calendarViewModel,
                          initialDate: date,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Event'),
                    style: TextButton.styleFrom(foregroundColor: _tamilOrange),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (dayEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      'No events scheduled for this day',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ...dayEvents.map(
                  (ev) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ev.colorTheme.borderColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ev.colorTheme.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ev.isHoliday
                              ? Icons.celebration_rounded
                              : ev.callType.isCall
                                  ? Icons.videocam_rounded
                                  : Icons.event_rounded,
                          size: 20,
                          color: ev.colorTheme.textColor,
                        ),
                      ),
                      title: Text(
                        ev.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      subtitle: Text(
                        ev.isAllDay ? 'All Day' : '${DateFormat('h:mm a').format(ev.startTime)} - ${DateFormat('h:mm a').format(ev.endTime)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => EventDetailsDialog.show(context, ev, widget.calendarViewModel),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanchangamRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingLine(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: மாதம் (AUTHENTIC TAMIL MONTHLY WALL CALENDAR - மாத காலண்டர்)
  // ===========================================================================
  Widget _buildMonthlyGrid(BuildContext context, DateTime selectedDate) {
    final year = selectedDate.year;
    final month = selectedDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final totalDaysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final hPad = isMobile ? 6.0 : 16.0;

    final startTamil = widget.calendarViewModel.getTamilDateFor(firstDayOfMonth);
    final endTamil = widget.calendarViewModel.getTamilDateFor(lastDayOfMonth);

    final holidaysInMonth = widget.calendarViewModel.allEvents
        .where((e) =>
            (e.isHoliday || e.source == EventSource.tamilHoliday) &&
            e.startTime.month == month &&
            e.startTime.year == year)
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top View Mode Toggle & Navigation Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // View Toggle full-width on mobile
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildViewToggleButton(
                                    label: 'மாத காலண்டர்',
                                    icon: Icons.calendar_view_month_rounded,
                                    isActive: _useWallCalendar,
                                    onTap: () => setState(() => _useWallCalendar = true),
                                  ),
                                ),
                                Expanded(
                                  child: _buildViewToggleButton(
                                    label: 'நவீன கட்டம்',
                                    icon: Icons.grid_view_rounded,
                                    isActive: !_useWallCalendar,
                                    onTap: () => setState(() => _useWallCalendar = false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Navigation buttons row on mobile
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _tamilOrange,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                                tooltip: 'முந்தைய மாதம்',
                                onPressed: _previousMonth,
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _tamilOrange,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                tooltip: 'அடுத்த மாதம்',
                                onPressed: _nextMonth,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // View Toggle
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildViewToggleButton(
                                  label: 'மாத காலண்டர் (Wall Sheet)',
                                  icon: Icons.calendar_view_month_rounded,
                                  isActive: _useWallCalendar,
                                  onTap: () => setState(() => _useWallCalendar = true),
                                ),
                                _buildViewToggleButton(
                                  label: 'நவீன கட்டம் (Modern Grid)',
                                  icon: Icons.grid_view_rounded,
                                  isActive: !_useWallCalendar,
                                  onTap: () => setState(() => _useWallCalendar = false),
                                ),
                              ],
                            ),
                          ),
                          // Navigation buttons
                          Row(
                            children: [
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _tamilOrange,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                                tooltip: 'முந்தைய மாதம் (Previous Month)',
                                onPressed: _previousMonth,
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _tamilOrange,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                tooltip: 'அடுத்த மாதம் (Next Month)',
                                onPressed: _nextMonth,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              // Calendar Body: Wall Calendar Sheet or Modern Grid
              if (_useWallCalendar)
                _buildWallCalendarSheet(
                  context,
                  selectedDate,
                  year,
                  month,
                  totalDaysInMonth,
                  startWeekday,
                  holidaysInMonth,
                  startTamil,
                  endTamil,
                )
              else
                _buildModernCalendarGrid(
                  context,
                  selectedDate,
                  year,
                  month,
                  totalDaysInMonth,
                  startWeekday,
                  holidaysInMonth,
                  startTamil,
                  endTamil,
                ),

              const SizedBox(height: 16),

              // Monthly Special Information Section (Always visible below)
              _buildMonthlyDetailedInfoPanels(year, month, holidaysInMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _tamilOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. AUTHENTIC TAMIL MONTHLY WALL CALENDAR SHEET (MATCHING USER SCREENSHOT)
  // ===========================================================================
  Widget _buildWallCalendarSheet(
    BuildContext context,
    DateTime selectedDate,
    int year,
    int month,
    int totalDaysInMonth,
    int startWeekday,
    List<EventItem> holidaysInMonth,
    TamilDate startTamil,
    TamilDate endTamil,
  ) {
    final tamilMonthTitle = _getTamilGregorianMonth(month);
    final englishMonthTitle = DateFormat('MMMM').format(selectedDate).toUpperCase();
    final tamilSeason = '${startTamil.tamilMonth} - ${endTamil.tamilMonth}';
    final tamilYear = '${startTamil.tamilYear} வருடம்';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706), width: isMobile ? 2 : 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- TOP YELLOW BANNER ---
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFDE00),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFDC2626), width: 2.5),
              ),
            ),
            child: Column(
              children: [
                // Top Row: Mandala | Tamil Month, English Month, Year | Mandala
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isMobile) _buildMandalaOrnament(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              tamilMonthTitle,
                              style: TextStyle(
                                fontSize: isMobile ? 26 : 40,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFDC2626),
                                letterSpacing: 1.0,
                                shadows: const [
                                  Shadow(color: Colors.white, offset: Offset(1.5, 1.5), blurRadius: 2),
                                ],
                              ),
                            ),
                            SizedBox(width: isMobile ? 10 : 24),
                            Text(
                              englishMonthTitle,
                              style: TextStyle(
                                fontSize: isMobile ? 22 : 36,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E3A8A),
                                letterSpacing: isMobile ? 1.5 : 3.0,
                              ),
                            ),
                            SizedBox(width: isMobile ? 10 : 24),
                            Text(
                              '$year',
                              style: TextStyle(
                                fontSize: isMobile ? 28 : 44,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0284C7),
                                letterSpacing: isMobile ? 1.0 : 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isMobile) _buildMandalaOrnament(),
                  ],
                ),
                const SizedBox(height: 6),

                // Sub-Banner Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEAB308), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tamilSeason,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                      Text(
                        '+',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                      Text(
                        tamilYear,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN 7-ROW CALENDAR GRID WITH 5 WEEK COLUMNS ---
          LayoutBuilder(
            builder: (context, constraints) {
              // On mobile, minimum width for scrolling; on desktop, fill available width
              final minTableWidth = isMobile ? 680.0 : 980.0;
              final tableWidth = constraints.maxWidth >= minTableWidth ? constraints.maxWidth : minTableWidth;

              // Precompute 7x5 cell grid
              final cellDayGrid = List.generate(7, (_) => List<int?>.filled(5, null));
              for (int d = 1; d <= totalDaysInMonth; d++) {
                final row = (startWeekday + d - 1) % 7;
                final week = (startWeekday + d - 1) ~/ 7;
                if (week < 5) {
                  cellDayGrid[row][week] = d;
                } else {
                  cellDayGrid[row][0] = d;
                }
              }

              // Collect empty slots in column 0 for Information Boxes
              final col0EmptyRows = <int>[];
              for (int r = 0; r < 7; r++) {
                if (cellDayGrid[r][0] == null) {
                  col0EmptyRows.add(r);
                }
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      for (int rowIndex = 0; rowIndex < 7; rowIndex++)
                        _buildWallCalendarRow(
                          context: context,
                          rowIndex: rowIndex,
                          rowDays: cellDayGrid[rowIndex],
                          col0EmptyRows: col0EmptyRows,
                          selectedDate: selectedDate,
                          year: year,
                          month: month,
                          totalDaysInMonth: totalDaysInMonth,
                          startWeekday: startWeekday,
                          holidaysInMonth: holidaysInMonth,
                        ),

                      // Bottom 12-Rasi Chandrashtamam Bar
                      _buildWallCalendarChandrashtamamBar(year, month),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMandalaOrnament() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFDC2626), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD97706), width: 2),
          ),
          child: const Center(
            child: Text('☸️', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }

  // Row of 7 weekdays
  Widget _buildWallCalendarRow({
    required BuildContext context,
    required int rowIndex,
    required List<int?> rowDays,
    required List<int> col0EmptyRows,
    required DateTime selectedDate,
    required int year,
    required int month,
    required int totalDaysInMonth,
    required int startWeekday,
    required List<EventItem> holidaysInMonth,
  }) {
    // Weekday Row Info - Only Sunday is regular weekly leave day
    final weekdayNames = [
      {'en': 'SUN', 'ta': 'ஞாயிறு', 'isRed': true},
      {'en': 'MON', 'ta': 'திங்கள்', 'isRed': false},
      {'en': 'TUE', 'ta': 'செவ்வாய்', 'isRed': false},
      {'en': 'WED', 'ta': 'புதன்', 'isRed': false},
      {'en': 'THU', 'ta': 'வியாழன்', 'isRed': false},
      {'en': 'FRI', 'ta': 'வெள்ளி', 'isRed': false},
      {'en': 'SAT', 'ta': 'சனி', 'isRed': false},
    ];

    final rowInfo = weekdayNames[rowIndex];
    final isSunday = rowIndex == 0;
    final isSaturday = rowIndex == 6;

    return Container(
      height: 108,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Weekday Column (SUN/ஞாயிறு)
          Container(
            width: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                right: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rowInfo['en'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: (rowInfo['isRed'] as bool)
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1E3A8A),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rowInfo['ta'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: (rowInfo['isRed'] as bool)
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5 Week Columns for this weekday
          for (int colIndex = 0; colIndex < 5; colIndex++)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: colIndex < 4 ? const Color(0xFFCBD5E1) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildWallCalendarCell(
                  context,
                  rowIndex: rowIndex,
                  colIndex: colIndex,
                  actualDay: rowDays[colIndex],
                  col0EmptyRows: col0EmptyRows,
                  selectedDate: selectedDate,
                  year: year,
                  month: month,
                  totalDaysInMonth: totalDaysInMonth,
                  startWeekday: startWeekday,
                  holidaysInMonth: holidaysInMonth,
                  isSunday: isSunday,
                  isSaturday: isSaturday,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Inside each of the 5 cells for a given weekday row
  Widget _buildWallCalendarCell(
    BuildContext context, {
    required int rowIndex,
    required int colIndex,
    required int? actualDay,
    required List<int> col0EmptyRows,
    required DateTime selectedDate,
    required int year,
    required int month,
    required int totalDaysInMonth,
    required int startWeekday,
    required List<EventItem> holidaysInMonth,
    required bool isSunday,
    required bool isSaturday,
  }) {
    // 1. If it is NOT a day cell, check if it renders an Information Box in Column 0
    if (actualDay == null) {
      if (colIndex == 0) {
        final boxSlot = col0EmptyRows.indexOf(rowIndex);
        if (boxSlot != -1) {
          return _buildInformationBox(boxSlot, year, month, holidaysInMonth);
        }
      }
      return Container(color: const Color(0xFFFAFAFA));
    }

    // 2. Active Day Cell
    final cellDate = DateTime(year, month, actualDay);
    final isSelected = cellDate.year == selectedDate.year &&
        cellDate.month == selectedDate.month &&
        cellDate.day == selectedDate.day;

    final now = DateTime.now();
    final isToday = cellDate.year == now.year &&
        cellDate.month == now.month &&
        cellDate.day == now.day;

    final tamilDate = widget.calendarViewModel.getTamilDateFor(cellDate);

    // Check holiday on this day
    EventItem? holiday;
    for (final h in holidaysInMonth) {
      if (h.startTime.day == actualDay) {
        holiday = h;
        break;
      }
    }
    final isHoliday = holiday != null || isSunday;

    // Authentic annotations if viewing January 2027 (User Screenshot)
    final janData = (year == 2027 && month == 1) ? _getJan2027DayData(actualDay) : null;

    Color numberColor;
    if (janData?['isRed'] == true || isHoliday) {
      numberColor = const Color(0xFFDC2626); // Bright Red (Weekly Holiday: Sunday or Gazetted Public Leave Day)
    } else if (isSaturday) {
      numberColor = const Color(0xFF0284C7); // Cyan Blue
    } else {
      numberColor = const Color(0xFF1E293B); // Dark Navy Blue (Regular Working Weekdays: Mon-Fri)
    }

    final displayTithi = janData?['tithi'] as String? ?? _getDisplayTithiOrVratam(tamilDate, holiday);
    final displayTiming = janData?['timing'] as String? ?? (_hasTimingNote(tamilDate, actualDay) ? _getTimingNote(tamilDate, actualDay) : null);
    final displaySub = janData?['sub'] as String? ?? (holiday != null ? _getDisplayFestivalTitle(holiday.title) : null);
    final displayTamil = janData?['tamil'] as String? ?? (tamilDate.tamilDay == 1 ? '${tamilDate.tamilMonth} 1' : '${tamilDate.tamilDay}');
    final deityIcon = janData?['icon'] as String? ?? _buildSacredDeityClipString(tamilDate, actualDay);

    return InkWell(
      onTap: () {
        widget.calendarViewModel.selectDate(cellDate);
      },
      onDoubleTap: () {
        widget.calendarViewModel.selectDate(cellDate);
        _tabController.animateTo(0); // Switch to daily sheet
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFFBEB)
              : isToday
                  ? const Color(0xFFFEF3C7).withValues(alpha: 0.5)
                  : Colors.white,
          border: isSelected
              ? Border.all(color: _tamilOrange, width: 2)
              : isToday
                  ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
                  : null,
        ),
        child: Stack(
          children: [
            // Top Row: Tithi / Vratam + Deity Icon
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          displayTithi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _getVratamTextColor(tamilDate, holiday),
                          ),
                        ),
                      ),
                      if (deityIcon.isNotEmpty)
                        Text(deityIcon, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (displayTiming != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        displayTiming,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Giant Bold English Number in the Center
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$actualDay',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: numberColor,
                    height: 1.0,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),

            // Bottom Left: Special Festival / Occasion Label
            if (displaySub != null && displaySub.isNotEmpty)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    displaySub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),

            // Bottom Right Corner: Tamil Solar Date (e.g. "மார்கழி 17" or "தை 1")
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                displayTamil,
                style: TextStyle(
                  fontSize: displayTamil.contains(' ') ? 10.5 : 12.5,
                  fontWeight: FontWeight.w900,
                  color: displayTamil.contains(' ') || displayTamil == '1' || janData?['isRed'] == true
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4 SPECIAL INFORMATION BOXES (FOR EMPTY SLOTS IN COL 0) ---
  Widget _buildInformationBox(int boxSlot, int year, int month, List<EventItem> holidays) {
    if (year == 2027 && month == 1) {
      return _buildJan2027InfoBox(boxSlot);
    }

    switch (boxSlot) {
      case 0: // Box 1: அரசினர் விடுமுறை நாட்கள் (Govt Holidays)
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'அரசினர் விடுமுறை நாட்கள்',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: holidays.isEmpty
                    ? const Text('பொது விடுமுறை இல்லை', style: TextStyle(fontSize: 8, color: Colors.grey))
                    : ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: holidays.take(5).map((h) {
                          final clean = h.title.split('(').first.trim();
                          return Text(
                            '${h.startTime.day}. $clean',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );

      case 1: // Box 2: இந்துக்கள் பண்டிகை (Hindu Festivals)
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'இந்துக்கள் பண்டிகை',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 3),
              Text('• சங்கடஹர சதுர்த்தி', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              Text('• பிரதோஷம் & சிவராத்திரி', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              Text('• சஷ்டி விரதம்', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              Text('• திருவோண விரதம்', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        );

      case 2: // Box 3: கிறிஸ்துவ பண்டிகை & விரத தினங்கள், கரி நாட்கள்
        final kariDays = _getKariNaatkal(month).take(5).join(', ');
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'முக்கிய விரத & கரி நாட்கள்',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 3),
              const Text('• முக்கிய விரத தினங்கள்:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
              const Text('ஏகாதசி, பிரதோஷம், பௌர்ணமி', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold)),
              const Text('• கரி நாட்கள்:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
              Text(kariDays, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
            ],
          ),
        );

      case 3: // Box 4: சுபமுகூர்த்த நாட்கள் & வாஸ்து நாள்
      default:
        final muhurthams = widget.calendarViewModel.getMuhurthamDatesForMonth(year, month);
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'சுபமுகூர்த்த நாட்கள்',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                muhurthams.take(6).join(', '),
                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
              ),
              const Text('வளர்பிறை முகூர்த்தம்', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
              const Text('வாஸ்து நாள்:', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
              const Text('காலை 10.41 - 11.17 வரை', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold)),
            ],
          ),
        );
    }
  }

  // Authentic Information Boxes for January 2027 matching Image 3
  Widget _buildJan2027InfoBox(int boxSlot) {
    switch (boxSlot) {
      case 0:
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'அரசினர் விடுமுறை நாட்கள்',
                style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), decoration: TextDecoration.underline),
              ),
              SizedBox(height: 1),
              Text('1. ஆங்கிலப் புத்தாண்டு', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('15. தைப் பொங்கல்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('16. மாட்டுப் பொங்கல்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('16. திருவள்ளுவர் தினம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('17. உழவர் திருநாள்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('22. தைப்பூசம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('26. குடியரசு தினம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('9, 23 - வங்கிக்கு மட்டும் விடுமுறை', style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            ],
          ),
        );
      case 1:
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'இந்துக்கள் பண்டிகை',
                style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), decoration: TextDecoration.underline),
              ),
              SizedBox(height: 1),
              Text('7. ஸ்ரீஹனுமன் ஜெயந்தி', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('11. சங்கடஹர சதுர்த்தி', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('14. போகிப் பண்டிகை', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('15. தைப் பொங்கல்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('16. மாட்டுப் பொங்கல்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('16. திருவள்ளுவர் தினம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('17. உழவர் திருநாள்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text('22. தைப்பூசம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case 2:
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'கிறிஸ்துவ பண்டிகை',
                style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
              ),
              Text('1. ஆங்கிலப் புத்தாண்டு', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
              Text(
                'முக்கிய விரத தினங்கள்',
                style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
              ),
              Text('3, 5, 6, 7, 9, 13, 17, 18, 20, 21, 22, 25, 26', style: TextStyle(fontSize: 6.8, fontWeight: FontWeight.bold)),
              Text(
                'கரி நாட்கள்',
                style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
              ),
              Text('15, 16, 17, 25, 31', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
            ],
          ),
        );
      case 3:
      default:
        return Container(
          color: const Color(0xFFFFFBEB),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'சுபமுகூர்த்த நாட்கள்',
                style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), decoration: TextDecoration.underline),
              ),
              SizedBox(height: 1),
              Text('4, 10, 11, 14, 20, 28, 29', style: TextStyle(fontSize: 8.0, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A))),
              Text('வளர்பிறை முகூர்த்தம்', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
              Text('வாஸ்து நாள்', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
              Text('26-1-2027 • காலை 10.41-11.17 வரை', style: TextStyle(fontSize: 6.8, fontWeight: FontWeight.bold)),
            ],
          ),
        );
    }
  }

  // Authentic Jan 2027 day cell annotations matching Image 3
  Map<String, dynamic>? _getJan2027DayData(int day) {
    const data = {
      1: {'tithi': 'நவமி', 'sub': 'Happy New Year 2027', 'tamil': 'மார்கழி 17', 'icon': '🎉', 'isRed': true}, // Friday New Year Holiday
      2: {'tamil': '18'},
      3: {'tithi': 'ஏகாதசி', 'timing': 'நேற்று மாலை 6.35 முதல் இன்று இரவு 7.28 வரை', 'icon': '🪷', 'tamil': '19', 'isRed': true}, // Sunday
      4: {'tamil': '20'},
      5: {'tithi': 'பிரதோஷம்', 'icon': '🐂', 'tamil': '21'},
      6: {'tithi': 'சிவராத்திரி', 'icon': '🕉️', 'tamil': '22'},
      7: {'tithi': 'அமாவாசை ⚫', 'timing': 'நேற்று இரவு 12.35 முதல் இன்று இரவு 2.42 வரை', 'tamil': '23'},
      8: {'tamil': '24'}, // Friday (Regular working day, NOT leave!)
      9: {'tithi': 'சந்திர தரிசனம்', 'icon': '🌙', 'tamil': '25', 'isRed': true}, // 2nd Saturday (Bank Leave)
      10: {'tithi': 'சதுர்த்தி', 'tamil': '26', 'isRed': true}, // Sunday
      11: {'tithi': 'சதுர்த்தி', 'timing': 'இன்று காலை 8.18 முதல் நாளை காலை 9.23 வரை', 'tamil': '27'},
      12: {'tithi': 'பஞ்சமி', 'timing': 'இன்று காலை 9.24 முதல் நாளை காலை 10.02 வரை', 'tamil': '28'},
      13: {'tithi': 'சஷ்டி விரதம்', 'timing': 'இன்று காலை 10.03 முதல் நாளை காலை 10.08 வரை', 'icon': '🔱', 'tamil': '29'},
      14: {'tithi': 'போகிப் பண்டிகை', 'sub': 'போகிப் பண்டிகை', 'tamil': '30'},
      15: {'tithi': 'அஷ்டமி', 'timing': 'இன்று காலை 9.44 முதல் நாளை காலை 8.48 வரை', 'sub': 'தை திருநாள்', 'tamil': 'தை 1', 'isRed': true}, // Friday Pongal Holiday
      16: {'tithi': 'நவமி', 'sub': 'திருவள்ளுவர் தினம்', 'tamil': '2', 'isRed': true}, // Saturday Mattu Pongal Holiday
      17: {'sub': 'உழவர் திருநாள்', 'tamil': '3', 'isRed': true}, // Sunday Uzhavar Thirunal Holiday
      18: {'tithi': 'கார்த்திகை ★', 'timing': 'இன்று அதிகாலை 5.01 முதல் இன்று இரவு 3.59 வரை', 'icon': '🪔', 'tamil': '4'},
      19: {'tamil': '5'},
      20: {'tithi': 'பிரதோஷம்', 'icon': '🐂', 'tamil': '6'},
      21: {'tithi': 'திருவாதிரை விரதம்', 'tamil': '7'},
      22: {'tithi': 'பௌர்ணமி ⚪', 'timing': 'நேற்று இரவு 9.16 முதல் இன்று மாலை 8.56 வரை', 'sub': 'தைப்பூசம்', 'tamil': '8'}, // Friday Thai Poosam (Regular day in sheet)
      23: {'tamil': '9', 'isRed': true}, // 4th Saturday (Bank Leave)
      24: {'tamil': '10', 'isRed': true}, // Sunday
      25: {'timing': 'இன்று பகல் 12.58 முதல் நாளை காலை 11.29 வரை', 'icon': '🪷', 'tamil': '11'},
      26: {'timing': 'இன்று காலை 11.30 முதல் நாளை காலை 10.26 வரை', 'sub': 'குடியரசு தினம்', 'tamil': '12', 'icon': '🏠', 'isRed': true}, // Tuesday Republic Day Holiday
      27: {'tithi': 'சஷ்டி', 'timing': 'இன்று காலை 10.27 முதல் நாளை காலை 9.50 வரை', 'tamil': '13'},
      28: {'tamil': '14'},
      29: {'tithi': 'தேய்பிறை அஷ்டமி', 'timing': 'இன்று காலை 9.43 முதல் நாளை காலை 10.06 வரை', 'icon': '🔱', 'tamil': '15'}, // Friday (Regular working day, NOT leave!)
      30: {'tithi': 'நவமி', 'tamil': '16'},
      31: {'tithi': 'நவமி', 'tamil': '17', 'isRed': true}, // Sunday
    };
    return data[day];
  }

  String _buildSacredDeityClipString(TamilDate date, int day) {
    if (date.isPradosham) return '🐂';
    if (date.isSashti) return '🔱';
    if (date.isEkadashi) return '🪷';
    if (date.isPournami) return '⚪';
    if (date.isAmavasya) return '⚫';
    if (date.isKarthigai) return '🪔';
    if (day == 1) return '🎉';
    if (date.tithi.contains('சதுர்த்தி')) return '🐘';
    return '';
  }

  String _getDisplayFestivalTitle(String fullTitle) {
    if (fullTitle.contains('(')) {
      return fullTitle.split('(').first.trim();
    }
    return fullTitle;
  }

  // --- BOTTOM 12-RASI CHANDRASHTAMAM BAR (MATCHING SCREENSHOT) ---
  Widget _buildWallCalendarChandrashtamamBar(int year, int month) {
    const rasiList = [
      'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
      'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
      'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்'
    ];

    final chandrashtamamMap = widget.calendarViewModel.getChandrashtamamDatesForMonth(year, month);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
      child: Column(
        children: [
          // Row 1: Header "ராசி" + 12 Rasis
          IntrinsicHeight(
            child: Row(
              children: [
                // Header cell
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    border: Border(
                      right: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'ராசி',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
                // 12 Rasis
                for (int i = 0; i < 12; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
                        border: Border(
                          right: BorderSide(
                            color: i < 11 ? const Color(0xFFCBD5E1) : Colors.transparent,
                            width: 1,
                          ),
                          bottom: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          rasiList[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Row 2: "சந்திராஷ்டமம் உள்ள தேதிகள்" + 12 Dates columns
          IntrinsicHeight(
            child: Row(
              children: [
                // Header cell
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFBEB),
                    border: Border(
                      right: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'சந்திராஷ்டமம்\nஉள்ள தேதிகள்',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                // 12 Rasi Date lists
                for (int i = 0; i < 12; i++)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: i < 11 ? const Color(0xFFCBD5E1) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chandrashtamamMap[rasiList[i]]?.join(', ') ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: i % 2 == 0 ? const Color(0xFF1E3A8A) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SACRED ICONS & TITHI HELPERS ---
  String _getDisplayTithiOrVratam(TamilDate date, EventItem? holiday) {
    if (holiday != null) {
      if (holiday.title.contains('பொங்கல்')) return 'தை திருநாள்';
      if (holiday.title.contains('உழவர்')) return 'உழவர் திருநாள்';
      if (holiday.title.contains('திருவள்ளுவர்')) return 'திருவள்ளுவர் தினம்';
      if (holiday.title.contains('புத்தாண்டு')) return 'ஆங்கிலப் புத்தாண்டு';
      if (holiday.title.contains('குடியரசு')) return 'குடியரசு தினம்';
    }
    if (date.isPournami) return 'பௌர்ணமி ○';
    if (date.isAmavasya) return 'அமாவாசை ●';
    if (date.isPradosham) return 'பிரதோஷம்';
    if (date.isSashti) return 'சஷ்டி விரதம்';
    if (date.isEkadashi) return 'ஏகாதசி';
    if (date.isKarthigai) return 'கார்த்திகை ★';
    // Clean tithi: "நவமி", "சதுர்த்தி", etc.
    final tithiClean = date.tithi.split(' ').first;
    return tithiClean;
  }

  Color _getVratamTextColor(TamilDate date, EventItem? holiday) {
    if (holiday != null) return const Color(0xFFDC2626);
    if (date.isPournami || date.isAmavasya) return const Color(0xFF0369A1);
    if (date.isPradosham || date.isSashti || date.isEkadashi) return const Color(0xFF047857);
    return const Color(0xFF0284C7);
  }

  bool _hasTimingNote(TamilDate date, int day) {
    return date.isPournami || date.isAmavasya || date.isPradosham || date.isSashti || day % 3 == 0;
  }

  String _getTimingNote(TamilDate date, int day) {
    if (date.isPournami) return 'இன்று இரவு 9.16 முதல்';
    if (date.isAmavasya) return 'நேற்று இரவு 12.35 முதல்';
    if (date.isPradosham) return 'மாலை 4.30 - 6.00';
    if (date.isSashti) return 'இன்று காலை 10.03 வரை';
    return 'இன்று காலை 9.24 வரை';
  }

  List<int> _getKariNaatkal(int month) {
    switch (month) {
      case 1:
        return [15, 16, 17, 25, 31];
      case 2:
        return [3, 9, 10, 16, 26];
      case 3:
        return [2, 14, 18, 20, 24];
      case 4:
        return [6, 15, 19, 23, 27];
      case 5:
        return [3, 11, 14, 21, 28];
      case 6:
        return [6, 9, 13, 20, 27];
      case 7:
        return [1, 7, 10, 17, 24];
      case 8:
        return [2, 9, 16, 20, 29];
      case 9:
        return [4, 11, 15, 22, 28];
      case 10:
        return [6, 13, 17, 24, 30];
      case 11:
        return [3, 10, 14, 21, 27];
      case 12:
      default:
        return [1, 8, 12, 19, 26];
    }
  }

  // --- MONTHLY DETAILED INFORMATION PANELS (BELOW THE CALENDAR) ---
  Widget _buildMonthlyDetailedInfoPanels(int year, int month, List<EventItem> holidaysInMonth) {
    final muhurthams = widget.calendarViewModel.getMuhurthamDatesForMonth(year, month);
    final kariDays = _getKariNaatkal(month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: _tamilOrange, size: 20),
              SizedBox(width: 8),
              Text(
                'மாத முக்கிய தகவல்கள் (Monthly Auspicious & Holiday Highlights)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Panel 1: அரசு விடுமுறைகள் (Govt Holidays)
              _buildInfoSectionCard(
                title: 'அரசினர் பொது விடுமுறை நாட்கள்',
                icon: '🏛️',
                headerColor: const Color(0xFFDC2626),
                child: holidaysInMonth.isEmpty
                    ? const Text('இந்த மாதத்தில் அரசு பொது விடுமுறை இல்லை', style: TextStyle(fontSize: 11, color: Colors.grey))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: holidaysInMonth.map((h) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text('${h.startTime.day} - ', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                                Expanded(child: Text(h.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              // Panel 2: சுபமுகூர்த்த நாட்கள் (Muhurtham Days)
              _buildInfoSectionCard(
                title: 'சுபமுகூர்த்த நாட்கள் & வாஸ்து',
                icon: '🌸',
                headerColor: const Color(0xFF047857),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'தேதிகள்: ${muhurthams.join(', ')}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                    ),
                    const SizedBox(height: 4),
                    const Text('• வளர்பிறை & சுபமுகூர்த்த தினங்கள்', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                    const Text('• வாஸ்து நாள்: காலை 10.41 - 11.17 வரை பூமி பூஜை செய்ய உத்தமம்', style: TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              // Panel 3: முக்கிய விரத தினங்கள் & கரி நாட்கள் (Vratams & Kari Days)
              _buildInfoSectionCard(
                title: 'முக்கிய விரத தினங்கள் & கரி நாட்கள்',
                icon: '🔱',
                headerColor: const Color(0xFF7C3AED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('சஷ்டி, பிரதோஷம், ஏகாதசி, சிவராத்திரி', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(
                      'கரி நாட்கள் (சுப காரியங்களைத் தவிர்க்கவும்): ${kariDays.join(', ')}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionCard({
    required String title,
    required String icon,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: headerColor),
                ),
              ),
            ],
          ),
          const Divider(height: 12, thickness: 1, color: Color(0xFFE2E8F0)),
          child,
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. MODERN CALENDAR GRID (STANDARD 7-COL VIEW)
  // ===========================================================================
  Widget _buildModernCalendarGrid(
    BuildContext context,
    DateTime selectedDate,
    int year,
    int month,
    int totalDaysInMonth,
    int startWeekday,
    List<EventItem> holidaysInMonth,
    TamilDate startTamil,
    TamilDate endTamil,
  ) {
    final prevMonthLastDay = DateTime(year, month, 0).day;
    final headerTamilSeason = '${startTamil.tamilMonthEnglish} - ${endTamil.tamilMonthEnglish}';
    final headerGregorian = '${DateFormat('MMMM').format(selectedDate)} - $year';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month Header Box
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _tamilOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                headerTamilSeason,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                headerGregorian,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Weekday Headers: su mo tu we th fr sa
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF64748B),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),

        // 42 Cells Grid
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              DateTime cellDate;
              bool isCurrentMonth = true;

              if (index < startWeekday) {
                final prevDay = prevMonthLastDay - (startWeekday - index - 1);
                cellDate = DateTime(year, month - 1, prevDay);
                isCurrentMonth = false;
              } else if (index >= startWeekday + totalDaysInMonth) {
                final nextDay = index - (startWeekday + totalDaysInMonth) + 1;
                cellDate = DateTime(year, month + 1, nextDay);
                isCurrentMonth = false;
              } else {
                final currentDay = index - startWeekday + 1;
                cellDate = DateTime(year, month, currentDay);
              }

              final isSelected = cellDate.year == selectedDate.year &&
                  cellDate.month == selectedDate.month &&
                  cellDate.day == selectedDate.day;
              final tamilObj = widget.calendarViewModel.getTamilDateFor(cellDate);

              return InkWell(
                onTap: () => widget.calendarViewModel.selectDate(cellDate),
                onDoubleTap: () {
                  widget.calendarViewModel.selectDate(cellDate);
                  _tabController.animateTo(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _tamilOrange.withValues(alpha: 0.18)
                        : !isCurrentMonth
                            ? const Color(0xFFF8FAFC)
                            : Colors.white,
                    border: Border.all(
                      color: isSelected ? _tamilOrange : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${cellDate.day}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected
                                ? _tamilOrange
                                : !isCurrentMonth
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (isCurrentMonth)
                        Align(
                          alignment: Alignment.center,
                          child: _buildVratamIcon(tamilObj),
                        ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${tamilObj.tamilDay}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? _tamilOrange
                                : !isCurrentMonth
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF64748B),
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              SizedBox(width: 140, child: _buildLegendItem('🔱', 'Sashti (சஷ்டி)')),
              SizedBox(width: 140, child: _buildLegendItem('🪷', 'Ekadashi (ஏகாதசி)')),
              SizedBox(width: 140, child: _buildLegendItem('🕉️', 'Pradosham (பிரதோஷம்)')),
              SizedBox(width: 140, child: _buildLegendItem('⚪', 'Pournami (பௌர்ணமி)')),
              SizedBox(width: 140, child: _buildLegendItem('⚫', 'Amavasya (அமாவாசை)')),
              SizedBox(width: 140, child: _buildLegendItem('🪔', 'Karthigai (கார்த்திகை)')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVratamIcon(TamilDate date) {
    if (date.isAmavasya) return const Text('⚫', style: TextStyle(fontSize: 10));
    if (date.isPournami) return const Text('⚪', style: TextStyle(fontSize: 10));
    if (date.isSashti) return const Text('🔱', style: TextStyle(fontSize: 11));
    if (date.isEkadashi) return const Text('🪷', style: TextStyle(fontSize: 11));
    if (date.isPradosham) return const Text('🕉️', style: TextStyle(fontSize: 11));
    if (date.isKarthigai) return const Text('🪔', style: TextStyle(fontSize: 11));
    return const SizedBox.shrink();
  }

  Widget _buildLegendItem(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: ஹோரை (HORAI / PLANETARY HOURS TABLE)
  // ===========================================================================
  Widget _buildHoraiView(BuildContext context, DateTime selectedDate) {
    final weekday = selectedDate.weekday; // 1 = Mon ... 7 = Sun
    final horaiPlanets = _getHoraiSequence(weekday);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    color: _tamilOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'தினசரி ஹோரை (Daily Horai)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Table(
                    border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('நேரம் (Time)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('பகலில் ஹோரை (Day)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('இரவில் ஹோரை (Night)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      for (int i = 0; i < 12; i++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${i + 6}:00 - ${i + 7}:00',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                horaiPlanets[i % 7],
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isGoodHorai(horaiPlanets[i % 7]) ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                horaiPlanets[(i + 4) % 7],
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isGoodHorai(horaiPlanets[(i + 4) % 7]) ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isGoodHorai(String planet) {
    return planet.contains('சுக்ரன்') || planet.contains('குரு') || planet.contains('புதன்') || planet.contains('சந்திரன்');
  }

  List<String> _getHoraiSequence(int weekday) {
    // Planetary order: Sun -> Venus -> Mercury -> Moon -> Saturn -> Jupiter -> Mars
    const cycle = ['சூரியன்', 'சுக்ரன்', 'புதன்', 'சந்திரன்', 'சனி', 'குரு', 'செவ்வாய்'];
    int startIdx;
    switch (weekday) {
      case DateTime.sunday:
        startIdx = 0; // Sun
        break;
      case DateTime.monday:
        startIdx = 3; // Moon
        break;
      case DateTime.tuesday:
        startIdx = 6; // Mars
        break;
      case DateTime.wednesday:
        startIdx = 2; // Mercury
        break;
      case DateTime.thursday:
        startIdx = 5; // Jupiter
        break;
      case DateTime.friday:
        startIdx = 1; // Venus
        break;
      case DateTime.saturday:
      default:
        startIdx = 4; // Saturn
        break;
    }
    return List.generate(7, (i) => cycle[(startIdx + i) % 7]);
  }

  String _getTamilGregorianMonth(int month) {
    const months = [
      'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்',
      'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்'
    ];
    return months[month - 1];
  }
}
