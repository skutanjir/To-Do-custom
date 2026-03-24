// lib/features/ai_chat/services/voice_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdbl_testing_custom_mobile/core/services/settings_service.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/ai_chat_service.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/core/services/alarm_service.dart';
import 'package:flutter/material.dart';

enum JarvisState { idle, passive, wakeDetected, active, processing, speaking }

class VoiceService extends ChangeNotifier {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AuthService? authService;
  final SettingsService? settingsService;
  late final AiChatService _chatService;

  JarvisState _state = JarvisState.idle;
  JarvisState get state => _state;

  String? _systemLocale;
  String? get systemLocale => _systemLocale;

  String _lastWords = '';
  String get lastWords => _lastWords;

  String _aiResponse = '';
  String get aiResponse => _aiResponse;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _bargeInActive = false;
  bool _isStopped = false;

  final List<VoidCallback> _stateListeners = [];
  ValueChanged<String>? onPartialResult;
  ValueChanged<String>? onAiResponse;
  VoidCallback? onWakeWordDetected;
  VoidCallback? onDismiss;

  // Store best voices for each language
  Map<String, dynamic>? _bestEnglishVoice;
  Map<String, dynamic>? _bestIndoVoice;

  void addStateListener(VoidCallback listener) => _stateListeners.add(listener);
  void removeStateListener(VoidCallback listener) => _stateListeners.remove(listener);

  bool _isStartingListening = false;
  bool _isConfirmingExit = false;

  Timer? _speechWatchdog;
  Timer? _keepAliveTimer;
  DateTime _lastRestartAttempt = DateTime.now().subtract(const Duration(seconds: 10));
  static const _restartCooldown = Duration(milliseconds: 1000);

  VoiceService({this.authService, this.settingsService}) {
    _chatService = AiChatService(authService: authService);
    
    // Listen to chat service for external updates (e.g. from UI)
    _chatService.addListener(() {
      notifyListeners();
    });
    
    // Listen for setting changes
    settingsService?.addListener(() {
      if (settingsService?.isJarvisVoiceEnabled == false) {
        _stt.cancel();
        _setState(JarvisState.idle);
      } else {
        // Gender might have changed, re-init voices
        _initializeVoices();
        
        // Sync back to backend (Phase 6)
        if (settingsService != null) {
          _chatService.updateVoicePreferences({
            'gender': settingsService!.jarvisGender,
            'language': _isIndonesian(_lastWords) ? 'id' : 'en',
          });
        }

        if (_state == JarvisState.idle) {
          startPassiveListening();
        }
      }
    });

    // Initialize TTS completion handler early
    _tts.setCompletionHandler(() {
      _stopWatchdog();
      _onSpeechCompleted();
    });

    // Load alarms
    _alarmService = AlarmService();

    // Sync voice preferences from backend
    _syncVoicePreferences();
  }

  late final AlarmService _alarmService;
  AlarmService get alarmService => _alarmService;

  void _stopWatchdog() {
    _speechWatchdog?.cancel();
    _speechWatchdog = null;
  }

  void _onSpeechCompleted() {
    debugPrint('Jarvis: Speech Completed. (State: $_state)');
    if (_state == JarvisState.speaking) {
      final text = _aiResponse.toLowerCase();
      
      if (text.contains('stand-by') || text.contains('standing by')) {
        startPassiveListening();
        onDismiss?.call();
        return;
      }

      // ALWAYS go to active listening after speaking so user can respond,
      // but only if we're not already listening (from barge-in)
      if (!_stt.isListening) {
        _startActiveListening();
      } else {
        _setState(JarvisState.active);
      }
    }
  }

  Future<void> _syncVoicePreferences() async {
    final prefs = await _chatService.getVoicePreferences();
    if (prefs != null) {
      final gender = prefs['gender'] as String?;
      if (gender != null && gender != settingsService?.jarvisGender) {
        settingsService?.setJarvisGender(gender);
        forceSetGender();
      }
    }
  }

