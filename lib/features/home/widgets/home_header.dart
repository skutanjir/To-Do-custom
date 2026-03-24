import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final bool isLoading;
  final bool isGuest;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;

  const HomeHeader({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.isLoading = false,
    this.isGuest = false,
    this.onNotificationTap,
    this.onAvatarTap,
    this.onLogoutTap,
    this.onLoginTap,
    this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              const Text(
                'Let\'s make today a productive day.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            offset: const Offset(0, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.surface,
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.04),
            onSelected: (value) {
              if (value == 'profile') {
                onAvatarTap?.call();
              } else if (value == 'notifications') {
                onNotificationTap?.call();
              } else if (value == 'logout') {
                onLogoutTap?.call();
              } else if (value == 'login') {
                onLoginTap?.call();
              } else if (value == 'register') {
                onRegisterTap?.call();
              }
            },
            itemBuilder: (BuildContext context) {
              if (isGuest) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'login',
                    child: ListTile(
                      leading: Icon(Icons.login, color: AppColors.primary),
                      title: Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'register',
                    child: ListTile(
                      leading: Icon(
                        Icons.person_add_outlined,
                        color: AppColors.textPrimary,
                      ),
                      title: Text(
                        'Register',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ];
              }

              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'notifications',
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_none,
                      color: AppColors.textPrimary,
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: AppColors.errorText),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.errorText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.person,
                              color: AppColors.textTertiary,
                              size: 24,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: AppColors.textTertiary,
                          size: 24,
                        ),
            ),
          ),
        ),
      ],
    );
  }
}
