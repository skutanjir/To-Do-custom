import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:pdbl_testing_custom_mobile/core/storage/local_database.dart';
import 'package:pdbl_testing_custom_mobile/core/network/api_client.dart';
import 'package:pdbl_testing_custom_mobile/core/storage/secure_storage.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/notification_helper.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/widget_service.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';

class TaskRepository {
  final ApiClient _api = ApiClient();
  Isar get _isar => LocalDatabase.isar;

  // Track pending syncs to avoid race conditions during background refreshes
  static final Map<int, int> _pendingSyncsCount = {};
  static final Map<int, Timer> _debounceTimers = {};

  Future<List<TaskLocal>> getAllTasks(String userEmail) async {
    return await _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .findAll();
  }

  Future<TaskLocal?> findByApiId(int apiId, String userEmail) async {
    return await _isar.taskLocals
        .filter()
        .apiIdEqualTo(apiId)
        .and()
        .userEmailEqualTo(userEmail)
        .findFirst();
  }

  Future<List<TaskLocal>> getTasksForDate(
    DateTime date,
    String userEmail,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .and()
        .dueDateBetween(
          startOfDay,
          endOfDay,
          includeLower: true,
          includeUpper: false,
        )
        .findAll();
  }

  Future<List<TaskLocal>> getTasksByPriority(
    String priority,
    String userEmail,
  ) async {
    return await _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .and()
        .priorityEqualTo(priority, caseSensitive: false)
        .findAll();
  }

  Future<void> createTask(TaskLocal task, String userEmail) async {
    task.userEmail = userEmail;
    // 1. Save locally first (offline first)
    await _isar.writeTxn(() async {
      task.isSynced = false;
      await _isar.taskLocals.put(task);
    });

    // 2. Attempt sync immediately if possible
    await _syncSingleTask(task);

    // 3. Schedule local reminders if deadline exists
    if (task.dueDate != null) {
      await NotificationHelper.scheduleDeadlineReminders(
        taskId: task.id,
        title: task.title,
        deadline: task.dueDate!,
      );
    }
    WidgetService.fullSync();
  }

  Future<void> createTeamTask(TaskLocal task, String userEmail, List<String> assignedEmails) async {
    task.userEmail = userEmail;
    task.assignedEmails = assignedEmails.join(',');
    // 1. Save locally first (offline first)
    await _isar.writeTxn(() async {
      task.isSynced = false;
      await _isar.taskLocals.put(task);
    });

    // 2. Attempt sync immediately if possible
    await _syncSingleTask(task);

    // 3. Schedule local reminders if deadline exists
    if (task.dueDate != null) {
      await NotificationHelper.scheduleDeadlineReminders(
        taskId: task.id,
        title: task.title,
        deadline: task.dueDate!,
      );
    }
    WidgetService.fullSync();
  }

  Future<void> updateTask(TaskLocal task) async {
    await _isar.writeTxn(() async {
      task.isSynced = false;
      task.lastLocalUpdate = DateTime.now().millisecondsSinceEpoch;
      await _isar.taskLocals.put(task);
    });

    // Debounce sync to avoid spamming the server and reduce race conditions
    _debounceTimers[task.id]?.cancel();
    _debounceTimers[task.id] = Timer(const Duration(milliseconds: 500), () {
      _syncSingleTask(task);
      _debounceTimers.remove(task.id);

      // Re-schedule reminders in case deadline changed
      if (task.dueDate != null) {
        NotificationHelper.scheduleDeadlineReminders(
          taskId: task.id,
          title: task.title,
          deadline: task.dueDate!,
        );
      } else {
        NotificationHelper.cancelTaskReminders(task.id);
      }
    });
    WidgetService.fullSync();
  }

  Future<void> deleteTask(TaskLocal task) async {
    // Cancel any pending syncs for this task
    _debounceTimers[task.id]?.cancel();
    _debounceTimers.remove(task.id);
    _pendingSyncsCount.remove(task.id);

    if (task.apiId != null) {
      try {
        await _api.dio.delete('/todos/${task.apiId}');
      } catch (_) {
        // Even if API fails, we delete locally for now.
        // A more robust system would queue for deletion.
      }
    }
    await _isar.writeTxn(() async {
      await _isar.taskLocals.delete(task.id);
    });
    
    // Cancel any scheduled local notifications
    await NotificationHelper.cancelTaskReminders(task.id);
    WidgetService.fullSync();
  }

