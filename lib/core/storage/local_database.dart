import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_message_local.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/models/chat_session.dart';

class LocalDatabase {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [TaskLocalSchema, ChatMessageLocalSchema, ChatSessionSchema],
      directory: dir.path,
    );
  }

  static Future<void> clearAll() async {
    await isar.writeTxn(() => isar.clear());
  }
}
