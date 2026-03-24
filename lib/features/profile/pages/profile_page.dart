import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pdbl_testing_custom_mobile/features/profile/services/profile_service.dart';
import 'package:pdbl_testing_custom_mobile/features/profile/pages/notification_page.dart';
import 'package:pdbl_testing_custom_mobile/core/models/user.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/welcome_page.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/error_handler.dart';
import 'package:pdbl_testing_custom_mobile/core/services/settings_service.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/voice_service.dart';

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  final SettingsService? settingsService;
  final VoiceService? voiceService;

  const ProfilePage({
    super.key, 
    required this.authService, 
    this.settingsService,
    this.voiceService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  User? _user;
  bool _loggingOut = false;
  bool _updatingAvatar = false;
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _selectedGender = widget.settingsService?.jarvisGender ?? 'male';
    debugPrint('ProfilePage: initState. Gender=$_selectedGender, settingsService=${widget.settingsService != null}');
    widget.settingsService?.addListener(_onSettingsChanged);
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settingsService != oldWidget.settingsService) {
      oldWidget.settingsService?.removeListener(_onSettingsChanged);
      widget.settingsService?.addListener(_onSettingsChanged);
      _selectedGender = widget.settingsService?.jarvisGender ?? 'male';
    }
  }

  @override
  void dispose() {
    widget.settingsService?.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    debugPrint('ProfilePage: Settings changed. Gender=${widget.settingsService?.jarvisGender}');
    if (mounted) {
      setState(() {
        _selectedGender = widget.settingsService?.jarvisGender ?? 'male';
      });
    }
  }

  Future<void> _loadUser() async {
    final user = await widget.authService.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // Check file size (2MB = 2 * 1024 * 1024 bytes)
      final File file = File(image.path);
      final int sizeInBytes = await file.length();
      if (sizeInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must be less than 2MB')),
        );
        return;
      }

      setState(() => _updatingAvatar = true);
      await _profileService.updateAvatar(image.path);
      await _loadUser();

      if (!mounted) return;
      ErrorHandler.showSuccessPopup('Profile picture updated successfully');
    } catch (e) {
      ErrorHandler.handleApiError(e);
    } finally {
      if (mounted) setState(() => _updatingAvatar = false);
    }
  }

  void _showChangeNameDialog() {
    final nameController = TextEditingController(text: _user?.name);
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      setDialogState(() => loading = true);
                      try {
                        await _profileService.updateProfile(
                          name: nameController.text.trim(),
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ErrorHandler.showSuccessPopup('Profile updated successfully');
                      } catch (e) {
                        setDialogState(() => loading = false);
                        ErrorHandler.handleApiError(e);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setDialogState(() => loading = true);
                      try {
                        await _profileService.updatePassword(
                          currentPassword: currentPasswordController.text,
                          newPassword: newPasswordController.text,
                          newPasswordConfirmation:
                              confirmPasswordController.text,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ErrorHandler.showSuccessPopup('Password updated successfully');
                      } catch (e) {
                        setDialogState(() => loading = false);
                        ErrorHandler.handleApiError(e);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController(text: _user?.email);
    final passwordController = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'New Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setDialogState(() => loading = true);
                      try {
                        await _profileService.updateEmail(
                          email: emailController.text,
                          currentPassword: passwordController.text,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ErrorHandler.showSuccessPopup('Email updated successfully');
                      } catch (e) {
                        setDialogState(() => loading = false);
                        ErrorHandler.handleApiError(e);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.name ?? 'User';
    final email = _user?.email ?? '';
    final isGuest = _user?.isGuest ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
            Stack(
              children: [
                GestureDetector(
                  onTap: _updatingAvatar ? null : _pickAndUploadImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                    ),
                    child: _updatingAvatar
                        ? const Center(child: CircularProgressIndicator())
                        : _user?.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  _user!.avatar!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, stackTrace) => const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 50,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 50,
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGuest ? 'Guest Mode' : email,
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 32),
            if (!isGuest) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Edit Profile Info',
                onTap: _showChangeNameDialog,
              ),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: _showChangePasswordDialog,
              ),
              _buildSettingTile(
                icon: Icons.email_outlined,
                title: 'Change Email',
                onTap: _showChangeEmailDialog,
              ),
              _buildSettingTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Jarvis Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: widget.settingsService?.isJarvisVoiceEnabled ?? true,
                      onChanged: (val) {
                        widget.settingsService?.setJarvisVoiceEnabled(val);
                      },
                      title: const Text(
                        'Jarvis Voice Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: const Text('Allow wake word "Ok Jarvis" and voice response'),
                      secondary: const Icon(Icons.psychology, color: AppColors.primary),
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildVoiceSettingItem(
                      icon: Icons.record_voice_over,
                      title: 'Jarvis Voice Character',
                      subtitle: 'Pilih karakter suara laki-laki atau perempuan',
                      content: SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: 'male',
                              label: Text('Laki-laki', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.male, size: 16),
                            ),
                            ButtonSegment(
                              value: 'female',
                              label: Text('Perempuan', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.female, size: 16),
                            ),
                          ],
                          selected: {_selectedGender},
                          onSelectionChanged: (Set<String> newSelection) {
                            if (newSelection.isNotEmpty) {
                              final gender = newSelection.first;
                              debugPrint('ProfilePage: Tapped gender=$gender (was=$_selectedGender)');
                              setState(() {
                                _selectedGender = gender;
                              });
                              widget.settingsService?.setJarvisGender(gender).then((_) {
                                widget.voiceService?.forceSetGender();
                              });
                            }
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: AppColors.primary,
                            selectedForegroundColor: Colors.white,
                            backgroundColor: AppColors.surface,
                            visualDensity: VisualDensity.compact,
                            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Logout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loggingOut ? null : _logout,
                icon: _loggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout, size: 20),
                label: Text(_loggingOut ? 'Logging out...' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildVoiceSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
