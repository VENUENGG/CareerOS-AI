import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profileData;
    final avatarController = context.watch<AvatarController>();
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
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile != null) ...[
                  ListSectionCard(children: [
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
                _buildSection('Appearance', [
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme throughout the app',
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                      activeThumbColor: AppColors.primary,
                    ),
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
                _buildSection('Privacy & Data', [
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
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => _showInfo('Privacy Policy'),
                  ),
                  _SettingsTile(
                    icon: Icons.security_rounded,
                    title: 'Data Export',
                    subtitle: 'Download your profile data',
                    onTap: () => _showInfo('Data Export'),
                  ),
                ]),
                _buildSection('About', [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: 'CareerOS AI v1.0.0',
                  ),
                  _SettingsTile(
                    icon: Icons.code_rounded,
                    title: 'Open Source Licenses',
                    subtitle: 'View third-party licenses',
                    onTap: () => _showInfo('Licenses'),
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Feedback',
                    subtitle: 'Get support or send feedback',
                    onTap: () => _showInfo('Help & Feedback'),
                  ),
                ]),
                _buildSection('Account', [
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your CareerOS account',
                    textColor: AppColors.danger,
                    iconColor: AppColors.danger,
                    onTap: _confirmSignOut,
                  ),
                ]),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ],
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
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialog, side: const BorderSide(color: AppColors.border, width: 0.5)),
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

  void _showInfo(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.dialog, side: const BorderSide(color: AppColors.border, width: 0.5)),
        title: Text(title, style: AppTypography.titleMedium),
        content: Text('$title content coming soon', style: AppTypography.bodyMedium),
        actions: [
          AppButton(label: 'OK', onPressed: () => Navigator.pop(context), size: AppButtonSize.small),
        ],
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