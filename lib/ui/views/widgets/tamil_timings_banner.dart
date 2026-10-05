import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../view_models/calendar_view_model.dart';

class TamilTimingsBanner extends StatefulWidget {
  final CalendarViewModel viewModel;

  const TamilTimingsBanner({
    super.key,
    required this.viewModel,
  });

  @override
  State<TamilTimingsBanner> createState() => _TamilTimingsBannerState();
}

class _TamilTimingsBannerState extends State<TamilTimingsBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.viewModel.showTamilTimings) return const SizedBox.shrink();

    final date = widget.viewModel.selectedDate;
    final timings = widget.viewModel.getTamilTimingsFor(date);
    final now = DateTime.now();
    final isSelectedToday = date.year == now.year && date.month == now.month && date.day == now.day;

    // Check active status right now
    final badTimingNow = isSelectedToday ? timings.getConflictingBadTiming(now, now.add(const Duration(minutes: 1))) : null;
    final goodTimingNow = isSelectedToday ? timings.getMatchingGoodTiming(now, now.add(const Duration(minutes: 1))) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badTimingNow != null
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : goodTimingNow != null
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🕉️', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'தமிழ் பஞ்சாங்கம்',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timings.tamilDate != null
                                  ? '• ${timings.tamilDate!.shortTamilDate}, ${timings.tamilDate!.tamilYear} ஆண்டு • ${timings.tamilDayName}'
                                  : '• ${timings.tamilDayName} (${timings.tamilMonthSeason})',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'நல்ல நேரம்: ${timings.nallaNeramMorning.timeFormatted} | ராகு காலம்: ${timings.rahuKalam.timeFormatted}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real-time status badge
                  if (isSelectedToday) ...[
                    if (badTimingNow != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'இப்போது ${badTimingNow.tamilLabel}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (goodTimingNow != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'இப்போது ${goodTimingNow.tamilLabel}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(width: 8),

                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Collapsed / Expanded Content
          AnimatedCrossFade(
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  // Section Title: Good Timings
                  Row(
                    children: const [
                      Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                      SizedBox(width: 6),
                      Text(
                        'நல்ல நேரம் (Auspicious Good Timings)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTimingPill(
                        context,
                        title: 'காலை நல்ல நேரம்',
                        englishTitle: 'Morning Nalla Neram',
                        time: timings.nallaNeramMorning.timeFormatted,
                        bgColor: const Color(0xFFDCFCE7),
                        borderColor: const Color(0xFF86EFAC),
                        textColor: const Color(0xFF15803D),
                        icon: Icons.wb_sunny_rounded,
                        note: 'Best for meetings, launching projects, agreements, travel',
                      ),
                      _buildTimingPill(
                        context,
                        title: 'மாலை நல்ல நேரம்',
                        englishTitle: 'Evening Nalla Neram',
                        time: timings.nallaNeramEvening.timeFormatted,
                        bgColor: const Color(0xFFDCFCE7),
                        borderColor: const Color(0xFF86EFAC),
                        textColor: const Color(0xFF15803D),
                        icon: Icons.wb_twilight_rounded,
                        note: 'Auspicious for closing deals, ceremonies, planning',
                      ),
                      _buildTimingPill(
                        context,
                        title: 'கௌரி நல்ல நேரம் (காலை)',
                        englishTitle: 'Gowri Nalla Neram (AM)',
                        time: timings.gowriNallaNeramMorning.timeFormatted,
                        bgColor: const Color(0xFFFEF3C7),
                        borderColor: const Color(0xFFFCD34D),
                        textColor: const Color(0xFFB45309),
                        icon: Icons.star_rounded,
                        note: 'Highly auspicious Gowri timing for spiritual & high-value work',
                      ),
                      _buildTimingPill(
                        context,
                        title: 'கௌரி நல்ல நேரம் (இரவு)',
                        englishTitle: 'Gowri Nalla Neram (PM)',
                        time: timings.gowriNallaNeramEvening.timeFormatted,
                        bgColor: const Color(0xFFFEF3C7),
                        borderColor: const Color(0xFFFCD34D),
                        textColor: const Color(0xFFB45309),
                        icon: Icons.nightlight_round,
                        note: 'Evening Gowri timing for family and key decisions',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Section Title: Bad Timings
                  Row(
                    children: const [
                      Icon(Icons.cancel_rounded, size: 14, color: Color(0xFFDC2626)),
                      SizedBox(width: 6),
                      Text(
                        'கெட்ட நேரம் / அசுப நேரம் (Inauspicious Timings)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTimingPill(
                        context,
                        title: 'இராகு காலம் (Rahu Kalam)',
                        englishTitle: 'Rahu Kalam',
                        time: timings.rahuKalam.timeFormatted,
                        bgColor: const Color(0xFFFEE2E2),
                        borderColor: const Color(0xFFFCA5A5),
                        textColor: const Color(0xFFB91C1C),
                        icon: Icons.warning_amber_rounded,
                        note: 'Avoid starting new ventures, contracts, buying assets, or travel',
                      ),
                      _buildTimingPill(
                        context,
                        title: 'எமகண்டம் (Yamagandam)',
                        englishTitle: 'Yamagandam',
                        time: timings.yamagandam.timeFormatted,
                        bgColor: const Color(0xFFFFEDD5),
                        borderColor: const Color(0xFFFDBA74),
                        textColor: const Color(0xFFC2410C),
                        icon: Icons.error_outline_rounded,
                        note: 'Avoid new initiatives, celebrations, or signing commitments',
                      ),
                      _buildTimingPill(
                        context,
                        title: 'குளிகை காலம் (Kuligai)',
                        englishTitle: 'Kuligai / Gulika',
                        time: timings.kuligai.timeFormatted,
                        bgColor: const Color(0xFFF3E8FF),
                        borderColor: const Color(0xFFD8B4FE),
                        textColor: const Color(0xFF7E22CE),
                        icon: Icons.hourglass_top_rounded,
                        note: 'Favorable for deeds you wish to repeat: savings, investments',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingPill(
    BuildContext context, {
    required String title,
    required String englishTitle,
    required String time,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required String note,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: textColor),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: TextStyle(
              fontSize: 9.5,
              color: textColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