  Future<void> initialize() async {
    try {
      _isAvailable = await _stt.initialize(
        debugLogging: true,
        onError: (error) {
          debugPrint('STT Error: ${error.errorMsg} (State: $_state)');
          if (error.errorMsg == 'error_busy') {
            debugPrint('Jarvis: STT Busy, backing off...');
            return;
          }
          _debouncedRestart();
        },
        onStatus: (status) {
          debugPrint('STT Status: $status (State: $_state)');
          if (status == 'done') {
            if (_state == JarvisState.active) {
              _processCommand();
            } else if (_state == JarvisState.passive) {
              _debouncedRestart();
            }
          } else if (status == 'notListening') {
            if (_state == JarvisState.passive || (_state == JarvisState.active && _lastWords.isEmpty)) {
              _debouncedRestart();
            }
          }
        },
      );

      if (_isAvailable) {
        final system = await _stt.systemLocale();
        _systemLocale = system?.localeId;
        debugPrint('System STT Locale: $_systemLocale');
      }
      
      await _initializeVoices();
    } catch (e) {
      debugPrint('Voice init error: $e');
      _isAvailable = false;
    }
  }

  Future<void> _initializeVoices({int retries = 3}) async {
    try {
      var voices = await _tts.getVoices;
      
      if ((voices == null || voices.isEmpty) && retries > 0) {
        debugPrint('Jarvis: Voices not ready, retrying ($retries left)...');
        await Future.delayed(const Duration(milliseconds: 500));
        return _initializeVoices(retries: retries - 1);
      }

      if (voices != null) {
        final gender = settingsService?.jarvisGender ?? 'male';
        debugPrint('Jarvis: ═══════════════════════════════════════');
        debugPrint('Jarvis: Voice init for gender: $gender');
        debugPrint('Jarvis: Total voices available: ${voices.length}');
        
        // DUMP all Indonesian and English voices so we can see what's available
        for (final v in voices) {
          final locale = (v['locale'] as String).toLowerCase();
          if (locale.startsWith('id') || locale.startsWith('en')) {
            debugPrint('  Voice: ${v['name']} | Locale: ${v['locale']}');
          }
        }
        debugPrint('Jarvis: ═══════════════════════════════════════');
        
        _bestEnglishVoice = null;
        _bestIndoVoice = null;
        
        _bestEnglishVoice = _findBestVoice(voices, 'en', gender);
        _bestIndoVoice = _findBestVoice(voices, 'id', gender);
        
        debugPrint('Jarvis: SELECTED Indo voice = ${_bestIndoVoice?["name"] ?? "NONE"}');
        debugPrint('Jarvis: SELECTED English voice = ${_bestEnglishVoice?["name"] ?? "NONE"}');
        
        if (_bestIndoVoice != null) {
          await _tts.setLanguage(_bestIndoVoice!["locale"]);
          await _tts.setVoice({"name": _bestIndoVoice!["name"], "locale": _bestIndoVoice!["locale"]});
        }
      }

      // Use pitch as a reliable gender differentiator
      final isMale = (settingsService?.jarvisGender ?? 'male') == 'male';
      final double finalPitch = isMale ? 0.5 : 1.4;
      await _tts.setPitch(finalPitch);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      debugPrint('Jarvis: TTS initialized with pitch $finalPitch (${isMale ? "male" : "female"})');
    } catch (e) {
      debugPrint('TTS voice init error: $e');
    }
  }

  /// Force re-initialization of voices when gender settings change
  Future<void> forceSetGender() async {
    debugPrint('Jarvis: Forcing gender re-init...');
    _bestEnglishVoice = null;
    _bestIndoVoice = null;
    await _initializeVoices();
    notifyListeners();
  }

