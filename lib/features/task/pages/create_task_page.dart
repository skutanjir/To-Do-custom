import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/primary_button.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/error_handler.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/task/services/task_repository.dart';
import 'package:intl/intl.dart';

class CreateTaskPage extends StatefulWidget {
  final AuthService? authService;
  final TaskLocal? task;
  const CreateTaskPage({super.key, this.authService, this.task});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPriority = 'High';
  final TaskRepository _repository = TaskRepository();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDate = widget.task!.dueDate ?? DateTime.now();

      if (widget.task!.dueTime != null) {
        final parts = widget.task!.dueTime!.split(':');
        if (parts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }

      _selectedPriority =
          widget.task!.priority[0].toUpperCase() +
          widget.task!.priority.substring(1).toLowerCase();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      if (!mounted) return;
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final user = await widget.authService?.getCurrentUser();
        final userEmail = user?.email ?? 'guest';

        final task = widget.task ?? TaskLocal();
        task.title = _titleController.text;
        task.description = _descriptionController.text;
        task.dueDate = _selectedDate;
        task.dueTime =
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
        task.priority = _selectedPriority.toLowerCase();
        task.userEmail = userEmail;
        task.isCompleted = task.isCompleted;

        if (widget.task == null) {
          await _repository.createTask(task, userEmail);
        } else {
          await _repository.updateTask(task);
        }

        if (mounted) {
          ErrorHandler.showSuccessPopup(
            widget.task == null ? 'Task created successfully' : 'Task updated successfully'
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ErrorHandler.handleApiError(e);
        }
      }
    }
  }

  Color _getPriorityBg(String p, bool isSelected) {
    if (!isSelected) return AppColors.surface;
    switch (p) {
      case 'High':
        return AppColors.errorBg;
      case 'Medium':
        return AppColors.warningBg;
      case 'Low':
        return AppColors.successBg;
      default:
        return AppColors.surface;
    }
  }

  Color _getPriorityText(String p, bool isSelected) {
    if (!isSelected) return AppColors.textSecondary;
    switch (p) {
      case 'High':
        return AppColors.errorText;
      case 'Medium':
        return AppColors.warningText;
      case 'Low':
        return AppColors.successText;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityBorder(String p, bool isSelected) {
    if (!isSelected) return AppColors.calendarBorder;
    switch (p) {
      case 'High':
        return AppColors.errorText;
      case 'Medium':
        return AppColors.warningText;
      case 'Low':
        return AppColors.successText;
      default:
        return AppColors.calendarBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task == null ? 'Create New Task' : 'Edit Task',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter task name...',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter title'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write details about your task here...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.calendarBorder),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_selectedDate),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.calendarBorder),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['High', 'Medium', 'Low'].map((p) {
                  final isSelected = _selectedPriority == p;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _getPriorityBg(p, isSelected),
                        border: Border.all(
                          color: _getPriorityBorder(p, isSelected),
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            p == 'High'
                                ? Icons.error_rounded
                                : (p == 'Medium'
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline_rounded),
                            color: _getPriorityText(p, isSelected),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p,
                            style: TextStyle(
                              color: _getPriorityText(p, isSelected),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              _isSaving
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : PrimaryButton(
                      label: widget.task == null
                          ? 'Create Task'
                          : 'Update Task',
                      onPressed: _saveTask,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
