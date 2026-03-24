import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:pdbl_testing_custom_mobile/core/storage/local_database.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/notification_helper.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';

/// Service to manage specialized "Anti-Late" alarms and reminders.
/// Extends NotificationHelper with state tracking for the AI.
class AlarmService extends ChangeNotifier {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// Mock analysis of weather/traffic to adjust alarms.
  /// Used for Phase 5 "Smart Alarm" feature.
  Future<Duration> checkEnvironmentalFactors() async {
    // Simulated weather: "Rainy" -> 15 min buffer
    // Simulated traffic: "Heavy" -> 10 min buffer
    debugPrint("AI Butler JARVIS: Analysing environmental factors...");
    
    bool isRainy = true; // Mocked
    bool heavyTraffic = DateTime.now().minute % 2 == 0; // Simulated dynamic
    
    int bufferMinutes = 0;
    if (isRainy) bufferMinutes += 15;
    if (heavyTraffic) bufferMinutes += 10;
    
    if (bufferMinutes > 0) {
      debugPrint("AI Butler JARVIS: Applying $bufferMinutes mins environmental buffer.");
    }
    
    return Duration(minutes: bufferMinutes);
  }

  List<TaskLocal> _upcomingAlarms = [];
  List<TaskLocal> get upcomingAlarms => _upcomingAlarms;

  Isar get _isar => LocalDatabase.isar;

  /// Fetch upcoming tasks that have deadlines soon (next 24h)
  Future<void> refreshUpcomingAlarms(String userEmail) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));

    _upcomingAlarms = await _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .and()
        .isCompletedEqualTo(false)
        .and()
        .dueDateBetween(now, tomorrow)
        .sortByDueDate()
        .findAll();
    
    notifyListeners();
  }

  /// Schedule a specific "Anti-Late" alarm for a task.
  /// This goes beyond normal reminders by setting an alarm object.
  Future<void> scheduleAntiLateAlarm({
    required int taskId,
    required String title,
    required DateTime deadline,
  }) async {
    await NotificationHelper.scheduleDeadlineReminders(
      taskId: taskId,
      title: title,
      deadline: deadline,
    );
    // Logic for "Anti-Late" specifically could include more frequent checks
    // or triggering a Jarvis voice wake-up if possible.
  }

  /// Cancel an alarm
  Future<void> cancelAlarm(int taskId) async {
    await NotificationHelper.cancelTaskReminders(taskId);
  }

  /// Get a summary of the next most urgent task
  TaskLocal? getNextUrgentTask() {
    if (_upcomingAlarms.isEmpty) return null;
    return _upcomingAlarms.first;
  }

  String getAlarmStatusText() {
    final next = getNextUrgentTask();
    if (next == null) return "No upcoming alarms";
    
    final timeStr = next.dueTime ?? "23:59:00";
    return "Next: ${next.title} at $timeStr";
  }
}
