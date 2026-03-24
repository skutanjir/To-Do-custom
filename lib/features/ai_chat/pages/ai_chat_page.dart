// lib/features/ai_chat/pages/ai_chat_page.dart
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:dio/dio.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_message.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/ai_chat_service.dart';

class AiChatPage extends StatefulWidget {
  final AuthService? authService;
  const AiChatPage({super.key, this.authService});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AiChatService _chatService;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String _streamingText = '';
  List<Map<String, dynamic>> _history = [];

  bool _isListening = false;
  final SpeechToText _stt = SpeechToText();
  bool _sttAvailable = false;
  String _voicePartial = '';

  @override
  void initState() {
    super.initState();
    _chatService = AiChatService(authService: widget.authService);
    _chatService.addListener(_onChatChanged);
    AiChatService.onActionMessage = (msg) => _showSnack(msg);
    _loadHistory();
    _initStt();
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChatChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom(force: true);
    }
  }

  Future<void> _loadHistory() async {
    final history = await _chatService.fetchHistory();
    if (mounted) setState(() => _history = history);
  }

  void _startNewChat() {
    _chatService.clearHistory();
    _loadHistory();
  }

  Future<void> _onChatSelected(String chatId) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    await _chatService.loadChat(chatId);
    if (mounted) {
      setState(() => _isLoading = false);
      _scrollToBottom(force: true);
    }
  }

  Future<void> _deleteChat(String chatId) async {
    final success = await _chatService.deleteChat(chatId);
    if (success) _loadHistory();
  }

  Future<void> _initStt() async {
    try {
      _sttAvailable = await _stt.initialize(
        onError: (e) => debugPrint('STT Error: ${e.errorMsg}'),
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && mounted && _isListening) {
            setState(() => _isListening = false);
            if (_voicePartial.isNotEmpty) {
              _textController.text = _voicePartial;
              _voicePartial = '';
              _handleUserInput();
            }
          }
        },
      );
    } catch (e) {
      debugPrint('STT init error: $e');
    }
  }

  void _handleUserInput() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading || _chatService.isRequestInProgress) return;
    _textController.clear();
    _sendToBackend(text);
  }

  Future<void> _sendToBackend(String text) async {
    setState(() { _isLoading = true; _streamingText = ''; });
    _scrollToBottom(force: true);

    try {
      final stream = _chatService.streamChat(text);
      String buffer = '';
      DateTime lastUpdate = DateTime.now();

      await for (final chunk in stream) {
        if (!mounted) break;
        buffer += chunk;
        
        final now = DateTime.now();
        if (now.difference(lastUpdate).inMilliseconds > 50) {
          setState(() {
            _streamingText += buffer;
            buffer = '';
          });
          lastUpdate = now;
          _scrollToBottom();
        }
      }
      
      if (buffer.isNotEmpty && mounted) {
        setState(() {
          _streamingText += buffer;
          buffer = '';
        });
      }
      
      if (mounted) setState(() => _streamingText = '');
      await _loadHistory();
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        _addAiMessage('Maaf, Jarvis sedang mengalami gangguan koneksi.');
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); _scrollToBottom(force: true); }
    }
  }

  void _addAiMessage(String text) {
    _chatService.addLocalMessage(ChatMessage(role: 'assistant', content: text));
  }

  DateTime _lastScrollTime = DateTime.now();

  Widget _buildComputeBadge() {
    final device = _chatService.computeDevice;
    final isGpu = device == 'GPU';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isGpu ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isGpu ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isGpu ? Icons.speed_rounded : Icons.memory_rounded, size: 10, color: isGpu ? const Color(0xFF059669) : Colors.grey),
          const SizedBox(width: 4),
          Text(
            device,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isGpu ? const Color(0xFF059669) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom({bool force = false}) {
    final now = DateTime.now();
    if (!force && now.difference(_lastScrollTime).inMilliseconds < 250) return;
    _lastScrollTime = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoice() async {
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_sttAvailable) { _showSnack('Voice not available'); return; }
    setState(() { _isListening = true; _voicePartial = ''; });
    try {
      final systemLocale = await _stt.systemLocale();
      await _stt.listen(
        onResult: (result) {
          if (mounted) {
            setState(() => _voicePartial = result.recognizedWords);
            if (result.finalResult && _voicePartial.isNotEmpty) {
              _textController.text = _voicePartial;
              _voicePartial = '';
              setState(() => _isListening = false);
              _handleUserInput();
            }
          }
        },
        localeId: systemLocale?.localeId ?? 'en-US',
      );
    } catch (e) { if (mounted) setState(() => _isListening = false); }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1E293B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) {
    final messages = _chatService.messages;
    final inSession = _chatService.totalSteps > 0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.menu_open_rounded, color: Color(0xFF64748B)), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Jarvis', style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(width: 8),
                _buildComputeBadge(),
              ],
            ),
            if (inSession) Text('GUIDED SESSION', style: TextStyle(color: Colors.amber.shade700, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          if (_isLoading && _chatService.isCancellable)
            IconButton(icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent, size: 22), onPressed: () => _chatService.cancelCurrentRequest()),
          IconButton(icon: const Icon(Icons.add_comment_outlined, color: Color(0xFF64748B), size: 22), onPressed: _startNewChat),
        ],
      ),
      body: Column(
        children: [
          if (inSession) _buildSessionProgressBar(),
          Expanded(
            child: messages.isEmpty && !_isLoading
                ? _buildWelcomeState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isLoading) return _buildTypingIndicator();
                      final msg = messages[index];
                      return Column(
                        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          _MessageBubble(message: msg),
                          if (msg.isAssistant && msg.hasQuickReplies && index == messages.length - 1 && !_isLoading)
                            _QuickReplyChips(replies: msg.quickReplies, onTap: (r) { _textController.text = r; _handleUserInput(); }),
                        ],
                      );
                    },
                  ),
          ),
          if (_isListening && _voicePartial.isNotEmpty) _buildVoicePartial(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSessionProgressBar() {
    final svc = _chatService;
    final current = svc.currentStep; final total = svc.totalSteps;
    if (svc.sessionType == 'create' && total == 5) {
      final steps = ['Title', 'Desc', 'Date', 'Time', 'Prio'];
      return Container(
        padding: const EdgeInsets.all(16), color: Colors.white,
        child: Row(
          children: List.generate(5, (i) {
            final active = i == current - 1; final done = i < current - 1;
            return Expanded(
              child: Column(
                children: [
                  Container(height: 4, margin: EdgeInsets.only(right: i < 4 ? 4 : 0), decoration: BoxDecoration(color: done ? Colors.green.shade400 : active ? Colors.indigo : Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 6),
                  Text(steps[i], style: TextStyle(fontSize: 8, color: active ? Colors.indigo : Colors.grey, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 30)]),
            child: const Icon(Icons.auto_awesome, color: Colors.indigo, size: 40),
          ),
          const SizedBox(height: 24),
          const Text('Jarvis AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          const Text('Bagaimana saya bisa membantu Tuan hari ini?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildVoicePartial() {
    return Container(
      width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(16)),
      child: Text(_voicePartial, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.indigo.shade800)),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          IconButton(icon: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded, color: _isListening ? Colors.indigo : const Color(0xFF94A3B8)), onPressed: _toggleVoice),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
              child: TextField(controller: _textController, focusNode: _focusNode, decoration: const InputDecoration(hintText: 'Ketik pesan...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))), onSubmitted: (_) => _handleUserInput()),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleUserInput,
            child: Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)])), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (_streamingText.isNotEmpty) return _MessageBubble(message: ChatMessage(role: 'assistant', content: _streamingText));
    return const Padding(padding: EdgeInsets.only(bottom: 16), child: _JarvisThinking());
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text('CHAT HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 2)),
          const SizedBox(height: 20),
          Expanded(
            child: _history.isEmpty
                ? const Center(child: Text('Kosong', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final chat = _history[index]; final isCurrent = chat['id'].toString() == _chatService.currentChatId;
                      return ListTile(
                        leading: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isCurrent ? Colors.indigo : Colors.transparent)),
                        title: Text(chat['title'] ?? 'Chat', maxLines: 1, style: TextStyle(color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF64748B), fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                        onTap: () => _onChatSelected(chat['id'].toString()),
                        trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Color(0xFFCBD5E1)), onPressed: () => _deleteChat(chat['id'].toString())),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(width: 32, height: 32, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.indigo), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: SelectableText(message.content, style: TextStyle(fontSize: 14, height: 1.5, color: isUser ? Colors.white : const Color(0xFF334155))),
                ),
                if (message.chainOfThought.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _ChainOfThoughtWidget(steps: message.chainOfThought),
                ],
                if (message.multiIntent.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _MultiIntentSummary(results: message.multiIntent),
                ],
                if (message.hasAction) ...[const SizedBox(height: 8), _ActionCard(action: message.action!)],
                if (message.hasActionResult) ...[const SizedBox(height: 8), _ActionResultCard(result: message.actionResult!)],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiIntentSummary extends StatelessWidget {
  final List<dynamic> results;
  const _MultiIntentSummary({required this.results});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'BATCH EXECUTION (${results.length})',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...results.map((r) {
            final success = r['success'] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(success ? Icons.check : Icons.close, size: 10, color: success ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r['command'] ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: success ? Colors.green.shade800 : Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChainOfThoughtWidget extends StatefulWidget {
  final List<String> steps;
  const _ChainOfThoughtWidget({required this.steps});
  @override
  State<_ChainOfThoughtWidget> createState() => _ChainOfThoughtWidgetState();
}

class _ChainOfThoughtWidgetState extends State<_ChainOfThoughtWidget> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  const Text('Proses Berpikir Jarvis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16, color: const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.steps.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF475569), height: 1.4)),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  const _ActionCard({required this.action});
  @override
  Widget build(BuildContext context) {
    final type = action['type'] as String? ?? '';
    IconData icon; Color color; String label;
    switch (type) {
      case 'create_task': icon = Icons.add_task; color = Colors.blue; label = 'TUGAS BARU'; break;
      case 'update_task': icon = Icons.edit_note; color = Colors.orange; label = 'UPDATE TUGAS'; break;
      default: icon = Icons.auto_awesome; color = Colors.indigo; label = 'AKSI AI';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 16), const SizedBox(width: 8), Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5))]),
    );
  }
}

class _ActionResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ActionResultCard({required this.result});
  @override
  Widget build(BuildContext context) {
    final success = result['success'] == true;
    final color = success ? const Color(0xFF10B981) : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(success ? Icons.check_circle_rounded : Icons.error_rounded, color: color, size: 14), const SizedBox(width: 8), Text(success ? 'BERHASIL' : 'GAGAL', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800))]),
    );
  }
}

class _QuickReplyChips extends StatelessWidget {
  final List<String> replies; final ValueChanged<String> onTap;
  const _QuickReplyChips({required this.replies, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 44),
      child: Wrap(spacing: 8, runSpacing: 8, children: replies.map((r) => ActionChip(label: Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5))), backgroundColor: Colors.white, side: BorderSide(color: Colors.indigo.withOpacity(0.2)), onPressed: () => onTap(r))).toList()),
    );
  }
}

class _JarvisThinking extends StatefulWidget {
  const _JarvisThinking();
  @override State<_JarvisThinking> createState() => _JarvisThinkingState();
}
class _JarvisThinkingState extends State<_JarvisThinking> with TickerProviderStateMixin {
  late AnimationController _c; @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Container(
      width: 150, height: 4, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(2)),
      child: AnimatedBuilder(animation: _c, builder: (context, _) => Align(alignment: Alignment(lerpDouble(-1.0, 1.0, _c.value)!, 0), child: Container(width: 60, height: 4, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFF4F46E5), Colors.transparent]), borderRadius: BorderRadius.circular(2))))),
    );
  }
}
