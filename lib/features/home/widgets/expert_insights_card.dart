// lib/features/home/widgets/expert_insights_card.dart

import 'package:flutter/material.dart';
import 'package:pdbl_testing_custom_mobile/core/theme/app_theme.dart';
import 'package:pdbl_testing_custom_mobile/features/ai_chat/services/ai_chat_service.dart';

/// Dashboard card that displays AI Expert insights, mental load score,
/// and habit recommendations fetched from the backend.
class ExpertInsightsCard extends StatefulWidget {
  const ExpertInsightsCard({super.key});

  @override
  State<ExpertInsightsCard> createState() => _ExpertInsightsCardState();
}

class _ExpertInsightsCardState extends State<ExpertInsightsCard> {
  final AiChatService _aiService = AiChatService();

  // Mental Load
  int _mentalScore = 0;
  String _mentalStatus = 'STABLE';

  // Expert Insights
  List<String> _findings = [];
  List<String> _suggestions = [];

  // Habits
  String _habitMessage = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllInsights();
  }

  Future<void> _loadAllInsights() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      _aiService.fetchMentalLoad(),
      _aiService.fetchExpertInsights(),
      _aiService.fetchHabitRecommendations(),
    ]);

    final mentalData = results[0] as Map<String, dynamic>?;
    final insightData = results[1] as List<dynamic>?;
    final habitData = results[2] as Map<String, dynamic>?;

    if (mounted) {
      setState(() {
        // Mental Load
        if (mentalData != null) {
          _mentalScore = mentalData['score'] as int? ?? 0;
          _mentalStatus = mentalData['status'] as String? ?? 'STABLE';
        }

        // Expert Insights
        if (insightData != null && insightData.isNotEmpty) {
          // Flatten the insights list if it's a list of maps (legacy) or list of strings
          final first = insightData[0];
          if (first is Map<String, dynamic>) {
            _findings = List<String>.from(first['findings'] ?? []);
            _suggestions = List<String>.from(first['suggestions'] ?? []);
          }
        }

        // Habits
        if (habitData != null) {
          _habitMessage = habitData['message'] as String? ?? '';
        }

        _isLoading = false;
      });
    }
  }

  Color _getStatusColor() {
    return switch (_mentalStatus) {
      'CRITICAL' => AppColors.errorText,
      'WARNING' => AppColors.warningText,
      _ => AppColors.successText,
    };
  }

  Color _getStatusBg() {
    return switch (_mentalStatus) {
      'CRITICAL' => AppColors.errorBg,
      'WARNING' => AppColors.warningBg,
      _ => AppColors.successBg,
    };
  }

  IconData _getStatusIcon() {
    return switch (_mentalStatus) {
      'CRITICAL' => Icons.warning_amber_rounded,
      'WARNING' => Icons.shield_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  String _getStatusLabel() {
    return switch (_mentalStatus) {
      'CRITICAL' => 'Beban Tinggi',
      'WARNING' => 'Perlu Perhatian',
      _ => 'Stabil',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Expert Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // ── Mental Load Score ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusBg(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mental Load: $_mentalScore',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusLabel(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Refresh button
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  color: AppColors.textTertiary,
                  onPressed: _loadAllInsights,
                  tooltip: 'Refresh insights',
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Findings ──────────────────────────────────────────────
        if (_findings.isNotEmpty)
          ..._findings.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Suggestions ───────────────────────────────────────────
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .take(3)
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],

        // ── Habit message ─────────────────────────────────────────
        if (_habitMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _habitMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
