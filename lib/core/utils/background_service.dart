// lib/core/utils/background_service.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

/// Background service entry point.
/// STT/TTS plugins require Flutter's UI thread, so they CANNOT run here.
/// This service acts purely as a keep-alive to prevent Android from killing
/// the app process, allowing the foreground VoiceService to keep listening.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Periodic heartbeat to keep the service alive
  Timer.periodic(const Duration(seconds: 30), (timer) {
    // no-op heartbeat
  });
}

@pragma('vm:entry-point')
class BackgroundService {

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'jarvis_voice_channel',
        initialNotificationTitle: 'Jarvis Voice Service',
        initialNotificationContent: 'Jarvis is standing by...',
        foregroundServiceNotificationId: 1001,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Manually start the background service if not already running.
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
  }

  /// Stop the background service.
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stopService');
    }
  }
}

