import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/design/design.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import 'app_button.dart';
import 'avatar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({super.key, required this.child, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        // AppShell is the single Material/Scaffold ancestor for every routed
        // page (ShellRoute renders screens directly, without their own
        // Scaffold). Without this, TextField/IconButton/NavigationBar/etc.
        // throw "No Material widget found" and can blank out the whole page.
        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: wide ? null : _MobileBottomNav(currentPath: currentPath),
          body: Container(
            decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
            child: wide
                ? Row(
                    children: [
                      _Sidebar(currentPath: currentPath),
                      Expanded(child: child),
                    ],
                  )
                : child,
          ),
        );
      },
    );
  }
}



Future<void> _confirmSignOut(BuildContext context) async {
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
  if (confirm == true && context.mounted) {
    context.read<AuthProvider>().logout();
  }
}

class _MobileBottomNav extends StatelessWidget {
  final String currentPath;

  const _MobileBottomNav({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getIndex(currentPath);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 72,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onDestinationSelected(context, index),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded, size: 24),
              selectedIcon: Icon(Icons.grid_view_rounded, size: 24, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, size: 24),
              selectedIcon: Icon(Icons.person_rounded, size: 24, color: AppColors.primary),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined, size: 24),
              selectedIcon: Icon(Icons.description_rounded, size: 24, color: AppColors.primary),
              label: 'Resume',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, size: 24),
              selectedIcon: Icon(Icons.auto_awesome_rounded, size: 24, color: AppColors.primary),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded, size: 24),
              selectedIcon: Icon(Icons.more_horiz_rounded, size: 24, color: AppColors.primary),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  int _getIndex(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/profile')) return 1;
    if (path.startsWith('/resume')) return 2;
    if (path.startsWith('/ai')) return 3;
    return 4; // More
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/profile'); break;
      case 2: context.go('/resume'); break;
      case 3: context.go('/ai'); break;
      case 4: _showMoreMenu(context); break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoreBottomSheet(currentPath: currentPath),
    );
  }
}

class _MoreBottomSheet extends StatelessWidget {
  final String currentPath;

  const _MoreBottomSheet({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Row(
              children: [
                Text('More Tools', style: AppTypography.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreItem(
            icon: Icons.radar_rounded,
            label: 'ATS Analyzer',
            subtitle: 'Analyze resume against job descriptions',
            selected: currentPath.startsWith('/ats'),
            onTap: () => _navigate(context, '/ats'),
          ),
          _MoreItem(
            icon: Icons.payments_rounded,
            label: 'Salary Intelligence',
            subtitle: 'Estimate and compare market compensation',
            selected: currentPath.startsWith('/salary'),
            onTap: () => _navigate(context, '/salary'),
          ),
          Divider(height: 1, color: AppColors.border, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          _MoreItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            subtitle: 'App preferences and account',
            onTap: () => _navigate(context, '/settings'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
return Pressable(
      onTap: onTap,
      radius: AppRadii.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        margin: AppSpacing.horizontalLg.copyWith(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
              child: Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textSecondary),
            ),
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
            if (selected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentPath;

  const _Sidebar({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final path = currentPath;
    final profile = context.watch<AuthProvider>().profileData;

    return Container(
      width: 280,
      padding: AppSpacing.xlAll,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Center(child: Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 24)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CareerOS', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                    Text('AI Career OS', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (profile != null) ...[
            _UserHeader(profile: profile),
            const SizedBox(height: AppSpacing.xl),
          ],
          _SidebarSection(
            title: 'Core',
            items: [
              _SidebarItem(route: '/', icon: Icons.grid_view_rounded, label: 'Dashboard', path: path),
              _SidebarItem(route: '/profile', icon: Icons.person_outline_rounded, label: 'Profile', path: path),
              _SidebarItem(route: '/resume', icon: Icons.description_outlined, label: 'Resume Studio', path: path),
              _SidebarItem(route: '/ai', icon: Icons.auto_awesome_outlined, label: 'Career AI', path: path),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SidebarSection(
            title: 'Tools',
            items: [
              _SidebarItem(route: '/ats', icon: Icons.radar_rounded, label: 'ATS Analyzer', path: path),
              _SidebarItem(route: '/salary', icon: Icons.payments_rounded, label: 'Salary Intelligence', path: path),
            ],
          ),
          const Spacer(),
          Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          _SidebarItem(
            route: '',
            icon: Icons.logout_rounded,
            label: 'Sign out',
            path: path,
            onTap: () => _confirmSignOut(context),
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final UserProfile profile;

  const _UserHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final avatarController = context.watch<AvatarController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: profile.profilePhotoUrl,
          initials: avatarController.initials,
          radius: 28,
          onTap: () => context.go('/profile'),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('${profile.firstName ?? ''} ${profile.lastName ?? ''}', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(profile.headline ?? 'Career Professional', style: AppTypography.bodySmall.muted(), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<_SidebarItem> items;

  const _SidebarSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.overline),
        const SizedBox(height: AppSpacing.md),
        ...items,
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String route;
  final IconData icon;
  final String label;
  final String path;
  final VoidCallback? onTap;
  final bool destructive;

  const _SidebarItem({
    required this.route,
    required this.icon,
    required this.label,
    required this.path,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = path == route;
    final fgColor = destructive
        ? AppColors.danger
        : selected
            ? AppColors.primary
            : AppColors.textSecondary;

    return Pressable(
      onTap: onTap ?? () => context.go(route),
      radius: AppRadii.md,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: fgColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected) Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}