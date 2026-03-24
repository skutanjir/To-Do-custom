import 'package:flutter/material.dart';
import 'navigator_service.dart';
import 'dart:async';

class ErrorHandler {
  static void showSuccessPopup(String message, {String? title}) {
    _showTopNotification(
      message,
      title: title ?? 'Success',
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  static void _showTopNotification(
    String message, {
    required String title,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Attempt to get the current context or fallback to navigator context
    final overlay = NavigatorService.navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint('ErrorHandler: Overlay is null, cannot show notification');
      return;
    }
    debugPrint('ErrorHandler: Showing notification: $message');

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SlidingNotification(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
    
    // Auto dismiss after 5.5 seconds to allow exit animation to finish
    Timer(const Duration(milliseconds: 5500), () {
      if (entry.mounted) {
        entry.remove();
        debugPrint('ErrorHandler: Notification dismissed');
      }
    });
  }

  static void showErrorPopup(String message, {String? title}) {
    _showTopNotification(
      message,
      title: title ?? 'Error',
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  static void handleApiError(dynamic error) {
    if (error.toString().contains('SocketException') || 
        error.toString().toLowerCase().contains('connection failed') ||
        error.toString().toLowerCase().contains('failed host lookup')) {
      showErrorPopup('No internet connection or server is offline.', title: 'Server Offline');
    } else if (error.toString().contains('401')) {
      showErrorPopup('Your session has expired. Please log in again.', title: 'Session Expired');
    } else if (error.toString().contains('403')) {
      showErrorPopup('You do not have permission to perform this action.', title: 'Access Denied');
    } else {
      // Clean up the error message if it's too long
      String msg = error.toString();
      if (msg.length > 100) {
        msg = '${msg.substring(0, 97)}...';
      }
      showErrorPopup(msg, title: 'Error');
    }
  }
}

class _SlidingNotification extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _SlidingNotification({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_SlidingNotification> createState() => _SlidingNotificationState();
}

class _SlidingNotificationState extends State<_SlidingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Start exit animation after 4.5 seconds
    Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        _controller.animateTo(-0.1, duration: const Duration(milliseconds: 200), curve: Curves.easeIn)
          .then((_) => _controller.animateTo(-2.0, duration: const Duration(milliseconds: 400), curve: Curves.easeInCubic));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
