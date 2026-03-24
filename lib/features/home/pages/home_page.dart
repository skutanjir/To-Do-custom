import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/models/user.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/services/auth_service.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/welcome_page.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/login_page.dart';
import 'package:pdbl_testing_custom_mobile/features/auth/pages/register_page.dart';
import 'package:pdbl_testing_custom_mobile/features/home/widgets/home_header.dart';
import 'package:pdbl_testing_custom_mobile/features/home/widgets/search_bar.dart';
import 'package:pdbl_testing_custom_mobile/features/home/widgets/week_strip.dart';
import 'package:pdbl_testing_custom_mobile/features/home/widgets/daily_task_list.dart';
import 'package:pdbl_testing_custom_mobile/features/task/models/task_local.dart';
import 'package:pdbl_testing_custom_mobile/features/task/services/task_repository.dart';
import 'package:pdbl_testing_custom_mobile/features/profile/pages/profile_page.dart';
import 'package:pdbl_testing_custom_mobile/features/profile/pages/notification_page.dart';
import 'package:pdbl_testing_custom_mobile/features/home/widgets/expert_insights_card.dart';

import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/voice_service.dart';
import 'package:pdbl_testing_custom_mobile/core/services/settings_service.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final VoiceService? voiceService;

  const HomePage({super.key, required this.authService, this.voiceService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  int _selectedDayIndex = 30;
  DateTime _selectedDate = DateTime.now();
  final TaskRepository _taskRepository = TaskRepository();

  Stream<List<TaskLocal>>? _tasksStream;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _jarvisHasSpoken = false;

  @override
  void initState() {
    super.initState();
    _loadData(_selectedDate);
    _checkUpcomingTasksForJarvis();
  }

  Future<void> _checkUpcomingTasksForJarvis() async {
    if (widget.voiceService == null || _jarvisHasSpoken) return;

    final user = await widget.authService.getCurrentUser();
    final userEmail = user?.email ?? 'guest';
    
    // Fetch all tasks directly
    final tasks = await _taskRepository.getAllTasks(userEmail);
    if (tasks.isEmpty) return;

    final now = DateTime.now();
    final upcomingTasks = tasks.where((t) {
      if (t.isCompleted || t.dueDate == null) return false;
      final diff = t.dueDate!.difference(now).inDays;
      return diff >= 0 && diff <= 7;
    }).toList();

    if (upcomingTasks.isNotEmpty) {
      // Sort to find the closest one
      upcomingTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      final urgentTask = upcomingTasks.first;
      final daysLeft = urgentTask.dueDate!.difference(now).inDays;
      
      // Delay slightly so UI loads first before Jarvis speaks
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && widget.voiceService != null && !_jarvisHasSpoken) {
          final isIndo = widget.voiceService?.systemLocale?.startsWith('id') ?? true;
          
          String timeTextId = '';
          String timeTextEn = '';
          
          if (daysLeft < 0) {
            timeTextId = 'telah melewati tenggat waktu';
            timeTextEn = 'is already overdue';
          } else if (daysLeft == 0) {
            timeTextId = 'akan berakhir hari ini';
            timeTextEn = 'is ending today';
          } else {
            timeTextId = 'akan berakhir dalam $daysLeft hari';
            timeTextEn = 'is due in $daysLeft days';
          }
          
          final text = isIndo
              ? 'Kak, ada tugas "${urgentTask.title}" yang belum Anda selesaikan dan $timeTextId.'
              : 'Hi, just a heads up that you have an unfinished task named "${urgentTask.title}" that $timeTextEn.';
              
          widget.voiceService?.speakProactiveReminder(
            taskName: urgentTask.title,
            daysLeft: daysLeft,
            isIndonesian: isIndo,
            customText: text,
          );
          _jarvisHasSpoken = true;
        }
      });
    }
  }

  Future<void> _loadData([DateTime? targetDate]) async {
    final dateToLoad = targetDate ?? _selectedDate;
    final user = await widget.authService.getCurrentUser();
    final userEmail = user?.email ?? 'guest';

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = true;
        _tasksStream = _taskRepository.watchTasksForDate(dateToLoad, userEmail);
      });
    }

    _taskRepository.fetchTasksFromServer(userEmail).then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onDaySelected(DateTime date) {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 30));
    final diff = date.difference(start).inDays;

    setState(() {
      _selectedDate = date;
      _selectedDayIndex = diff;
    });
    _loadData(date);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (_) => false,
    );
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _goToProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(authService: widget.authService)),
    );
    _loadData();
  }

  void _goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.name ?? 'Guest';
    final isGuest = _user?.isGuest ?? true;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 900
        ? screenWidth * 0.15
        : screenWidth > 600
        ? screenWidth * 0.08
        : 20.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: StreamBuilder<List<TaskLocal>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];

          final filteredTasks = _searchQuery.isEmpty
              ? tasks
              : tasks.where((task) {
                  return task.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      (task.description?.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ??
                          false);
                }).toList();

          final uncompletedTasks = tasks
              .where((t) => !t.isCompleted)
              .toList();

          uncompletedTasks.sort((a, b) {
            if (a.dueTime != null && b.dueTime != null) {
              final timeCompare = a.dueTime!.compareTo(b.dueTime!);
              if (timeCompare != 0) return timeCompare;
            } else if (a.dueTime != null) {
              return -1;
            } else if (b.dueTime != null) {
              return 1;
            }

            int getWeight(String p) {
              switch (p.toLowerCase()) {
                case 'high':
                  return 3;
                case 'medium':
                  return 2;
                case 'low':
                  return 1;
                default:
                  return 0;
              }
            }

            final weightA = getWeight(a.priority);
            final weightB = getWeight(b.priority);
            return weightB.compareTo(weightA);
          });

          final focusTask = uncompletedTasks.firstOrNull;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  MediaQuery.of(context).padding.top + 24.0,
                  horizontalPadding,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    HomeHeader(
                      displayName: displayName,
                      avatarUrl: _user?.avatar,
                      isGuest: isGuest,
                      onAvatarTap: _goToProfile,
                      onNotificationTap: _goToNotifications,
                      onLogoutTap: _logout,
                      onLoginTap: _goToLogin,
                      onRegisterTap: _goToRegister,
                    ),
                    const SizedBox(height: 32),
                    NexuzeSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    WeekStrip(
                      selectedIndex: _selectedDayIndex,
                      onDaySelected: _onDaySelected,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Today\'s Focus',
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading && focusTask == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    else if (focusTask != null)
                      _buildFocusCard(focusTask)
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.calendarBorder),
                        ),
                        child: const Center(
                          child: Text(
                            'All caught up for today.',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
              // Use Sliver version of TaskList to avoid nesting and allow memory recycling
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: DailyTaskList(
                  tasks: filteredTasks,
                  onRefresh: _loadData,
                  authService: widget.authService,
                  isLoading: _isLoading,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  32,
                  horizontalPadding,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const ExpertInsightsCard(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFocusCard(TaskLocal task) {
    final isHigh = task.priority.toLowerCase() == 'high';
    final isMed = task.priority.toLowerCase() == 'medium';
    final tagText = isHigh
        ? AppColors.errorText
        : (isMed ? AppColors.warningText : AppColors.successText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary, // Dark aesthetic for the focus card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tagText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.priority.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.dueTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(task.dueTime!, context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
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
