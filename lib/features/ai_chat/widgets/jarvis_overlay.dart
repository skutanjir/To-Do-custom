import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter, lerpDouble;
import 'dart:math' show pi, sin, cos;
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/voice_service.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/ai_chat_service.dart';

class JarvisOverlay extends StatefulWidget {
  final VoiceService voiceService;
  final VoidCallback onDismiss;

  const JarvisOverlay({
    super.key,
    required this.voiceService,
    required this.onDismiss,
  });

  @override
  State<JarvisOverlay> createState() => _JarvisOverlayState();
}

class _JarvisOverlayState extends State<JarvisOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _minimizeController;

  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _minimizeAnim;

  String _partialText = '';
  String _responseText = '';
  late JarvisState _currentState;
  late VoidCallback _stateCallback;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _currentState = widget.voiceService.state;

    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo));
    _fadeAnim = CurvedAnimation(parent: _slideController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));

    _minimizeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _minimizeAnim = CurvedAnimation(parent: _minimizeController, curve: Curves.easeInOutQuart);

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat();

    _stateCallback = () {
      if (mounted) {
        setState(() {
          _currentState = widget.voiceService.state;
          if (_currentState == JarvisState.passive) {
            _isMinimized = true;
            _minimizeController.forward();
          } else if (_currentState == JarvisState.active || _currentState == JarvisState.speaking) {
            _isMinimized = false;
            _minimizeController.reverse();
          }
        });
      }
    };
    widget.voiceService.addStateListener(_stateCallback);
    widget.voiceService.onPartialResult = (text) {
      if (mounted) {
        setState(() {
          _partialText = text;
          if (_currentState == JarvisState.speaking && text.isNotEmpty) {
            widget.voiceService.stopSpeaking(restartActive: true);
          }
        });
      }
    };
    widget.voiceService.onAiResponse = (text) {
      if (mounted) setState(() => _responseText = text);
    };
    widget.voiceService.onDismiss = () => _dismiss();

    _slideController.forward();
  }

  @override
  void dispose() {
    widget.voiceService.removeStateListener(_stateCallback);
    _slideController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _minimizeController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideController.reverse().then((_) => widget.onDismiss());
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _minimizeController.forward();
      } else {
        _minimizeController.reverse();
      }
    });
  }

  Color _getStateAccent() {
    switch (_currentState) {
      case JarvisState.active: return const Color(0xFF4F46E5); // Modern Indigo
      case JarvisState.processing: return const Color(0xFFD97706); // Modern Amber
      case JarvisState.speaking: return const Color(0xFF059669); // Modern Emerald
      case JarvisState.wakeDetected: return const Color(0xFF7C3AED); // Modern Violet
      default: return const Color(0xFF64748B); // Modern Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getStateAccent();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (!_isMinimized)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  widget.voiceService.stop();
                  _dismiss();
                  widget.voiceService.startPassiveListening();
                },
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
              ),
            ),

          AnimatedBuilder(
            animation: _minimizeAnim,
            builder: (context, child) {
              final val = _minimizeAnim.value;
              return Positioned(
                left: lerpDouble(isLargeScreen ? screenWidth * 0.2 : 0, screenWidth - 90, val),
                right: lerpDouble(isLargeScreen ? screenWidth * 0.2 : 0, 20, val),
                bottom: lerpDouble(0, 100, val),
                child: _isMinimized 
                  ? _buildFloatingOrb(accent)
                  : _buildBottomSheet(accent, bottomPadding, isLargeScreen),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(Color accent) {
    return GestureDetector(
      onTap: _toggleMinimize,
      child: Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0F172A).withOpacity(0.9),
          boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)],
          border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
        ),
        child: Center(child: _buildVoiceOrb(accent, size: 50, iconSize: 20)),
      ),
    );
  }

  Widget _buildBottomSheet(Color accent, double bottomPadding, bool isLargeScreen) {
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.85),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(accent),
                      _buildControlButtons(accent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSessionProgress(accent),
                  const SizedBox(height: 12),
                  _buildVoiceOrb(accent, size: 140, iconSize: 32),
                  const SizedBox(height: 24),
                  if (_partialText.isNotEmpty) _buildTextBubble(_partialText, isUser: true),
                  if (_responseText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildTextBubble(_responseText, isUser: false, accent: accent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Color accent) {
    String text = 'Jarvis';
    IconData icon = Icons.auto_awesome;
    Color color = accent;

    if (AiChatService().totalSteps > 0) {
      text = 'Session Active';
      icon = Icons.task_alt_rounded;
      color = const Color(0xFFF59E0B);
    } else {
      switch (_currentState) {
        case JarvisState.active: text = 'Listening'; icon = Icons.mic_none_rounded; break;
        case JarvisState.processing: text = 'Thinking'; icon = Icons.hourglass_empty_rounded; break;
        case JarvisState.speaking: text = 'Speaking'; icon = Icons.volume_up_rounded; break;
        default: break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Color accent) {
    final isInSession = AiChatService().totalSteps > 0;
    return Row(
      children: [
        if (isInSession)
          TextButton(
            onPressed: () { widget.voiceService.stopSpeaking(restartActive: false); widget.voiceService.processText('batal'); },
            child: const Text('CANCEL', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        IconButton(onPressed: _toggleMinimize, icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 24)),
      ],
    );
  }

  Widget _buildSessionProgress(Color accent) {
    final svc = AiChatService();
    if (svc.totalSteps <= 0) return const SizedBox.shrink();
    
    if (svc.sessionType == 'create' && svc.totalSteps == 5) {
      final steps = ['Title', 'Desc', 'Date', 'Time', 'Prio'];
      return Column(
        children: [
          Row(
            children: List.generate(5, (i) {
              final active = i == svc.currentStep - 1;
              final done = i < svc.currentStep - 1;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 3, margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      decoration: BoxDecoration(color: done ? Colors.greenAccent : active ? accent : Colors.white10, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i], style: TextStyle(fontSize: 7, color: active ? accent : Colors.white24, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildVoiceOrb(Color accent, {double size = 140, double iconSize = 26}) {
    final active = _currentState == JarvisState.active || _currentState == JarvisState.speaking;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () { if (_currentState == JarvisState.speaking) widget.voiceService.stopSpeaking(restartActive: true); },
        child: SizedBox(
          width: size, height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseController, _waveController]),
            builder: (context, _) => CustomPaint(
              painter: _VoiceOrbPainter(accent: accent, pulse: _pulseController.value, wave: _waveController.value, isActive: active, isProcessing: _currentState == JarvisState.processing),
              child: Center(
                child: Container(
                  width: size * 0.4, height: size * 0.4,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.1), border: Border.all(color: accent.withOpacity(0.3), width: 2)),
                  child: Icon(_getIconForState(), color: Colors.white, size: iconSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForState() {
    switch (_currentState) {
      case JarvisState.active: return Icons.mic_rounded;
      case JarvisState.processing: return Icons.auto_awesome_rounded;
      case JarvisState.speaking: return Icons.volume_up_rounded;
      default: return Icons.auto_awesome;
    }
  }

  Widget _buildTextBubble(String text, {required bool isUser, Color? accent}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: isUser ? Colors.white.withOpacity(0.05) : (accent ?? Colors.indigo).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: isUser ? Colors.white70 : Colors.white, fontWeight: isUser ? FontWeight.normal : FontWeight.w500)),
    );
  }
}

class _VoiceOrbPainter extends CustomPainter {
  final Color accent; final double pulse; final double wave; final bool isActive; final bool isProcessing;
  _VoiceOrbPainter({required this.accent, required this.pulse, required this.wave, required this.isActive, required this.isProcessing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 3;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0;

    if (isActive) {
      for (int i = 0; i < 3; i++) {
        final r = baseRadius + (i * 12) + (pulse * 10);
        paint.color = accent.withOpacity((0.2 - i * 0.05) * (1 - pulse * 0.3));
        canvas.drawCircle(center, r, paint);
      }
      final wavePath = Path();
      for (int deg = 0; deg <= 360; deg += 5) {
        final rad = deg * pi / 180;
        final r = baseRadius + 15 + sin(rad * 10 + wave * 4 * pi) * 6 * pulse;
        final x = center.dx + r * cos(rad); final y = center.dy + r * sin(rad);
        if (deg == 0) {
          wavePath.moveTo(x, y);
        } else {
          wavePath.lineTo(x, y);
        }
      }
      wavePath.close();
      paint.color = accent.withOpacity(0.4); paint.strokeWidth = 1.5;
      canvas.drawPath(wavePath, paint);
    } else if (isProcessing) {
      for (int i = 0; i < 8; i++) {
        final angle = (i * 45 + wave * 360) * pi / 180;
        final x = center.dx + (baseRadius + 10) * cos(angle); final y = center.dy + (baseRadius + 10) * sin(angle);
        canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = accent.withOpacity(0.6));
      }
    } else {
      canvas.drawCircle(center, baseRadius, paint..color = accent.withOpacity(0.1));
    }
  }
  @override bool shouldRepaint(covariant _VoiceOrbPainter oldDelegate) => true;
}
