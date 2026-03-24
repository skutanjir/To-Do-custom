import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/primary_button.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/task/services/task_repository.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/error_handler.dart';
import 'package:pdbl_testing_custom_mobile/features/group/services/team_service.dart';
import 'package:intl/intl.dart';

class CreateGroupTaskPage extends StatefulWidget {
  final AuthService? authService;
  const CreateGroupTaskPage({super.key, this.authService});

  @override
  State<CreateGroupTaskPage> createState() => _CreateGroupTaskPageState();
}

class _CreateGroupTaskPageState extends State<CreateGroupTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _invitedEmails = [];

  final TeamService _teamService = TeamService();
  final TaskRepository _taskRepository = TaskRepository();
  bool _isSaving = false;

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty &&
        email.contains('@') &&
        !_invitedEmails.contains(email)) {
      setState(() {
        _invitedEmails.add(email);
        _emailController.clear();
      });
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _invitedEmails.remove(email);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _handleCreate() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // 1. Create Team
      final teamResponse = await _teamService.createTeam(
        _titleController.text,
        description: _descriptionController.text, // Added description support
      );
      final int teamId = teamResponse['team']['id'];

      // 2. Invite People
      if (_invitedEmails.isNotEmpty) {
        await Future.wait(
          _invitedEmails.map((email) => _teamService.inviteToTeam(teamId, email).catchError((e) {
            debugPrint('Failed to invite $email: $e');
          })),
        );
      }

      // 3. Create Task for the Team
      final user = await widget.authService?.getCurrentUser();
      final userEmail = user?.email ?? 'guest';

      final task = TaskLocal();
      task.title = _titleController.text;
      task.description = _descriptionController.text;
      task.dueDate = _selectedDate;
      task.dueTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';
      task.priority = 'medium';
      task.userEmail = userEmail;
      task.teamId = teamId;

      await _taskRepository.createTask(task, userEmail);

      if (mounted) {
        ErrorHandler.showSuccessPopup('Project Team created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      ErrorHandler.handleApiError(e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Project Team',
          style: TextStyle(
            color: Color(0xFF2D2631),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Task Title'),
                _buildTextField(
                  _titleController,
                  'Enter task name...',
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
  
                const SizedBox(height: 24),
                _buildLabel('Description'),
                _buildTextField(
                  _descriptionController,
                  'Write details about your task here...',
                  maxLines: 5,
                ),
  
                const SizedBox(height: 24),
                _buildLabel('Add People'),
                TextField(
                  controller: _emailController,
                  onSubmitted: (_) => _addEmail(),
                  decoration: InputDecoration(
                    hintText: 'Add People',
                    fillColor: const Color(0xFFF1E6D2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      onPressed: _addEmail,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _invitedEmails
                      .map((email) => _buildEmailChip(email))
                      .toList(),
                ),
  
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Due Date'),
                          _buildPickerTile(
                            icon: Icons.calendar_today_outlined,
                            text: DateFormat(
                              'MMM dd, yyyy',
                            ).format(_selectedDate),
                            onTap: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Time'),
                          _buildPickerTile(
                            icon: Icons.access_time,
                            text: _selectedTime.format(context),
                            onTap: () => _selectTime(context),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        label: 'Create Task',
                        onPressed: _handleCreate,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: const Color(0xFFF1E6D2),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E6D2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildEmailChip(String email) {
    return Chip(
      avatar: const CircleAvatar(child: Icon(Icons.person, size: 14)),
      label: Text(email, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: () => _removeEmail(email),
      backgroundColor: const Color(0xFFF1E6D2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