  Map<String, dynamic>? _findBestVoice(List<dynamic> voices, String langCode, String gender) {
    final isMale = gender == 'male';

    // Priority list: most specific match first, then gender keyword, then gender-opposite as last resort
    final List<bool Function(String, String)> priorities;

    if (langCode == 'id') {
      priorities = [
        // Exact Google TTS voice IDs for Indonesian (idc, dfg, g, e are often male)
        (name, locale) => (name.contains(isMale ? 'id-id-x-idc' : 'id-id-x-ida')) && locale.contains('id'),
        (name, locale) => (name.contains(isMale ? 'id-id-x-dfg' : 'id-id-x-afg')) && locale.contains('id'),
        (name, locale) => (name.contains(isMale ? 'id-id-x-g' : 'id-id-x-a')) && locale.contains('id'),
        (name, locale) => (name.contains(isMale ? 'id-id-x-e' : 'id-id-x-b')) && locale.contains('id'),
        // Samsung/Generic male/female keywords
        (name, locale) => locale.contains('id') && (isMale ? (name.contains('male') || name.contains('masculine') || name.contains('pria')) : (name.contains('female') || name.contains('feminine') || name.contains('wanita'))),
        // Network/Cloud voices often have "pria" or "wanita" in Indonesian locales
        (name, locale) => locale.contains('id') && name.contains(isMale ? 'pria' : 'wanita'),
        // Voice name heuristics
        (name, locale) => locale.contains('id') && name.contains(isMale ? 'id-id-x-d' : 'id-id-x-a'),
      ];
    } else {
      priorities = [
        // Exact Google TTS voice IDs for British English (Jarvis priority)
        (name, locale) => name.contains(isMale ? 'en-gb-x-rjs' : 'en-gb-x-fis') && locale.contains('en-gb'),
        (name, locale) => name.contains(isMale ? 'en-gb-x-gba' : 'en-gb-x-gbb') && locale.contains('en-gb'),
        // US English fallbacks
        (name, locale) => name.contains(isMale ? 'en-us-x-sfg' : 'en-us-x-tpc') && locale.contains('en'),
        (name, locale) => name.contains(isMale ? 'en-us-x-iol' : 'en-us-x-tpd') && locale.contains('en'),
        // Gender keyword match (Inclusive of Samsung/Network voices)
        (name, locale) => locale.contains('en') && (isMale ? (name.contains('male') || name.contains('guy') || name.contains('man')) : (name.contains('female') || name.contains('girl') || name.contains('woman'))),
        // Locale fallback for en-GB
        (name, locale) => locale.contains('en-gb'),
      ];
    }

    for (final matcher in priorities) {
      for (final voice in voices) {
        final name = (voice['name'] as String).toLowerCase();
        final locale = (voice['locale'] as String).toLowerCase().replaceAll('_', '-');
        if (matcher(name, locale)) {
          debugPrint('Jarvis: Matched voice "$name" ($locale) for $langCode/$gender');
          return voice;
        }
      }
    }
    
    // Last resort: just pick any voice for this language
    for (final voice in voices) {
      final locale = (voice['locale'] as String).toLowerCase();
      if (locale.startsWith(langCode)) {
        debugPrint('Jarvis: Fallback voice "${voice['name']}" ($locale) for $langCode/$gender');
        return voice;
      }
    }
    
    debugPrint('Jarvis: No voice found at all for $langCode/$gender');
    return null;
  }

  void _setState(JarvisState newState) {
    debugPrint('Jarvis State Transition: $_state -> $newState');
    _state = newState;
    for (final listener in _stateListeners) {
      listener();
    }
    notifyListeners();
  }

