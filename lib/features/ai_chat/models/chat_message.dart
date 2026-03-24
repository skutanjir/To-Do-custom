// lib/features/ai_chat/models/chat_message.dart

/// Model representing a chat message between user and AI.
class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? action;
  final Map<String, dynamic>? actionResult;
  final Map<String, dynamic>? reasoningDetails;
  final List<String> quickReplies;
  final List<String> chainOfThought;
  final List<dynamic> multiIntent;
  final String? codeBlock;
  final String? codeLanguage;
  final Map<String, dynamic>? knowledgeCard;
  final Map<String, dynamic>? translationPair;
  final String? formattedContent;
  final String? contentType; // 'text', 'code', 'knowledge', 'translation', 'creative'

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.action,
    this.actionResult,
    this.reasoningDetails,
    List<String>? quickReplies,
    List<String>? chainOfThought,
    List<dynamic>? multiIntent,
    this.codeBlock,
    this.codeLanguage,
    this.knowledgeCard,
    this.translationPair,
    this.formattedContent,
    this.contentType,
  })  : id = id ?? '${role}_${DateTime.now().microsecondsSinceEpoch}_${content.hashCode}',
        timestamp = timestamp ?? DateTime.now(),
        quickReplies = quickReplies ?? [],
        chainOfThought = chainOfThought ?? [],
        multiIntent = multiIntent ?? [];

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasAction => action != null && action!['type'] != null;
  bool get hasActionResult => actionResult != null && (actionResult!['success'] != null);
  bool get hasQuickReplies => quickReplies.isNotEmpty;
  bool get hasCodeBlock => codeBlock != null && codeBlock!.isNotEmpty;
  bool get hasKnowledgeCard => knowledgeCard != null && knowledgeCard!.isNotEmpty;
  bool get hasTranslationPair => translationPair != null && translationPair!.isNotEmpty;
  bool get hasFormattedContent => formattedContent != null && formattedContent!.isNotEmpty;

  String? get actionType => action?['type'];
  Map<String, dynamic>? get actionData =>
      action?['data'] is Map<String, dynamic>
          ? action!['data'] as Map<String, dynamic>
          : null;

  /// Convert to the format expected by the backend history array.
  Map<String, dynamic> toHistoryMap() {
    return {
      'role': role,
      'content': content,
    };
  }
}
