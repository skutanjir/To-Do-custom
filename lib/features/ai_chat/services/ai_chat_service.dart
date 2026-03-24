import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:pdbl_testing_custom_mobile/core/network/api_client.dart';
import 'package:pdbl_testing_custom_mobile/core/storage/local_database.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/task/services/task_repository.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_message.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_message_local.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_session.dart';

/// Service that handles AI chat communication and task action execution.
class AiChatService extends ChangeNotifier {
  static final AiChatService _instance = AiChatService._internal();
  
  factory AiChatService({AuthService? authService}) {
    if (authService != null) _instance._authService = authService;
    return _instance;
  }
  
  AiChatService._internal();

  final ApiClient _api = ApiClient();
  final TaskRepository _taskRepo = TaskRepository();
  AuthService? _authService;
  AuthService? get authService => _authService;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  final Set<String> _messageIds = {}; // v12.1: Prevent double-chat bug

  String? _currentChatId;
  String? get currentChatId => _currentChatId;

  String _computeDevice = 'CPU';
  String get computeDevice => _computeDevice;

  int _currentStep = 0;
  int get currentStep => _currentStep;
  
  int _totalSteps = 0;
  int get totalSteps => _totalSteps;
  
  String? _sessionLabel;
  String? get sessionLabel => _sessionLabel;

  String? _sessionType;
  String? get sessionType => _sessionType;

  CancelToken? _cancelToken;
  bool get isCancellable => _cancelToken != null;

  bool _isRequestInProgress = false; // v12.1: Prevent concurrent request double-chat
  bool get isRequestInProgress => _isRequestInProgress;

  static VoidCallback? onTaskChanged;
  static ValueChanged<String>? onActionMessage;

  Isar get _isar => LocalDatabase.isar;

  void _addUniqueMessage(ChatMessage msg) {
    if (_messageIds.contains(msg.id)) return;
    _messageIds.add(msg.id);
    _messages.add(msg);
    notifyListeners();
  }

  void cancelCurrentRequest() {
    _cancelToken?.cancel('User cancelled');
    _cancelToken = null;
    notifyListeners();
  }