  bool _containsWakeWord(String input) {
    final lowerInput = input.toLowerCase();
    final universalTriggers = [
      'jarvis', 'jarves', 'jarviz', 'jarv', 'yarvis', 'garvis', 'jarbis', 
      'jervis', 'jarvice', 'arvis', 'ervis', 'irvis', 'jarbi', 'jarpis'
    ];

    for (final trigger in universalTriggers) {
      if (lowerInput.contains(trigger)) return true;
    }

    for (final variant in universalTriggers) {
      final words = lowerInput.split(' ');
      for (final word in words) {
        final score = _calculateSimilarity(word, variant);
        if (score > 0.75) return true;
      }
    }
    return false;
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    int editDistance(String a, String b) {
      final m = a.length, n = b.length;
      final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
      for (var i = 0; i <= m; i++) {
        dp[i][0] = i;
      }
      for (var j = 0; j <= n; j++) {
        dp[0][j] = j;
      }
      for (var i = 1; i <= m; i++) {
        for (var j = 1; j <= n; j++) {
          final cost = a[i - 1] == b[j - 1] ? 0 : 1;
          dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
              .reduce((min, val) => val < min ? val : min);
        }
      }
      return dp[m][n];
    }
    final distance = editDistance(s1, s2);
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLen);
  }

  void _debouncedRestart() {
    final now = DateTime.now();
    if (now.difference(_lastRestartAttempt) < _restartCooldown) {
      debugPrint('Jarvis: Debounced restart too soon (${now.difference(_lastRestartAttempt).inMilliseconds}ms < 3000ms)');
      return;
    }
    
    // Additional check to avoid restarting while already starting or already listening
    if (_isStartingListening || _stt.isListening) return;

    _lastRestartAttempt = now;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isStopped) return;
      if (_state == JarvisState.passive) {
        debugPrint('Jarvis: Debounced restart -> Passive');
        startPassiveListening();
      } else if (_state == JarvisState.active && !_stt.isListening) {
        debugPrint('Jarvis: Debounced restart -> Active');
        _startActiveListening();
      }
    });
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_stt.isListening && !_isStartingListening && (_state == JarvisState.passive || _state == JarvisState.active)) {
        debugPrint('Jarvis: KeepAlive triggering restart...');
        _debouncedRestart();
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  Future<void> startPassiveListening() async {
    if (settingsService?.isJarvisVoiceEnabled == false) return;
    if (!_isAvailable) return;
    if (_isStartingListening) return;
    _isStopped = false;
    
    // Cancel any existing listening session before starting a new one
    if (_stt.isListening) {
      await _stt.stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isStartingListening = true;
    try {
      _setState(JarvisState.passive);
      await _stt.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          if (words.isNotEmpty && _containsWakeWord(words)) {
            _onWakeWordDetected();
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
        ),
        localeId: _systemLocale ?? 'en-US',
        listenFor: const Duration(hours: 1),
        pauseFor: const Duration(seconds: 30),
      );
      debugPrint('Jarvis: Passive listening started successfully.');
      _startKeepAlive();
    } catch (e) {
      debugPrint('Jarvis: Passive listen error: $e');
    } finally {
      _isStartingListening = false;
    }
  }

  void _onWakeWordDetected() {
    debugPrint('Wake Word Detected!');
    _stt.stop();
    _setState(JarvisState.wakeDetected);
    onWakeWordDetected?.call();
    
    _alarmService.refreshUpcomingAlarms(_getUserEmailSync());

    final hour = DateTime.now().hour;
    if (hour < 11) {
      _aiResponse = 'Selamat pagi, Kak. Ada yang bisa saya bantu hari ini?';
    } else if (hour < 15) {
      _aiResponse = 'Selamat siang, Kak. Apa ada tugas yang perlu saya catat?';
    } else if (hour < 18) {
      _aiResponse = 'Selamat sore, Kak. Bagaimana progres hari ini?';
    } else {
      _aiResponse = 'Selamat malam, Kak. Ada perintah tambahan sebelum beristirahat?';
    }
    
    onAiResponse?.call(_aiResponse);
    _safeSpeak(_aiResponse);
  }

  String _getUserEmailSync() {
    return 'guest'; // Simplified for now
  }

  void activate() => _onWakeWordDetected();

  Future<void> _startActiveListening() async {
    if (!_isAvailable) return;
    _isStopped = false;
    _lastWords = '';
    _aiResponse = '';
    
    // Cancel existing STT before starting active
    if (_stt.isListening) {
      await _stt.cancel();
    }
    
    _setState(JarvisState.active);
    try {
      await _stt.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onPartialResult?.call(_lastWords);
          if (result.finalResult && _lastWords.isNotEmpty) _processCommand();
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          onDevice: true,
        ),
        localeId: _systemLocale ?? 'en-US', 
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),
      );
      debugPrint('Jarvis: Active listening started.');
      _startKeepAlive();
    } catch (e) {
      debugPrint('Active listen error: $e');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state == JarvisState.active) {
          startPassiveListening();
          onDismiss?.call();
        }
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN COMMAND PROCESSOR
  // ═══════════════════════════════════════════════════════════════

  /// Public method to process arbitrary text as a voice command
  Future<void> processText(String text) async {
    _lastWords = text;
    await _processCommand();
  }

  Future<void> _processCommand() async {
    final input = _lastWords.trim();
    if (input.isEmpty) {
      debugPrint('Jarvis: No words captured.');
      _startActiveListening();
      return;
    }
    
    // Check for exit
    final lower = input.toLowerCase();
    if (_isConfirmingExit) {
      _isConfirmingExit = false;
      final positiveConfirm = ['ya', 'iya', 'cukup', 'sudah', 'yes', 'yup', 'okay', 'sip', 'benar', 'betul'];
      if (positiveConfirm.any((pc) => lower == pc || lower.contains(pc))) {
        _aiResponse = _isIndonesian(input) ? 'Baik Kak, sistem stand-by.' : 'Alright, system standing by.';
        onAiResponse?.call(_aiResponse);
        _safeSpeak(_aiResponse);
        return;
      }
    }

    final exitKeywords = ['sudah cukup', 'cukup', 'selesai', 'stop', 'berhenti', 'tutup', 'exit', 'out', 'keluar', 'batal'];
    
    // v12.1: Fuzzy matching for critical voice commands
    bool matchedExit = false;
    for (final kw in exitKeywords) {
      if (lower.contains(kw) || _calculateSimilarity(lower, kw) > 0.8) {
        matchedExit = true;
        break;
      }
    }

    if (matchedExit) {
      _isConfirmingExit = true;
      _aiResponse = _isIndonesian(input) 
          ? 'Baik Kak, apakah sudah cukup atau ada lagi yang bisa saya bantu?' 
          : 'Understood. Is that everything, or is there anything else I can assist with?';
      onAiResponse?.call(_aiResponse);
      _safeSpeak(_aiResponse);
      return;
    }

    _setState(JarvisState.processing);
    try {
      // Let backend handle ALL command logic (create, edit, delete, etc.)
      // AiChatService.sendMessage handles context and actions internally
      final response = await _chatService.sendMessage(input);

      _aiResponse = response.content;

      // Clean persona names if backend includes them
      _aiResponse = _aiResponse.replaceAll(RegExp(r'\b(Sir|sir|User|user|Fajar|fajar|Tuan|tuan)\b'), 'Kak');
      
      onAiResponse?.call(_aiResponse);
      _safeSpeak(_aiResponse);
    } catch (e) {
      debugPrint('Jarvis command error: $e');
      _aiResponse = _isIndonesian(input) ? 'Maaf Kak, saya sedang mengalami gangguan koneksi.' : 'Apologies, I am experiencing connection difficulties.';
      onAiResponse?.call(_aiResponse);
      _safeSpeak(_aiResponse);
    }
  }

  bool _isIndonesian(String text) {
    final lower = text.toLowerCase();
    final indoKeywords = ['saya', 'bisa', 'ada', 'tugas', 'anda', 'kamu', 'apa', 'yang', 'sudah', 'telah', 'buat', 'hapus', 'besok', 'hari', 'jam', 'cukup', 'selesai', 'bantu', 'siap', 'tuan', 'prioritas', 'deskripsi', 'judul', 'deadline', 'lewati'];
    return indoKeywords.any((word) => lower.contains(word));
  }

  String _cleanTextForSpeech(String text) {
    if (text.isEmpty) return '';
    var cleaned = text.replaceAll(RegExp(r'```[\s\S]*?```'), ''); 
    cleaned = cleaned.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), (match) => match.group(1) ?? '');
    cleaned = cleaned.replaceAll(RegExp(r'^[\s]*([-*+]|[0-9]+\.)\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'[`*#_~|>]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\\\/@\^&\$\[\]\{\}+=<>]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\r\n]+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  /// Automatically speak a reminder for a task that is ending soon.
  Future<void> speakProactiveReminder({
    required String taskName,
    required int daysLeft,
    bool isIndonesian = true,
    String? customText,
  }) async {
    if (_state == JarvisState.speaking) return; // Don't interrupt if already speaking
    
    final text = customText ?? (isIndonesian
        ? 'Kak, ada tugas $taskName yang belum Anda selesaikan dan akan berakhir dalam $daysLeft hari.'
        : 'Hi, just a reminder that you have an unfinished task named $taskName that is due in $daysLeft days.');
    
    _aiResponse = text;
    onAiResponse?.call(_aiResponse);
    await _safeSpeak(text);
  }

  Future<void> _safeSpeak(String text) async {
    _setState(JarvisState.speaking);
    _stopWatchdog();
    _stopKeepAlive(); // Stop keepalive while speaking
    
    // Gender-based pitch: male = lower, female = higher
    final isMale = (settingsService?.jarvisGender ?? 'male') == 'male';
    final genderPitch = isMale ? 0.5 : 1.4;
    
    try {
      final isIndo = _isIndonesian(text);
      if (isIndo) {
        debugPrint('Jarvis: Detected Indonesian text.');
        await _tts.setLanguage('id-ID');
        if (_bestIndoVoice != null) {
          debugPrint('Jarvis: Speaking with best Indo voice: ${_bestIndoVoice!["name"]} (pitch=$genderPitch)');
          await _tts.setVoice({"name": _bestIndoVoice!["name"], "locale": _bestIndoVoice!["locale"]});
        }
        await _tts.setPitch(genderPitch);
        await _tts.setSpeechRate(0.5);
      } else {
        debugPrint('Jarvis: Detected English text.');
        await _tts.setLanguage('en-GB'); // Prioritize British for the Butler feel
        if (_bestEnglishVoice != null) {
          debugPrint('Jarvis: Speaking with best English voice: ${_bestEnglishVoice!["name"]} (pitch=$genderPitch)');
          await _tts.setVoice({"name": _bestEnglishVoice!["name"], "locale": _bestEnglishVoice!["locale"]});
        } else {
          debugPrint('Jarvis: No specific English voice, using default en-GB TTS.');
        }
        await _tts.setPitch(genderPitch);
        await _tts.setSpeechRate(0.55);
      }

      final speakText = _cleanTextForSpeech(text);
      if (speakText.isEmpty) {
        startPassiveListening();
        onDismiss?.call();
        return;
      }
      
      final finalSpeech = speakText.length > 500 ? '${speakText.substring(0, 500)}...' : speakText;
      
      final durationSeconds = (finalSpeech.length / 10).ceil() + 5;
      _speechWatchdog = Timer(Duration(seconds: durationSeconds), () {
        debugPrint('Jarvis: Speech Watchdog Fired!');
        _onSpeechCompleted();
      });

      await _tts.speak(finalSpeech);

      // BARGE-IN: Start listening while speaking (with a small delay to avoid resource contention)
      if (_isAvailable && _state == JarvisState.speaking) {
        _bargeInActive = false;
        // Reduced delay for faster interruption
        Future.delayed(const Duration(milliseconds: 400), () async {
          if (_isStopped) return;
          if (_state != JarvisState.speaking) return; 

          debugPrint('Jarvis: Starting Barge-in listening...');
          await _stt.listen(
            onResult: (result) {
              if (_state != JarvisState.speaking || _bargeInActive) return;

              final words = result.recognizedWords.trim();
              final wordCount = words.split(RegExp(r'\s+')).length;

              // Threshold: 1+ word for more responsive hands-free interruption
              if (words.isNotEmpty && wordCount >= 1) {
                _bargeInActive = true;
                debugPrint('Jarvis: Barge-in detected ("$words")! Switching to ACTIVE LISTENING.');
                
                _stopWatchdog();
                _tts.stop();
                _lastWords = words;
                
                // Switch state to trigger UI changes immediately
                _setState(JarvisState.active);
                onPartialResult?.call(words);
                
                // Force restart listening to focus on the new command if final
                if (result.finalResult) {
                  _bargeInActive = false;
                  _processCommand();
                }
              }
            },
            listenOptions: SpeechListenOptions(
              cancelOnError: false,
              partialResults: true,
              listenMode: ListenMode.dictation,
            ),
            localeId: _systemLocale ?? 'en-US',
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
          );
        });
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _onSpeechCompleted();
    }
  }

  /// Manually cut off Jarvis and start listening immediately
  void stopSpeaking({bool restartActive = false}) {
    if (_state == JarvisState.speaking) {
      debugPrint('Jarvis: Stopping speech.');
      _stopWatchdog();
      _tts.stop();
      if (restartActive) {
        _startActiveListening();
      } else {
        _setState(JarvisState.passive);
        startPassiveListening();
      }
    }
  }

  void stop() {
    _isStopped = true;
    _stopWatchdog();
    _stopKeepAlive();
    try { _stt.cancel(); } catch (_) {}
    try { _tts.stop(); } catch (_) {}
    _setState(JarvisState.idle);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
