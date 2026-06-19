import 'package:flutter/material.dart';

import '../../app/nut_app.dart';
import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/backup_service.dart';
import '../../shared/services/local_storage_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/widgets/nut_card.dart';
import '../../shared/widgets/responsive_page.dart';
import '../../shared/widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.currentTheme = AppTheme.dark,
    this.onThemeChanged,
    this.onResetOnboarding,
  });

  final AppTheme currentTheme;
  final ValueChanged<AppTheme>? onThemeChanged;
  final VoidCallback? onResetOnboarding;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _notificationService = NotificationService();
  final _backupService = BackupService();
  final _storage = LocalStorageService.instance;

  bool _appLockEnabled = false;
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lockEnabled = await _authService.isAppLockEnabled();
    final notifEnabled = await _storage.isNotifEnabled();
    final hour = await _storage.getNotifHour();
    final minute = await _storage.getNotifMinute();

    setState(() {
      _appLockEnabled = lockEnabled;
      _notificationsEnabled = notifEnabled;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleAppLock(bool value) async {
    final l10n = context.l10n;
    if (value) {
      final available = await _authService.isBiometricAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsErrorBiometrics)),
          );
        }
        return;
      }
      final authenticated = await _authService.authenticate();
      if (authenticated) {
        await _authService.setAppLockEnabled(true);
        setState(() => _appLockEnabled = true);
      }
    } else {
      await _authService.setAppLockEnabled(false);
      setState(() => _appLockEnabled = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final l10n = context.l10n;
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        await _notificationService.scheduleDailyReminder(
          hour: _reminderTime.hour,
          minute: _reminderTime.minute,
          title: l10n.settingsDailyReminder,
          body: l10n.settingsDailyReminderSubtitle,
        );
        await _storage.setNotifEnabled(true);
        setState(() => _notificationsEnabled = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsErrorNotifPermission)),
          );
        }
      }
    } else {
      await _notificationService.cancelAll();
      await _storage.setNotifEnabled(false);
      setState(() => _notificationsEnabled = false);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      await _storage.setNotifHour(picked.hour);
      await _storage.setNotifMinute(picked.minute);
      setState(() => _reminderTime = picked);
      
      if (_notificationsEnabled) {
        final l10n = context.l10n;
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
          title: l10n.settingsDailyReminder,
          body: l10n.settingsDailyReminderSubtitle,
        );
      }
    }
  }

  Future<void> _exportData() async {
    final l10n = context.l10n;
    try {
      await _backupService.exportBackup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsExportFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _importData() async {
    final l10n = context.l10n;
    final success = await _backupService.importBackup();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? l10n.settingsImportSuccess
              : l10n.settingsImportFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.nutPalette;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: NutResponsiveListView(
        children: [

          // ── Appearance ───────────────────────────────
          SmallSectionLabel(title: l10n.settingsSectionAppearance),
          const SizedBox(height: 8),
          NutCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.settingsTheme,
                    style: textTheme.bodyMedium,
                  ),
                ),
                Row(
                  children: AppTheme.values.map((theme) {
                    final selected = theme == widget.currentTheme;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: theme != AppTheme.values.last ? 8 : 0,
                        ),
                        child: _ThemeChip(
                          theme: theme,
                          selected: selected,
                          palette: palette,
                          onTap: () => widget.onThemeChanged?.call(theme),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Security ─────────────────────────────────
          SmallSectionLabel(title: l10n.settingsSectionSecurity),
          const SizedBox(height: 8),
          NutCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _appLockEnabled,
              activeColor: palette.accentGold,
              title: Text(l10n.settingsAppLock, style: textTheme.bodyMedium),
              subtitle: Text(l10n.settingsAppLockSubtitle, style: textTheme.bodySmall),
              onChanged: _toggleAppLock,
            ),
          ),
          const SizedBox(height: 20),

          // ── Notifications ────────────────────────────
          SmallSectionLabel(title: l10n.settingsSectionNotifications),
          const SizedBox(height: 8),
          NutCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _notificationsEnabled,
                  activeColor: palette.accentGold,
                  title: Text(l10n.settingsDailyReminder, style: textTheme.bodyMedium),
                  subtitle: Text(l10n.settingsDailyReminderSubtitle, style: textTheme.bodySmall),
                  onChanged: _toggleNotifications,
                ),
                if (_notificationsEnabled) ...[
                  Divider(color: palette.border, thickness: 0.5, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsReminderTime, style: textTheme.bodyMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _reminderTime.format(context),
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: palette.textMuted, size: 18),
                      ],
                    ),
                    onTap: _selectTime,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Data ─────────────────────────────────────
          SmallSectionLabel(title: l10n.settingsSectionData),
          const SizedBox(height: 8),
          NutCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.upload_outlined, color: palette.textSecondary),
                  title: Text(l10n.settingsExportData, style: textTheme.bodyMedium),
                  subtitle: Text(l10n.settingsExportDataSubtitle, style: textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: palette.textMuted, size: 18),
                  onTap: _exportData,
                ),
                Divider(color: palette.border, thickness: 0.5, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.download_outlined, color: palette.textSecondary),
                  title: Text(l10n.settingsImportData, style: textTheme.bodyMedium),
                  subtitle: Text(l10n.settingsImportDataSubtitle, style: textTheme.bodySmall),
                  trailing: Icon(Icons.chevron_right, color: palette.textMuted, size: 18),
                  onTap: _importData,
                ),
                Divider(color: palette.border, thickness: 0.5, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline, color: palette.textSecondary),
                  title: Text(l10n.settingsAboutNut, style: textTheme.bodyMedium),
                  subtitle: Text(
                    l10n.settingsVersionInfo('0.1.0', 'Wave 1 MVP'),
                    style: textTheme.bodySmall,
                  ),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),

          // ── Dev tools ────────────────────────────────
          if (widget.onResetOnboarding != null) ...[
            const SizedBox(height: 20),
            SmallSectionLabel(title: l10n.settingsSectionDeveloper),
            const SizedBox(height: 8),
            NutCard(
              borderColor: palette.reset.withOpacity(0.3),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh, color: palette.reset),
                title: Text(
                  l10n.settingsResetOnboarding,
                  style: textTheme.bodyMedium?.copyWith(color: palette.reset),
                ),
                subtitle: Text(l10n.settingsResetOnboardingSubtitle, style: textTheme.bodySmall),
                onTap: widget.onResetOnboarding,
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'NUT',
      applicationVersion: '0.1.0 · Wave 1 MVP',
      applicationLegalese: '© 2025 NUT. All rights reserved.',
    );
  }
}

// ── Theme chip widget ─────────────────────────

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.theme,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final AppTheme theme;
  final bool selected;
  final NutPalette palette;
  final VoidCallback onTap;

  // Preview colors cho từng theme
  static const _previewBg = {
    AppTheme.dark:  Color(0xFF0D0D0D),
    AppTheme.ocean: Color(0xFF0F2027),
    AppTheme.light: Color(0xFFF7F4EE),
  };
  static const _previewAccent = {
    AppTheme.dark:  Color(0xFFF5A623),
    AppTheme.ocean: Color(0xFF6FA897),
    AppTheme.light: Color(0xFFD4850A),
  };

  @override
  Widget build(BuildContext context) {
    final bg     = _previewBg[theme]!;
    final accent = _previewAccent[theme]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? palette.accentBg : palette.surface,
          borderRadius: BorderRadius.circular(NutRadius.card),
          border: Border.all(
            color: selected ? palette.accentGold : palette.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Mini preview swatch
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.border),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              theme.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? palette.accentGold : palette.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
