import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/shell/widgets/bottom_navbar.dart';
import 'package:pdbl_testing_custom_mobile/features/home/pages/home_page.dart';
import 'package:pdbl_testing_custom_mobile/features/task/pages/task_page.dart';
import 'package:pdbl_testing_custom_mobile/features/calendar/pages/calendar_page.dart';
import 'package:pdbl_testing_custom_mobile/features/group/pages/group_page.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/login_page.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/voice_service.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/widgets/jarvis_overlay.dart';
import 'package:pdbl_testing_custom_mobile/core/services/settings_service.dart';
import 'package:pdbl_testing_custom_mobile/features/profile/pages/profile_page.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/pages/ai_chat_page.dart';

class MainNavigation extends StatefulWidget {
  final AuthService authService;
  const MainNavigation({super.key, required this.authService});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  List<Widget>? _pages;
  SettingsService? _settingsService;
  VoiceService? _voiceService;
  bool _showJarvisOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initServices();
  }

  Future<void> _initServices() async {
    final settings = await SettingsService.init();
    final voice = VoiceService(
      authService: widget.authService,
      settingsService: settings,
    );
    await voice.initialize();

    if (!mounted) return;

    setState(() {
      _settingsService = settings;
      _voiceService = voice;
      _pages = [
        HomePage(authService: widget.authService, voiceService: _voiceService),
        TaskPage(authService: widget.authService),
        CalendarPage(authService: widget.authService),
        const GroupPage(),
        ProfilePage(
          authService: widget.authService,
          settingsService: _settingsService,
          voiceService: _voiceService,
        ),
      ];
    });

    _voiceService!.onWakeWordDetected = () {
      debugPrint('MainNavigation: Wake word callback received');
      if (mounted) setState(() => _showJarvisOverlay = true);
    };
    _voiceService!.onDismiss = () {
      debugPrint('MainNavigation: Dismiss callback received');
      if (mounted) setState(() => _showJarvisOverlay = false);
    };
    _voiceService!.startPassiveListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_voiceService == null) return;
    
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_showJarvisOverlay) {
        setState(() => _showJarvisOverlay = false);
      }
      if (_voiceService!.state != JarvisState.passive &&
          _voiceService!.state != JarvisState.idle) {
        _voiceService!.stop();
        _voiceService!.startPassiveListening();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_voiceService!.state == JarvisState.idle) {
        _voiceService!.startPassiveListening();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _voiceService?.dispose();
    super.dispose();
  }

  void _onNavTap(int index) async {
    if (index == _currentIndex) return;

    if (index == 3) {
      final user = await widget.authService.getCurrentUser();
      if (user == null || user.isGuest) {
        if (mounted) {
          _showAuthRequiredDialog();
        }
        return;
      }
    }

    setState(() => _currentIndex = index);
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text(
          'Group features are only available for registered users. Would you like to log in or register now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }

  void _openAiChat() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AiChatPage(authService: widget.authService),
    ));
  }

  void _activateJarvis() {
    _voiceService?.activate();
    setState(() => _showJarvisOverlay = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null || _voiceService == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                // Using IndexedStack prevents the pages from being destroyed and rebuilt
                // on every tab switch. This caches their state and prevents re-loading data.
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages!,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom,
            child: NexuzeBottomBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              authService: widget.authService,
              onAiTap: _openAiChat,
              onAiVoiceTap: _activateJarvis,
            ),
          ),
          // Global Jarvis Overlay
          if (_showJarvisOverlay)
            JarvisOverlay(
              voiceService: _voiceService!,
              onDismiss: () {
                setState(() => _showJarvisOverlay = false);
              },
            ),
        ],
      ),
    );
  }
}
