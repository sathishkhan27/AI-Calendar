import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/connected_account.dart';
import '../view_models/accounts_view_model.dart';
import '../view_models/calendar_view_model.dart';

class AccountsView extends StatefulWidget {
  final AccountsViewModel accountsViewModel;
  final CalendarViewModel calendarViewModel;

  const AccountsView({
    super.key,
    required this.accountsViewModel,
    required this.calendarViewModel,
  });

  @override
  State<AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  final _geminiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await widget.accountsViewModel.getGeminiApiKey();
    if (key != null) _geminiKeyController.text = key;
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    super.dispose();
  }

  void _showConnectDialog(BuildContext context, AccountProvider provider) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              provider == AccountProvider.google ? Icons.g_mobiledata_rounded : Icons.work_outline_rounded,
              color: provider == AccountProvider.google ? AppColors.googleRed : AppColors.outlookBlue,
            ),
            const SizedBox(width: 8),
            Text('Connect ${provider.displayName}'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: provider == AccountProvider.google ? 'your.name@gmail.com' : 'your.name@outlook.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: provider == AccountProvider.google ? 'My Google Calendar' : 'Work Outlook',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'OAuth Access Token (Optional)',
                  hintText: 'Leave empty for automated client OAuth',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                await widget.accountsViewModel.connectNewAccount(
                  email: emailController.text.trim(),
                  displayName: nameController.text.trim(),
                  provider: provider,
                  accessToken: tokenController.text.trim().isNotEmpty
                      ? tokenController.text.trim()
                      : null,
                );
                await widget.calendarViewModel.refresh();
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Connect & Sync'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.accountsViewModel,
      builder: (context, _) {
        final accounts = widget.accountsViewModel.accounts;
        final isSaving = widget.accountsViewModel.isSaving;

        return Scaffold(
          backgroundColor: AppColors.darkBg,
          appBar: AppBar(
            title: const Text('Accounts & Sync Integrations', style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                icon: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync_rounded),
                tooltip: 'Sync All Accounts',
                onPressed: isSaving
                    ? null
                    : () async {
                        await widget.accountsViewModel.syncAll();
                        await widget.calendarViewModel.refresh();
                      },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client-Side OAuth2 Synchronization',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'The app automatically ingests calendar events, Google Meet calls, and Microsoft Teams meetings from your connected accounts.',
                            style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Connected Accounts List
              Row(
                children: [
                  const Text(
                    'Active Mail & Calendar Accounts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<AccountProvider>(
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                    tooltip: 'Connect another account',
                    onSelected: (p) => _showConnectDialog(context, p),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: AccountProvider.google,
                        child: Row(
                          children: [
                            Icon(Icons.g_mobiledata_rounded, color: AppColors.googleRed),
                            SizedBox(width: 8),
                            Text('Add Google Account'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: AccountProvider.microsoft,
                        child: Row(
                          children: [
                            Icon(Icons.work_outline_rounded, color: AppColors.outlookBlue),
                            SizedBox(width: 8),
                            Text('Add Outlook Account'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              for (final acc in accounts) _buildAccountCard(acc),
              const SizedBox(height: 28),

              // Regional & Government Calendars Section
              const Text(
                'Regional & Government Holidays',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTamilHolidaysCard(),
              const SizedBox(height: 28),

              // AI Configuration Section
              const Text(
                'Gemini AI Configuration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.aiSparkle.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.aiSparkle, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Google Gemini API Key',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Optional: Provide your Gemini API key for live LLM synthesis, or leave empty to use the built-in intelligent scheduling engine.',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _geminiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'AIzaSy...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save_rounded, color: AppColors.aiSparkle),
                          onPressed: () async {
                            await widget.accountsViewModel.setGeminiApiKey(_geminiKeyController.text.trim());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gemini API Key saved!')),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(ConnectedAccount acc) {
    final isGoogle = acc.provider == AccountProvider.google;
    final color = isGoogle ? AppColors.googleRed : AppColors.outlookBlue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGoogle ? Icons.g_mobiledata_rounded : Icons.work_outline_rounded,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      acc.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  acc.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  '${acc.syncedEventsCount} events & calls synced • Last sync: ${acc.lastSyncedAt != null ? DateFormat('h:mm a').format(acc.lastSyncedAt!) : 'Just now'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: acc.syncEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) async {
              await widget.accountsViewModel.toggleAccountSync(acc.id, val);
              await widget.calendarViewModel.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.darkTextMuted),
            tooltip: 'Remove Account',
            onPressed: () async {
              await widget.accountsViewModel.removeAccount(acc.id);
              await widget.calendarViewModel.refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTamilHolidaysCard() {
    final isEnabled = widget.calendarViewModel.showTamilHolidays;
    final upcomingCount = widget.calendarViewModel.upcomingTamilHolidays.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🚩', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Tamil Nadu Public Holidays',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                            : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isEnabled ? 'Active' : 'Disabled',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? const Color(0xFFF59E0B) : AppColors.darkTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'தமிழ்நாடு அரசு பொது விடுமுறை நாட்கள் (Government Gazetted Holidays)',
                  style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  isEnabled
                      ? '$upcomingCount upcoming official holidays • Pongal, Tamil New Year, Deepavali & more'
                      : 'Holidays hidden from calendar view',
                  style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showTamilHolidaysDialog(context),
            icon: const Icon(Icons.list_alt_rounded, size: 16, color: Color(0xFFF59E0B)),
            label: const Text('View List', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isEnabled,
            activeThumbColor: const Color(0xFFF59E0B),
            onChanged: (val) async {
              await widget.calendarViewModel.toggleTamilHolidays(val);
            },
          ),
        ],
      ),
    );
  }

  void _showTamilHolidaysDialog(BuildContext context) {
    final holidays = widget.calendarViewModel.upcomingTamilHolidays;
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Text('🚩', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tamil Nadu Public Holidays',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Official Government Public Holidays for ${now.year} - ${now.year + 1}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: holidays.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (ctx, index) {
                    final h = holidays[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Text(
                          DateFormat('MMM d').format(h.startTime),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                      title: Text(
                        h.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        h.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