  Future<void> fetchTasksFromServer(String userEmail) async {
    try {
      final response = await _api.get('/todos');
      final List<dynamic> todos = response.data['todos'] ?? [];
      if (todos.isEmpty) return;

      // Optimize: Fetch all local tasks with API IDs to avoid querying in loop
      final existingTasks = await _isar.taskLocals
          .filter()
          .userEmailEqualTo(userEmail)
          .and()
          .apiIdIsNotNull()
          .findAll();
      
      final Map<int, TaskLocal> apiIdMap = {
        for (var t in existingTasks) t.apiId!: t
      };

      final List<TaskLocal> tasksToPut = [];

      for (var todo in todos) {
        final int apiId = todo['id'];
        final existing = apiIdMap[apiId];
        final task = existing ?? TaskLocal();

        // CRITICAL: If the task exists locally and is NOT synced,
        // OR if there is an active sync process for it,
        // skip updating it from the server to avoid race conditions.
        final isPending = (_pendingSyncsCount[task.id] ?? 0) > 0;
        if (existing != null && (!existing.isSynced || isPending)) {
          continue;
        }

        task.apiId = apiId;
        task.userEmail = userEmail;
        task.title = todo['judul'] ?? 'Untitled';
        task.description = todo['deskripsi'];
        task.priority = todo['priority'] ?? 'medium';
        task.isCompleted = todo['is_completed'] ?? false;
        task.isSynced = true;
        task.teamId = todo['team_id'];

        if (todo['assigned_emails'] != null && todo['assigned_emails'] is List) {
          task.assignedEmails = (todo['assigned_emails'] as List).join(',');
        }

        if (todo['deadline'] != null) {
          try {
            final DateTime dt = DateTime.parse(todo['deadline']);
            task.dueDate = DateTime(dt.year, dt.month, dt.day);
            task.dueTime = DateFormat('HH:mm:ss').format(dt);
          } catch (_) {}
        }

        tasksToPut.add(task);
      }

      if (tasksToPut.isNotEmpty) {
        await _isar.writeTxn(() async {
          await _isar.taskLocals.putAll(tasksToPut);
        });

        // Schedule reminders for updated tasks
        for (var task in tasksToPut) {
          if (task.dueDate != null) {
            NotificationHelper.scheduleDeadlineReminders(
              taskId: task.id,
              title: task.title,
              deadline: task.dueDate!,
            );
          }
        }
      }
      
      WidgetService.fullSync();
    } catch (_) {
      // Offline or error
    }
  }

  Future<void> _syncSingleTask(TaskLocal task) async {
    _pendingSyncsCount[task.id] = (_pendingSyncsCount[task.id] ?? 0) + 1;
    try {
      final payload = {
        'judul': task.title,
        if (task.description != null) 'deskripsi': task.description,
        if (task.dueDate != null)
          'deadline':
              '${DateFormat('yyyy-MM-dd').format(task.dueDate!)} ${task.dueTime ?? '23:59:00'}',
        'priority': task.priority,
        'is_completed': task.isCompleted,
        'created_at': DateTime.now().toIso8601String(),
        'device_id': await SecureStorage.getDeviceId(),
        if (task.teamId != null) 'team_id': task.teamId,
        if (task.assignedEmails != null && task.assignedEmails!.isNotEmpty)
          'assigned_emails': task.assignedEmails!.split(','),
      };

      if (task.apiId == null) {
        // Create (POST)
        debugPrint('Sync: Creating new task ${task.id} for guest/user');
        final response = await _api.post('/todos', data: payload);
        debugPrint('Sync response: ${response.data}');
        final data = response.data['todo'];

        await _isar.writeTxn(() async {
          task.apiId = data['id'];
          task.isSynced = true;
          await _isar.taskLocals.put(task);
          debugPrint(
            'Sync: Task ${task.id} created with API ID: ${task.apiId}',
          );
        });
      } else {
        // Update (PUT)
        debugPrint('Sync: Updating task ${task.id} (API ID: ${task.apiId})');
        await _api.dio.put('/todos/${task.apiId}', data: payload);

        await _isar.writeTxn(() async {
          // RE-FETCH: Check if the task was modified locally while the sync was in progress
          final current = await _isar.taskLocals.get(task.id);
          if (current != null &&
              current.lastLocalUpdate == task.lastLocalUpdate) {
            task.isSynced = true;
            await _isar.taskLocals.put(task);
            debugPrint('Sync: Task ${task.id} marked as synced');
          } else {
            debugPrint(
              'Sync: Task ${task.id} modified during sync, skipping mark-as-synced',
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Sync error for task ${task.id}: $e');
      if (e is DioException) {
        debugPrint('Sync error response: ${e.response?.data}');
      }
      // Ignore network errors, it stays isSynced = false
    } finally {
      final count = (_pendingSyncsCount[task.id] ?? 1) - 1;
      if (count <= 0) {
        _pendingSyncsCount.remove(task.id);
      } else {
        _pendingSyncsCount[task.id] = count;
      }
    }
  }

  // Reactive stream for tasks
  Stream<List<TaskLocal>> watchTasksForDate(DateTime date, String userEmail) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .and()
        .dueDateBetween(
          startOfDay,
          endOfDay,
          includeLower: true,
          includeUpper: false,
        )
        .watch(fireImmediately: true);
  }

  Stream<List<TaskLocal>> watchAllTasks(String userEmail) {
    return _isar.taskLocals
        .filter()
        .userEmailEqualTo(userEmail)
        .watch(fireImmediately: true);
  }

  // Migrate guest tasks to user email
  Future<void> migrateGuestTasksToUser(String newEmail) async {
    final guestTasks = await _isar.taskLocals
        .filter()
        .userEmailEqualTo('guest')
        .findAll();

    if (guestTasks.isEmpty) return;

    await _isar.writeTxn(() async {
      for (var task in guestTasks) {
        task.userEmail = newEmail;
        task.isSynced = false; // Mark for re-sync with new user email/token
        task.lastLocalUpdate = DateTime.now().millisecondsSinceEpoch;
        await _isar.taskLocals.put(task);
      }
    });

    // Push the migrated tasks to the server
    await syncAllUnsyncedTasks();
  }

  // Called to push all unsynced tasks to the backend
  Future<void> syncAllUnsyncedTasks() async {
    final unsynced = await _isar.taskLocals
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    // Process one by one, not multiple in same time
    for (var task in unsynced) {
      await _syncSingleTask(task);
    }
  }
}
