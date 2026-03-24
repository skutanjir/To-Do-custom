import 'package:isar/isar.dart';

part 'task_local.g.dart';

@collection
class TaskLocal {
  Id id = Isar.autoIncrement;

  @Index()
  int? apiId;

  late String title;

  String? description;

  @Index()
  DateTime? dueDate;

  String? dueTime;

  late String priority;

  @Index()
  bool isCompleted = false;

  @Index()
  bool isSynced = false;

  int lastLocalUpdate = 0;

  @Index()
  String? userEmail;

  @Index()
  int? teamId;

  String? assignedEmails;
}
