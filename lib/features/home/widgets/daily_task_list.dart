import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/task/pages/task_page.dart';
import 'package:pdbl_testing_custom_mobile/features/task/services/task_repository.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/error_handler.dart';

class DailyTaskList extends StatefulWidget {
  final List<TaskLocal> tasks;
  final VoidCallback onRefresh;
  final AuthService? authService;
  final bool isLoading;

  const DailyTaskList({
    super.key,
    required this.tasks,
    required this.onRefresh,
    this.authService,
    this.isLoading = false,
  });

  @override
  State<DailyTaskList> createState() => _DailyTaskListState();
}

class _DailyTaskListState extends State<DailyTaskList> {
  final TaskRepository _taskRepository = TaskRepository();

  Future<void> _toggleTask(TaskLocal task) async {
    task.isCompleted = !task.isCompleted;
    _taskRepository.updateTask(task);
  }

  Future<void> _deleteTask(TaskLocal task) async {
    await _taskRepository.deleteTask(task);
    ErrorHandler.showSuccessPopup('Task deleted successfully');
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: AppTextStyles.title,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskPage(authService: widget.authService),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.isLoading && widget.tasks.isEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: _SkeletonTaskItem(),
              ),
              childCount: 3,
            ),
          )
        else if (widget.tasks.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.done_all_rounded, size: 48, color: AppColors.calendarBorder),
                    const SizedBox(height: 12),
                    const Text(
                      'No tasks left for today',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = widget.tasks[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index == widget.tasks.length - 1 && !widget.isLoading ? 0 : 12),
                  child: _TaskItem(
                    task: task,
                    onToggle: () => _toggleTask(task),
                    onDelete: () => _deleteTask(task),
                  ),
                );
              },
              childCount: widget.tasks.length,
            ),
          ),
        if (widget.isLoading && widget.tasks.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: _SkeletonTaskItem(),
            ),
          ),
      ],
    );
  }
}

class _SkeletonTaskItem extends StatelessWidget {
  const _SkeletonTaskItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.calendarBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskLocal task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: AppColors.errorBg,
            foregroundColor: AppColors.errorText,
            icon: Icons.delete_outline,
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppColors.background : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted ? Colors.transparent : AppColors.calendarBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.isCompleted ? AppColors.primary : AppColors.textPlaceholder,
                    width: task.isCompleted ? 0 : 2,
                  ),
                  color: task.isCompleted ? AppColors.primary : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: task.isCompleted ? FontWeight.w500 : FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                    ),
                  ),
                  if (task.dueTime != null || task.priority.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (task.priority.isNotEmpty) ...[
                          Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: task.isCompleted ? AppColors.textTertiary : _getPriorityTextColor(task.priority),
                            ),
                          ),
                          if (task.dueTime != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text('•', style: TextStyle(color: AppColors.textPlaceholder, fontSize: 10)),
                            ),
                        ],
                        if (task.dueTime != null)
                          Text(
                            _formatTime(task.dueTime!, context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted ? AppColors.textTertiary : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.errorText;
      case 'medium':
        return AppColors.warningText;
      case 'low':
        return AppColors.successText;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(String timeStr, BuildContext context) {
    try {
      final parts = timeStr.split(':');
      final tod = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      return tod.format(context);
    } catch (e) {
      return timeStr;
    }
  }
}
