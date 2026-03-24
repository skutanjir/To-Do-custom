import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/task/pages/create_task_page.dart';
import 'package:pdbl_testing_custom_mobile/features/group/pages/create_group_task_page.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/login_page.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/pages/ai_chat_page.dart';

class NexuzeBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AuthService? authService;
  final VoidCallback? onAiTap;
  final VoidCallback? onAiVoiceTap;

  const NexuzeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.authService,
    this.onAiTap,
    this.onAiVoiceTap,
  });

  @override
  State<NexuzeBottomBar> createState() => _NexuzeBottomBarState();
}

class _NexuzeBottomBarState extends State<NexuzeBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _plusMenuController;
  late Animation<double> _plusMenuAnim;
  bool _plusMenuOpen = false;
  OverlayEntry? _overlayEntry;

  static const _navIcons = [
    Icons.home_rounded,
    Icons.add_rounded,
    Icons.calendar_month_rounded,
    Icons.groups_rounded,
  ];

  static const _plusSubItems = [
    _SubItem(icon: Icons.person_add_outlined, label: 'Personal'),
    _SubItem(icon: Icons.group_add_outlined, label: 'Team'),
  ];

  @override
  void initState() {
    super.initState();
    _plusMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _plusMenuAnim = CurvedAnimation(
      parent: _plusMenuController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _plusMenuController.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    if (index == 1) {
      _togglePlusMenu();
      return;
    }
    _closePlusMenu();
    widget.onTap(index);
  }

  void _togglePlusMenu() {
    setState(() {
      _plusMenuOpen = !_plusMenuOpen;
      if (_plusMenuOpen) {
        _plusMenuController.forward();
        _showOverlay();
      } else {
        _plusMenuController.reverse().then((_) => _hideOverlay());
      }
    });
  }

  void _closePlusMenu() {
    if (!_plusMenuOpen) return;
    setState(() {
      _plusMenuOpen = false;
      _plusMenuController.reverse().then((_) => _hideOverlay());
    });
  }

  void _showOverlay() {
    final nav = Navigator.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _PlusOverlay(
        anim: _plusMenuAnim,
        onClose: _closePlusMenu,
        onTapItem: (i) async {
          _closePlusMenu();
          if (i == 0) {
            nav.push(MaterialPageRoute(
              builder: (_) =>
                  CreateTaskPage(authService: widget.authService),
            ));
          } else if (i == 1) {
            final user = await widget.authService?.getCachedUser();
            if (!mounted) return;
            if (user == null || user.isGuest) {
              _showAuthDialog(nav.context);
              return;
            }
            nav.push(MaterialPageRoute(
              builder: (_) =>
                  CreateGroupTaskPage(authService: widget.authService),
            ));
          }
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showAuthDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text(
          'Team projects require a registered account. Log in now?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pushAndRemoveUntil(
                c,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (r) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _openAiChat() {
    _closePlusMenu();
    if (widget.onAiTap != null) {
      widget.onAiTap!();
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AiChatPage(authService: widget.authService),
      ));
    }
  }

  void _triggerVoiceAssistant() {
    _closePlusMenu();
    if (widget.onAiVoiceTap != null) {
      widget.onAiVoiceTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.currentIndex;

    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Floating AI button above navbar
          Positioned(
            right: 24,
            bottom: 92,
            child: _AiFab(
              onTap: _openAiChat,
              onLongPress: _triggerVoiceAssistant,
            ),
          ),
          // Capsule navbar
          Positioned(
            left: 20,
            right: 20,
            bottom: 12,
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (i) {
                  final isActive = idx == i && i != 1;
                  final isPlus = i == 1;

                  return GestureDetector(
                    onTap: () => _onItemTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: isActive ? 48 : (isPlus ? 48 : 44),
                      height: isActive ? 48 : (isPlus ? 48 : 44),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppColors.primary.withOpacity(0.08)
                            : (isPlus && _plusMenuOpen
                                ? AppColors.textSecondary.withOpacity(0.08)
                                : Colors.transparent),
                      ),
                      child: AnimatedRotation(
                        turns: (isPlus && _plusMenuOpen) ? 0.125 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _navIcons[i],
                          size: isPlus ? 26 : 24,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Floating AI Button with pulse animation
class _AiFab extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _AiFab({required this.onTap, required this.onLongPress});

  @override
  State<_AiFab> createState() => _AiFabState();
}

class _AiFabState extends State<_AiFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = _pulse.value;
          final glowSize = 10.0 + 8.0 * t;
          
          return GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18), // Modern Squircle-like
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1), // Indigo
                    Color(0xFF8B5CF6), // Violet
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3 * (1 - t)),
                    blurRadius: glowSize,
                    spreadRadius: 1 + 2 * t,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Plus Menu Overlay
class _PlusOverlay extends StatelessWidget {
  final Animation<double> anim;
  final VoidCallback onClose;
  final Function(int) onTapItem;

  const _PlusOverlay({
    required this.anim,
    required this.onClose,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: anim,
              builder: (context, _) => Container(
                color: Colors.black.withValues(alpha: 0.2 * anim.value),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: bottomPad + 90,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: anim,
            builder: (context, _) {
              if (anim.value == 0) return const SizedBox.shrink();
              return Align(
                alignment: const Alignment(-0.3, 0), // Rubah kiri kanan
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _NexuzeBottomBarState._plusSubItems.length,
                    (i) {
                      final item = _NexuzeBottomBarState._plusSubItems[i];
                      final delay = i * 0.15;
                      final t = ((anim.value - delay) / (1.0 - delay))
                          .clamp(0.0, 1.0);

                      return Padding(
                        padding: EdgeInsets.only(left: i > 0 ? 24 : 0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - t)),
                          child: Transform.scale(
                            scale: t,
                            child: Opacity(
                              opacity: t,
                              child: GestureDetector(
                                onTap: () => onTapItem(i),
                                child: Container(
                                  width: 46,
                                  height: 46,
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
                                  child: Icon(item.icon,
                                      color: AppColors.primary,
                                      size: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubItem {
  final IconData icon;
  final String label;
  const _SubItem({required this.icon, required this.label});
}
