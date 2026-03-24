import 'package:isar/isar.dart';

part 'chat_session.g.dart';

@collection
class ChatSession {
  Id id = Isar.autoIncrement;

  late String title;
  late int messageCount;
  late DateTime createdAt;
  late DateTime updatedAt;

  ChatSession();

  factory ChatSession.create({required String title}) {
    final now = DateTime.now();
    return ChatSession()
      ..title = title
      ..messageCount = 0
      ..createdAt = now
      ..updatedAt = now;
  }
}