  /// Send a message to the AI and get a response.
  Future<ChatMessage> sendMessage(String userMessage) async {
    if (_isRequestInProgress) return ChatMessage(role: 'assistant', content: 'Request in progress...');
    _isRequestInProgress = true;
    
    _cancelToken = CancelToken();
    final userMsg = ChatMessage(role: 'user', content: userMessage);
    _addUniqueMessage(userMsg);

    try {
      // ... (rest of the method stays mostly same, but replace _messages.add with _addUniqueMessage)

      final historyMessages = _messages.length <= 21
          ? _messages.sublist(0, _messages.length - 1)
          : _messages.sublist(_messages.length - 21, _messages.length - 1);
      final history = historyMessages.map((m) => m.toHistoryMap()).toList();

      final response = await _api.dio.post('/ai/chat', data: {
        'message': userMessage,
        'history': history,
        'chat_id': _currentChatId,
      }, cancelToken: _cancelToken);

      final data = response.data;
      final aiMessage = data['message'] as String? ?? 'Sorry, I could not process your request.';
      final action = data['action'] as Map<String, dynamic>?;
      final actionResult = data['action_result'] as Map<String, dynamic>?;
      final reasoningDetails = data['reasoning_details'] as Map<String, dynamic>? ?? {};
      
      // v12.0: Parse chain of thought and multi intent
      final chainOfThought = (data['chain_of_thought'] as List<dynamic>?)?.cast<String>() ?? [];
      final multiIntent = (data['multi_intent'] as List<dynamic>?) ?? [];
      
      if (chainOfThought.isNotEmpty) reasoningDetails['chain_of_thought'] = chainOfThought;
      if (multiIntent.isNotEmpty) reasoningDetails['multi_intent'] = multiIntent;
      
      final rawQuickReplies = data['quick_replies'] as List<dynamic>?;
      final quickReplies = rawQuickReplies?.map((e) => e.toString()).toList() ?? [];
      
      if (data['chat_id'] != null) {
        _currentChatId = data['chat_id'].toString();
      }
      
      _currentStep = data['current_step'] ?? 0;
      _totalSteps = data['total_steps'] ?? 0;
      _sessionLabel = data['session_label'];
      _sessionType = data['session_type'];
      _computeDevice = (data['compute_device'] as String? ?? 'CPU').toUpperCase();

      final aiMsg = ChatMessage(
        role: 'assistant',
        content: aiMessage,
        action: action,
        actionResult: actionResult,
        reasoningDetails: reasoningDetails,
        quickReplies: quickReplies,
        chainOfThought: chainOfThought,
        multiIntent: multiIntent,
      );
      _addUniqueMessage(aiMsg);

      // Persist to local Isar
      try {
        final localSessionId = await _getOrCreateLocalSession(_currentChatId, userMessage);
        await _saveMessageToLocal(userMsg, localSessionId);
        await _saveMessageToLocal(aiMsg, localSessionId);
      } catch (e) {
        debugPrint('Local save error: $e');
      }

      if (aiMsg.hasAction) {
        await _executeAction(aiMsg);
      }
      
      _cancelToken = null;
      _isRequestInProgress = false;
      notifyListeners();
      return aiMsg;
    } catch (e) {
      _isRequestInProgress = false;
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('AI Chat cancelled by user');
        if (_messages.isNotEmpty && _messages.last.role == 'user') {
          _messages.removeLast();
        }
        _cancelToken = null;
        notifyListeners();
        rethrow;
      }
      debugPrint('AI Chat error: $e');
      final errorMsg = ChatMessage(
        role: 'assistant',
        content: 'Maaf, tidak bisa terhubung ke AI service. Pastikan server sudah berjalan.',
      );
      _addUniqueMessage(errorMsg);
      _cancelToken = null;
      notifyListeners();
      return errorMsg;
    }
  }

  Future<void> _saveMessageToLocal(ChatMessage msg, int sessionId) async {
    final local = ChatMessageLocal()
      ..sessionId = sessionId
      ..role = msg.role
      ..content = msg.content
      ..timestamp = msg.timestamp
      ..action = msg.action
      ..actionResult = msg.actionResult
      ..reasoningDetails = msg.reasoningDetails
      ..quickReplies = msg.quickReplies
      ..codeBlock = msg.codeBlock
      ..codeLanguage = msg.codeLanguage
      ..knowledgeCard = msg.knowledgeCard
      ..translationPair = msg.translationPair
      ..formattedContent = msg.formattedContent
      ..contentType = msg.contentType;
    
    await _isar.writeTxn(() async {
      await _isar.chatMessageLocals.put(local);
      final session = await _isar.chatSessions.get(sessionId);
      if (session != null) {
        session.messageCount++;
        session.updatedAt = DateTime.now();
        await _isar.chatSessions.put(session);
      }
    });
  }

  Future<int> _getOrCreateLocalSession(String? backendChatId, String title) async {
    final sessions = await _isar.chatSessions.where().sortByUpdatedAtDesc().findAll();
    
    if (backendChatId != null) {
      for (final s in sessions) {
        if (s.title.endsWith('[#$backendChatId]')) return s.id;
      }
    }
    
    final session = ChatSession.create(title: '$title [#${backendChatId ?? 'local'}]');
    await _isar.writeTxn(() => _isar.chatSessions.put(session));
    return session.id;
  }

  /// Execute a task action from the AI response.
  Future<void> _executeAction(ChatMessage msg) async {
    if (!msg.hasAction) return;

    final type = msg.actionType;
    final data = msg.actionData;
    final userEmail = await _getUserEmail();
    debugPrint('AiChatService: Executing action "$type" for user "$userEmail"');

    try {
      switch (type) {
        case 'create_task':
          if (data != null) {
            final task = TaskLocal()
              ..title = data['judul'] ?? 'New Task'
              ..description = data['deskripsi']
              ..priority = data['priority'] ?? 'medium';

            if (data['deadline'] != null) {
              try {
                final dt = DateTime.parse(data['deadline']);
                task.dueDate = DateTime(dt.year, dt.month, dt.day);
                task.dueTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
              } catch (e) {
                debugPrint('AiChatService: Deadline parse error: $e');
              }
            }

            debugPrint('AiChatService: Creating task "${task.title}"');
            await _taskRepo.createTask(task, userEmail);
            
            _currentStep = 0;
            _totalSteps = 0;
            _sessionType = null;
            _sessionLabel = null;

            onTaskChanged?.call();
            onActionMessage?.call('Tugas "${task.title}" berhasil dibuat secara lokal.');
          }
          break;

        case 'batch_create':
          final tasks = data?['tasks'] as List<dynamic>?;
          if (tasks != null) {
            for (final taskAction in tasks) {
              final taskData = (taskAction is Map<String, dynamic>)
                  ? (taskAction['data'] as Map<String, dynamic>? ?? taskAction)
                  : <String, dynamic>{};
              final task = TaskLocal()
                ..title = taskData['judul'] ?? 'New Task'
                ..description = taskData['deskripsi']
                ..priority = taskData['priority'] ?? 'medium';

              if (taskData['deadline'] != null) {
                try {
                  final dt = DateTime.parse(taskData['deadline']);
                  task.dueDate = DateTime(dt.year, dt.month, dt.day);
                  task.dueTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
                } catch (_) {}
              }
              await _taskRepo.createTask(task, userEmail);
            }
            onTaskChanged?.call();
            onActionMessage?.call('${tasks.length} tugas berhasil dibuat.');
          }
          break;

        case 'update_task':
        case 'delete_task':
        case 'toggle_task':
          if (data != null && data['id'] != null) {
            final apiId = data['id'] is int ? data['id'] : int.tryParse(data['id'].toString());
            if (apiId == null) {
              debugPrint('AiChatService: Invalid task ID for $type: ${data['id']}');
              break;
            }

            final task = await _taskRepo.findByApiId(apiId, userEmail);
            if (task == null) {
              debugPrint('AiChatService: Task with API ID $apiId not found locally');
              break;
            }

            if (type == 'update_task') {
              debugPrint('AiChatService: Updating task ${task.id}');
              if (data['judul'] != null) task.title = data['judul'];
              if (data['deskripsi'] != null) task.description = data['deskripsi'];
              if (data['priority'] != null) task.priority = data['priority'];
              if (data['is_completed'] != null) task.isCompleted = data['is_completed'] == true;
              if (data['deadline'] != null) {
                try {
                  final dt = DateTime.parse(data['deadline']);
                  task.dueDate = DateTime(dt.year, dt.month, dt.day);
                  task.dueTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
                } catch (e) {
                  debugPrint('AiChatService: Deadline parse error in update: $e');
                }
              }
              await _taskRepo.updateTask(task);
              _currentStep = 0;
              _totalSteps = 0;
              _sessionType = null;
              _sessionLabel = null;
              onActionMessage?.call('Tugas "${task.title}" berhasil diperbarui.');
            } else if (type == 'delete_task') {
              debugPrint('AiChatService: Deleting task ${task.id}');
              final title = task.title;
              await _taskRepo.deleteTask(task);
              onActionMessage?.call('Tugas "$title" berhasil dihapus.');
            } else {
              debugPrint('AiChatService: Toggling task ${task.id}');
              task.isCompleted = !task.isCompleted;
              await _taskRepo.updateTask(task);
              onActionMessage?.call('Status tugas "${task.title}" berhasil diubah.');
            }
            onTaskChanged?.call();
          }
          break;

        case 'bulk_delete':
          final ids = data?['ids'] as List<dynamic>?;
          if (ids != null) {
            bool changed = false;
            for (final rawId in ids) {
              final apiId = rawId is int ? rawId : int.tryParse(rawId.toString());
              if (apiId != null) {
                final task = await _taskRepo.findByApiId(apiId, userEmail);
                if (task != null) {
                  await _taskRepo.deleteTask(task);
                  changed = true;
                }
              }
            }
            if (changed) {
              onTaskChanged?.call();
              onActionMessage?.call('${ids.length} tugas berhasil dihapus.');
            }
          }
          break;

        case 'bulk_toggle':
          final ids = data?['ids'] as List<dynamic>?;
          final setCompleted = data?['set_completed'] == true;
          if (ids != null) {
            bool changed = false;
            for (final rawId in ids) {
              final apiId = rawId is int ? rawId : int.tryParse(rawId.toString());
              if (apiId != null) {
                final task = await _taskRepo.findByApiId(apiId, userEmail);
                if (task != null) {
                  task.isCompleted = setCompleted;
                  await _taskRepo.updateTask(task);
                  changed = true;
                }
              }
            }
            if (changed) {
              onTaskChanged?.call();
              onActionMessage?.call('Status ${ids.length} tugas berhasil diubah.');
            }
          }
          break;

        case 'start_pomodoro':
          if (data != null && data['todo'] != null) {
            final todoData = data['todo'] as Map<String, dynamic>;
            final task = TaskLocal()
              ..title = todoData['judul'] ?? '⏱️ Pomodoro'
              ..apiId = todoData['id'];
            await _taskRepo.createTask(task, userEmail);
            onTaskChanged?.call();
          }
          break;
          
        case 'duplicate_task':
          if (data != null && data['todo'] != null) {
            final todoData = data['todo'] as Map<String, dynamic>;
            final task = TaskLocal()
              ..title = todoData['judul'] ?? 'Copy'
              ..apiId = todoData['id'];
            await _taskRepo.createTask(task, userEmail);
            onTaskChanged?.call();
            onActionMessage?.call('Tugas berhasil digandakan.');
          }
          break;
      }
    } catch (e) {
      debugPrint('Error executing AI action: $e');
    }
  }

  Future<String> _getUserEmail() async {
    final user = await _authService?.getCachedUser();
    return user?.email ?? 'guest';
  }

  void addLocalMessage(ChatMessage message) {
    _addUniqueMessage(message);
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _messageIds.clear();
    _currentChatId = null;
    _currentStep = 0;
    _totalSteps = 0;
    _sessionLabel = null;
    _sessionType = null;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final List<Map<String, dynamic>> combinedHistory = [];
    final Set<String> backendChatIds = {};

    try {
      final response = await _api.get('/ai/history');
      if (response.statusCode == 200) {
        final data = (response.data as List<dynamic>).cast<Map<String, dynamic>>();
        for (var chat in data) {
          combinedHistory.add(chat);
          backendChatIds.add(chat['id'].toString());
        }
      }
    } catch (e) {
      debugPrint('Fetch history API error: $e');
    }
    
    // Fallback/Merge: load from local Isar
    try {
      final sessions = await _isar.chatSessions.where().sortByUpdatedAtDesc().findAll();
      final backendIdRegex = RegExp(r'\[#(.*?)\]$');
      final cleanTitleRegex = RegExp(r'\s*\[#.*?\]$');

      for (final s in sessions) {
        final match = backendIdRegex.firstMatch(s.title);
        final backendId = match?.group(1);
        
        if (backendId != null && backendId != 'local' && backendChatIds.contains(backendId)) {
          continue;
        }

        combinedHistory.add({
          'id': 'local_${s.id}',
          'title': s.title.replaceAll(cleanTitleRegex, ''),
          'updated_at': s.updatedAt.toIso8601String(),
          'messages_count': s.messageCount,
        });
      }
    } catch (e) {
      debugPrint('Fetch history local error: $e');
    }

    combinedHistory.sort((a, b) {
      final da = DateTime.tryParse(a['updated_at'] ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['updated_at'] ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });

    return combinedHistory;
  }

  Future<void> loadChat(String chatId) async {
    _messages.clear();
    _messageIds.clear();
    
    if (chatId.startsWith('local_')) {
      final sessionId = int.tryParse(chatId.replaceFirst('local_', ''));
      if (sessionId != null) {
        final localMsgs = await _isar.chatMessageLocals
            .where()
            .sessionIdEqualTo(sessionId)
            .sortByTimestamp()
            .findAll();
        
        _currentChatId = chatId;
        for (final m in localMsgs) {
          final reasoning = m.reasoningDetails ?? {};
          final cot = (reasoning['chain_of_thought'] as List<dynamic>?)?.cast<String>() ?? [];
          final mi = reasoning['multi_intent'] as List<dynamic>? ?? [];
          
          _addUniqueMessage(ChatMessage(
            role: m.role,
            content: m.content,
            action: m.action,
            actionResult: m.actionResult,
            quickReplies: m.quickReplies,
            timestamp: m.timestamp,
            reasoningDetails: reasoning,
            chainOfThought: cot,
            multiIntent: mi,
          ));
        }
        notifyListeners();
        return;
      }
    }

    try {
      final response = await _api.get('/ai/history/$chatId');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rawMessages = data['messages'] as List<dynamic>;
        
        _currentChatId = chatId;
        
        for (final m in rawMessages) {
          final role = m['role'] as String;
          final content = m['content'] as String;
          Map<String, dynamic>? msgData = m['data'] is String 
              ? jsonDecode(m['data']) 
              : (m['data'] as Map<String, dynamic>?);
          
          final reasoning = msgData?['reasoning_details'] as Map<String, dynamic>? ?? {};
          final cot = (msgData?['chain_of_thought'] as List<dynamic>?)?.cast<String>() ?? 
                      (reasoning['chain_of_thought'] as List<dynamic>?)?.cast<String>() ?? [];
          final mi = (msgData?['multi_intent'] as List<dynamic>?) ?? 
                     (reasoning['multi_intent'] as List<dynamic>?) ?? [];

          _addUniqueMessage(ChatMessage(
            role: role,
            content: content,
            action: msgData?['action'],
            quickReplies: (msgData?['quick_replies'] as List<dynamic>?)?.cast<String>() ?? [],
            timestamp: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
            reasoningDetails: reasoning,
            chainOfThought: cot,
            multiIntent: mi,
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load chat error: $e');
    }
  }

  Future<bool> deleteChat(String chatId) async {
    if (chatId.startsWith('local_')) {
      final sessionId = int.tryParse(chatId.replaceFirst('local_', ''));
      if (sessionId != null) {
        await _isar.writeTxn(() async {
          await _isar.chatMessageLocals.where().sessionIdEqualTo(sessionId).deleteAll();
          await _isar.chatSessions.delete(sessionId);
        });
        if (_currentChatId == chatId) clearHistory();
        return true;
      }
    }

    try {
      final response = await _api.delete('/ai/history/$chatId');
      if (response.statusCode == 200) {
        if (_currentChatId == chatId) clearHistory();
        return true;
      }
    } catch (e) {
      debugPrint('Delete chat error: $e');
    }
    return false;
  }

  Stream<String> streamChat(String userMessage) async* {
    if (_isRequestInProgress) return;
    _isRequestInProgress = true;

    _cancelToken = CancelToken();
    final userMsg = ChatMessage(role: 'user', content: userMessage);
    _addUniqueMessage(userMsg);

    final historyMessages = _messages.length <= 21
        ? _messages.sublist(0, _messages.length - 1)
        : _messages.sublist(_messages.length - 21, _messages.length - 1);
    final history = historyMessages.map((m) => m.toHistoryMap()).toList();

    try {
      final response = await _api.postStream('/ai/stream', data: {
        'message': userMessage,
        'history': history,
        'chat_id': _currentChatId,
      });

      final stream = response.data?.stream;
      if (stream == null) return;

      String fullText = '';
      Map<String, dynamic>? finalAction;
      List<String> finalQuickReplies = [];
      List<String> finalChainOfThought = [];
      List<dynamic> finalMultiIntent = [];

      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        
        final lines = text.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]') continue;
            
            try {
              final data = jsonDecode(jsonStr);
              if (data['type'] == 'message') {
                final content = data['content'] as String;
                fullText += content;
                
                _currentStep = data['current_step'] ?? _currentStep;
                _totalSteps = data['total_steps'] ?? _totalSteps;
                _sessionLabel = data['session_label'] ?? _sessionLabel;
                _sessionType = data['session_type'] ?? _sessionType;
                if (data['compute_device'] != null) {
                  _computeDevice = data['compute_device'].toString().toUpperCase();
                }
                
                if (data['chain_of_thought'] != null) {
                  finalChainOfThought = (data['chain_of_thought'] as List<dynamic>).cast<String>();
                }
                if (data['multi_intent'] != null) {
                  finalMultiIntent = data['multi_intent'] as List<dynamic>;
                }
                
                yield content;
              } else if (data['type'] == 'action') {
                finalAction = data['action'];
              } else if (data['type'] == 'quick_replies') {
                finalQuickReplies = (data['data'] as List<dynamic>?)?.cast<String>() ?? [];
              } else if (data['type'] == 'chat_id') {
                _currentChatId = data['id'].toString();
              }
            } catch (e) {
              debugPrint('Error parsing SSE chunk: $e');
            }
          }
        }
      }

      final aiMsg = ChatMessage(
        role: 'assistant',
        content: fullText,
        action: finalAction,
        quickReplies: finalQuickReplies,
        chainOfThought: finalChainOfThought,
        multiIntent: finalMultiIntent,
        reasoningDetails: {
          if (finalChainOfThought.isNotEmpty) 'chain_of_thought': finalChainOfThought,
          if (finalMultiIntent.isNotEmpty) 'multi_intent': finalMultiIntent,
        },
      );
      _addUniqueMessage(aiMsg);

      try {
        final localSessionId = await _getOrCreateLocalSession(_currentChatId, userMessage);
        await _saveMessageToLocal(userMsg, localSessionId);
        await _saveMessageToLocal(aiMsg, localSessionId);
      } catch (e) {
        debugPrint('Local save error (stream): $e');
      }

      if (aiMsg.hasAction) {
        await _executeAction(aiMsg);
      }

      _cancelToken = null;
      _isRequestInProgress = false;
      notifyListeners();
    } catch (e) {
      _isRequestInProgress = false;
      if (e is DioException && e.type == DioExceptionType.cancel) {
        if (_messages.isNotEmpty && _messages.last.role == 'user') {
          _messages.removeLast();
        }
        _cancelToken = null;
        notifyListeners();
        return;
      }
      debugPrint('AI Stream error: $e');
      yield '\n[Connection error]';
      _cancelToken = null;
    }
  }
  
  // Expert Insights Endpoints (v12.1)
  Future<Map<String, dynamic>?> fetchMentalLoad() async {
    try {
      final response = await _api.get('/ai/experts/mental-load');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching mental load: $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchExpertInsights() async {
    try {
      final response = await _api.get('/ai/experts/insights');
      if (response.data != null && response.data['success'] == true) {
        // Wrap in a list to match the UI expectation if needed
        return [response.data];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching expert insights: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchHabitRecommendations() async {
    try {
      final response = await _api.get('/ai/experts/habits');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching habits: $e');
      return null;
    }
  }

  Future<void> updateVoicePreferences(Map<String, dynamic> prefs) async {
    try {
      await _api.post('/ai/voice-preference', data: prefs);
    } catch (e) {
      debugPrint('Error updating voice preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getVoicePreferences() async {
    try {
      final response = await _api.get('/ai/voice-preference');
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting voice preferences: $e');
      return null;
    }
  }
}
