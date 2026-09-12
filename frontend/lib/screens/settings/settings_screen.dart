import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/app_providers.dart';
import '../../providers/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profileData;
    final avatarController = context.watch<AvatarController>();
    final themeController = context.watch<ThemeController>();
    final name = [profile?.firstName, profile?.lastName].where((s) => s != null && s.isNotEmpty).join(' ');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Settings', style: AppTypography.titleLarge),
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile != null) ...[
                      ListSectionCard(title: 'Profile', children: [
                        Pressable(
                          onTap: () => context.go('/profile'),
                          child: Padding(
                            padding: AppSpacing.cardPadding,
                            child: Row(
                              children: [
                                AppAvatar(
                                  imageUrl: profile.profilePhotoUrl,
                                  initials: avatarController.initials,
                                  radius: 26,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.isEmpty ? 'Your profile' : name,
                                        style: AppTypography.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        profile.email ?? profile.headline ?? 'View and edit your profile',
                                        style: AppTypography.bodySmall.muted(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _buildSection('Account', [
                      _SettingsTile(
                        icon: Icons.badge_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your name, headline, and details',
                        onTap: () => context.go('/profile'),
                      ),
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        subtitle: 'Sign out of your CareerOS account',
                        textColor: AppColors.danger,
                        iconColor: AppColors.danger,
                        onTap: _confirmSignOut,
                      ),
                    ]),
                    _buildSection('Appearance', [
                      _SettingsTile(
                        icon: Icons.brightness_6_rounded,
                        title: 'Theme',
                        subtitle: _themeModeLabel(themeController.mode),
                        onTap: () => _showThemePicker(context, themeController),
                      ),
                    ]),
                    _buildSection('Notifications', [
                      _SettingsTile(
                        icon: Icons.notifications_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Receive updates and reminders',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Updates',
                        subtitle: 'Receive career insights and tips via email',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ]),
                    _buildSection('Privacy & Security', [
                      _SettingsTile(
                        icon: Icons.analytics_rounded,
                        title: 'Analytics',
                        subtitle: 'Help improve CareerOS with anonymous usage data',
                        trailing: Switch(
                          value: _analyticsEnabled,
                          onChanged: (v) => setState(() => _analyticsEnabled = v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Clear Cache',
                        subtitle: 'Remove temporary files and free up space',
                        onTap: _clearCache,
                      ),
                      _SettingsTile(
                        icon: Icons.download_outlined,
                        title: 'Data Export',
                        subtitle: 'Contact support to request your profile data',
                        onTap: () => _showContactSupport(context, reason: 'Data export request'),
                      ),
                    ]),
                    _buildSection('Legal', [
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => context.push('/settings/privacy'),
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () => context.push('/settings/terms'),
                      ),
                    ]),
                    _buildSection('Support', [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Feedback',
                        subtitle: 'Get support or send feedback',
                        onTap: () => _showContactSupport(context, reason: 'General feedback'),
                      ),
                    ]),
                    _buildSection('About', [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About CareerOS',
                        subtitle: 'v1.0.0',
                        onTap: () => context.push('/settings/about'),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Match system setting';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(BuildContext context, ThemeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.sheet,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: AppSpacing.horizontalLg,
              child: Row(children: [Text('Theme', style: AppTypography.titleMedium)]),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final mode in AppThemeMode.values)
              _ThemeOptionTile(
                icon: switch (mode) {
                  AppThemeMode.system => Icons.brightness_auto_rounded,
                  AppThemeMode.light => Icons.light_mode_rounded,
                  AppThemeMode.dark => Icons.dark_mode_rounded,
                },
                label: switch (mode) {
                  AppThemeMode.system => 'System',
                  AppThemeMode.light => 'Light',
                  AppThemeMode.dark => 'Dark',
                },
                subtitle: switch (mode) {
                  AppThemeMode.system => 'Match your device setting',
                  AppThemeMode.light => 'Always use light theme',
                  AppThemeMode.dark => 'Always use dark theme',
                },
                selected: controller.mode == mode,
                onTap: () {
                  controller.setMode(mode);
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: ListSectionCard(title: title, children: children),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialog, side: BorderSide(color: AppColors.border, width: 0.5)),
        title: Text('Sign out?', style: AppTypography.titleMedium),
        content: Text('You\'ll need to sign in again to access your CareerOS account.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: AppTypography.labelMedium)),
          AppButton(label: 'Sign out', onPressed: () => Navigator.pop(context, true), style: AppButtonStyle.danger, size: AppButtonSize.small),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cache cleared'),
        backgroundColor: AppColors.successContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
    );
  }

  void _showContactSupport(BuildContext context, {required String reason}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialog, side: BorderSide(color: AppColors.border, width: 0.5)),
        title: Text('Contact Support', style: AppTypography.titleMedium),
        content: Text(
          '$reason -- reach the CareerOS team at support@careeros.app and we\'ll follow up by email.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          AppButton(label: 'OK', onPressed: () => Navigator.pop(context), size: AppButtonSize.small),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.horizontalLg.copyWith(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyMedium.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  )),
                  Text(subtitle, style: AppTypography.bodySmall.muted()),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(AppRadii.md)),
              child: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(color: textColor)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.bodySmall.muted()),
                ],
              ),
            ),
            trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
