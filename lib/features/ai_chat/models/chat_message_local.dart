import 'dart:convert';
import 'package:isar/isar.dart';

part 'chat_message_local.g.dart';

@collection
class ChatMessageLocal {
  Id id = Isar.autoIncrement;

  @Index()
  late int sessionId;

  late String role;
  late String content;
  late DateTime timestamp;

  String? actionJson;
  String? actionResultJson;
  String? reasoningDetailsJson;
  String? quickRepliesJson;
  String? codeBlock;
  String? codeLanguage;
  String? knowledgeCardJson;
  String? translationPairJson;
  String? formattedContent;
  String? contentType;

  ChatMessageLocal();

  // ── Convenience getters ──

  @ignore
  Map<String, dynamic>? get action =>
      actionJson != null ? jsonDecode(actionJson!) as Map<String, dynamic> : null;

  set action(Map<String, dynamic>? v) =>
      actionJson = v != null ? jsonEncode(v) : null;

  @ignore
  Map<String, dynamic>? get actionResult =>
      actionResultJson != null ? jsonDecode(actionResultJson!) as Map<String, dynamic> : null;

  set actionResult(Map<String, dynamic>? v) =>
      actionResultJson = v != null ? jsonEncode(v) : null;

  @ignore
  Map<String, dynamic>? get reasoningDetails =>
      reasoningDetailsJson != null ? jsonDecode(reasoningDetailsJson!) as Map<String, dynamic> : null;

  set reasoningDetails(Map<String, dynamic>? v) =>
      reasoningDetailsJson = v != null ? jsonEncode(v) : null;

  @ignore
  List<String> get quickReplies =>
      quickRepliesJson != null
          ? (jsonDecode(quickRepliesJson!) as List<dynamic>).cast<String>()
          : [];

  set quickReplies(List<String>? v) =>
      quickRepliesJson = v != null && v.isNotEmpty ? jsonEncode(v) : null;

  @ignore
  Map<String, dynamic>? get knowledgeCard =>
      knowledgeCardJson != null ? jsonDecode(knowledgeCardJson!) as Map<String, dynamic> : null;

  set knowledgeCard(Map<String, dynamic>? v) =>
      knowledgeCardJson = v != null ? jsonEncode(v) : null;

  @ignore
  Map<String, dynamic>? get translationPair =>
      translationPairJson != null ? jsonDecode(translationPairJson!) as Map<String, dynamic> : null;

  set translationPair(Map<String, dynamic>? v) =>
      translationPairJson = v != null ? jsonEncode(v) : null;
}
