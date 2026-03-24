import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/error_handler.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/image_utils.dart';
import 'package:pdbl_testing_custom_mobile/core/utils/widget_service.dart';
import 'package:pdbl_testing_custom_mobile/features/group/services/team_service.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/group/pages/create_team_task_page.dart';
import 'package:pdbl_testing_custom_mobile/features/group/pages/member_detail_page.dart';

class TeamDetailPage extends StatefulWidget {
  final int teamId;
  final AuthService? authService;
  final String? taskId; // Added for deep linking

  const TeamDetailPage({super.key, required this.teamId, this.authService, this.taskId});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  final TeamService _teamService = TeamService();
  bool _isLoading = true;
  Map<String, dynamic>? _teamData;
  List<dynamic> _members = [];
  List<dynamic> _tasks = [];
  int? _currentUserId;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (widget.taskId != null) {
        final task = _tasks.where((t) => t['id']?.toString() == widget.taskId).firstOrNull;
        if (task != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showTaskDetail(task);
          });
        }
      }
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final user = await widget.authService?.getCurrentUser();
      _currentUserId = user?.id;
      _currentUserEmail = user?.email;

      final data = await _teamService.getTeamDetails(widget.teamId);
      setState(() {
        _teamData = data['team'];
        _members = data['team']['members'] ?? [];
        _tasks = data['tasks'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading team: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _showMemberOptions(dynamic member) {
    final bool isOwner = _teamData?['created_by']?.toString() == _currentUserId?.toString();
    if (!isOwner || member['id']?.toString() == _currentUserId?.toString()) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove, color: AppColors.errorText),
              title: const Text(
                'Kick Member',
                style: TextStyle(color: AppColors.errorText),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleRemoveMember(member['id']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.errorText),
              title: const Text(
                'Ban Member',
                style: TextStyle(color: AppColors.errorText, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleBanMember(member['id']);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditTeamDialog() async {
    final nameController = TextEditingController(text: _teamData?['name']);
    final descController = TextEditingController(
      text: _teamData?['description'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _teamService.updateTeam(
                  widget.teamId,
                  nameController.text,
                  descController.text,
                );
                if (context.mounted) {
                  ErrorHandler.showSuccessPopup('Team updated successfully');
                  Navigator.pop(context);
                  _loadData();
                }
              } catch (e) {
                ErrorHandler.handleApiError(e);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMemberDialog() async {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'User Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _teamService.inviteToTeam(
                  widget.teamId,
                  emailController.text,
                );
                if (context.mounted) {
                  ErrorHandler.showSuccessPopup('Invitation sent');
                  Navigator.pop(context);
                  _loadData();
                }
              } catch (e) {
                ErrorHandler.handleApiError(e);
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRemoveMember(int userId) async {
    try {
      await _teamService.removeMember(widget.teamId, userId);
      _loadData();
      ErrorHandler.showSuccessPopup('Member removed successfully');
    } catch (e) {
      ErrorHandler.handleApiError(e);
    }
  }

  Future<void> _handleBanMember(int userId) async {
    try {
      await _teamService.banMember(widget.teamId, userId);
      _loadData();
      ErrorHandler.showSuccessPopup('Member banned successfully');
    } catch (e) {
      ErrorHandler.handleApiError(e);
    }
  }

  void _showTaskDetail(dynamic task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskDetailSheet(
        task: task,
        isOwner: true, 
        onDelete: () async {
          try {
            // Optimistic UI: Remove task immediately
            setState(() {
              _tasks.removeWhere((t) => t['id'] == task['id']);
            });
            await _teamService.deleteTask(task['id']);
            // Sync with server quietly
            _loadData(showLoading: false);
            ErrorHandler.showSuccessPopup('Task deleted successfully');
          } catch (e) {
            // Revert or show error
            _loadData(showLoading: false);
            ErrorHandler.handleApiError(e);
          }
        },
        onEditComplete: () => _loadData(showLoading: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String teamName = _teamData?['name'] ?? 'Team Detail';
    final String description = _teamData?['description'] ?? '';

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
          'Project Team',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_teamData?['created_by']?.toString() == _currentUserId?.toString())
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showEditTeamDialog(),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Members Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Anggota Team',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_teamData?['created_by']?.toString() == _currentUserId?.toString())
                    _SmallButton(
                      label: 'Add New Member',
                      onTap: () => _showAddMemberDialog(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ..._members.map(
                (m) => _MemberTile(
                  name: m['name'] ?? '',
                  role: m['role'] ?? 'Member',
                  avatarUrl: ImageUtils.getAvatarUrl(m['avatar']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberDetailPage(
                          teamId: widget.teamId,
                          member: m,
                          memberTasks: _tasks.where((t) {
                            final assignedEmails = (t['assigned_emails'] as List<dynamic>?)?.cast<String>() ?? [];
                            final memberEmail = m['email']?.toString().toLowerCase().trim();
                            return memberEmail != null &&
                                assignedEmails.any((e) => e.toLowerCase().trim() == memberEmail);
                          }).toList(),
                          currentUserEmail: _currentUserEmail,
                          isOwner: _teamData?['created_by']?.toString() == _currentUserId?.toString(),
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                  onMore: () => _showMemberOptions(m),
                ),
              ),

              const SizedBox(height: 32),

              // Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Team',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _SmallButton(
                    label: 'Add Task',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateTeamTaskPage(
                            teamId: widget.teamId,
                            members: _members,
                            userEmail: _teamData?['owner']?['email'] ?? '',
                          ),
                        ),
                      ).then((result) {
                        if (result == true) _loadData();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_tasks.isEmpty)
                const Center(
                  child: Text(
                    'No tasks created yet.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                )
              else
                ..._tasks.map(
                  (t) => _TaskTile(
                    title: t['judul'] ?? '',
                    assignedEmails: (t['assigned_emails'] as List<dynamic>?)?.cast<String>() ?? [t['user']?['email'] ?? 'Unassigned'],
                    completedBy: (t['completed_by'] as List<dynamic>?)?.cast<String>() ?? [],
                    isDone: t['is_completed'] == true,
                    currentUserEmail: _currentUserEmail,
                    onTap: () => _showTaskDetail(t),
                    onToggle: () async {
                      final bool isOwner = _teamData?['created_by']?.toString() == _currentUserId?.toString();
                      final List<String> assignedEmails = (t['assigned_emails'] as List<dynamic>?)?.cast<String>() ?? [];
                      final String? currentUserEmailNormalized = _currentUserEmail?.toLowerCase().trim();

                      final bool isAssigned = currentUserEmailNormalized != null &&
                          assignedEmails.any((e) => e.toLowerCase().trim() == currentUserEmailNormalized);

                      if (isOwner || isAssigned) {
                        final taskIndex = _tasks.indexOf(t);
                        if (taskIndex != -1) {
                          setState(() {
                            final task = Map<String, dynamic>.from(_tasks[taskIndex]);
                            final List<String> completedBy = (task['completed_by'] as List<dynamic>?)?.cast<String>() ?? [];
                            
                            if (currentUserEmailNormalized != null) {
                              if (completedBy.any((e) => e.toLowerCase().trim() == currentUserEmailNormalized)) {
                                completedBy.removeWhere((e) => e.toLowerCase().trim() == currentUserEmailNormalized);
                              } else {
                                completedBy.add(_currentUserEmail!);
                              }
                            }
                            
                            task['completed_by'] = completedBy;
                            final int totalAssigned = assignedEmails.isNotEmpty ? assignedEmails.length : 1;
                            task['is_completed'] = completedBy.length >= totalAssigned;
                            _tasks[taskIndex] = task;
                          });
                        }

                        try {
                          await _teamService.toggleMemberTaskStatus(t['id']);
                          // Call WidgetService.fullSync after task toggle or deletion.
                          WidgetService.fullSync();
                          _loadData(showLoading: false);
                        } catch (e) {
                          _loadData(showLoading: false);
                          ErrorHandler.handleApiError(e);
                        }
                      } else {
                        ErrorHandler.showErrorPopup(
                          'Only the owner or assigned member can toggle this task',
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _MemberTile({
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: onMore),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final List<String> assignedEmails;
  final List<String> completedBy;
  final bool isDone;
  final String? currentUserEmail;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TaskTile({
    required this.title,
    required this.assignedEmails,
    required this.completedBy,
    required this.isDone,
    this.currentUserEmail,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final int totalAssigned = assignedEmails.length;
    final int totalCompleted = completedBy.length;
    final double progress = totalAssigned > 0 ? totalCompleted / totalAssigned : 0;
    final bool currentUserChecked = currentUserEmail != null &&
        completedBy.any((e) => e.toLowerCase().trim() == currentUserEmail!.toLowerCase().trim());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...assignedEmails.map(
                    (email) {
                      final bool memberChecked = completedBy.any(
                        (e) => e.toLowerCase().trim() == email.toLowerCase().trim(),
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            memberChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 14,
                            color: memberChecked ? AppColors.successText : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              email,
                              style: TextStyle(
                                color: memberChecked ? AppColors.successText : AppColors.textTertiary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.calendarBorder,
                            color: isDone ? AppColors.successText : AppColors.primary,
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalCompleted/$totalAssigned',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDone ? AppColors.successText : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: currentUserChecked,
              onChanged: (val) => onToggle(),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final dynamic task;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onEditComplete;

  const _TaskDetailSheet({
    required this.task,
    required this.isOwner,
    required this.onDelete,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime? deadline = task['deadline'] != null ? DateTime.tryParse(task['deadline']) : null;
    final String time = deadline != null ? DateFormat('HH:mm').format(deadline) : '--:--';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task['judul'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.access_time, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TIME',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Description',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              task['deskripsi'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          // Allow all members to manage group tasks
          Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text('Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.errorText))),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        Navigator.pop(context); // Close sheet immediately
                        onDelete();
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.errorText,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.errorText),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.errorBg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final titleController = TextEditingController(text: task['judul']);
                      final descController = TextEditingController(text: task['deskripsi']);

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Task'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(labelText: 'Title'),
                              ),
                              TextField(
                                controller: descController,
                                decoration: const InputDecoration(labelText: 'Description'),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final TeamService teamService = TeamService();
                                  await teamService.updateTask(
                                    task['id'],
                                    titleController.text,
                                    descController.text,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (context.mounted) {
                                    Navigator.pop(context); // Close sheet
                                    onEditComplete();
                                    ErrorHandler.showSuccessPopup('Task updated successfully');
                                  }
                                } catch (e) {
                                  ErrorHandler.handleApiError(e);
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
