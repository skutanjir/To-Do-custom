// lib/core/services/todo_state_service.dart

import 'package:flutter/foundation.dart';
import 'package:pdbl_testing_custom_mobile/core/network/api_client.dart';

/// Service for the Workflow Engine — todo-states API.
/// Manages custom workflow states (e.g., Backlog → In Progress → Done).
/// Public route, accessible by both guests (via DeviceID) and authenticated users.
class TodoStateService {
  final ApiClient _api = ApiClient();

  /// List all available todo states.
  Future<List<dynamic>> getTodoStates() async {
    try {
      final response = await _api.get('/todo-states');
      return response.data['data'] as List<dynamic>? ?? [];
    } catch (e) {
      debugPrint('TodoStateService.getTodoStates error: $e');
      return [];
    }
  }

  /// Get a single todo state by ID.
  Future<Map<String, dynamic>?> getTodoState(int id) async {
    try {
      final response = await _api.get('/todo-states/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TodoStateService.getTodoState error: $e');
      return null;
    }
  }

  /// Create a new todo state.
  Future<Map<String, dynamic>?> createTodoState({
    required String name,
    String? color,
    int? order,
  }) async {
    try {
      final response = await _api.post('/todo-states', data: {
        'name': name,
        if (color != null) 'color': color,
        if (order != null) 'order': order,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TodoStateService.createTodoState error: $e');
      return null;
    }
  }

  /// Update a todo state.
  Future<Map<String, dynamic>?> updateTodoState(int id, {String? name, String? color, int? order}) async {
    try {
      final response = await _api.put('/todo-states/$id', data: {
        if (name != null) 'name': name,
        if (color != null) 'color': color,
        if (order != null) 'order': order,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('TodoStateService.updateTodoState error: $e');
      return null;
    }
  }

  /// Delete a todo state.
  Future<bool> deleteTodoState(int id) async {
    try {
      await _api.delete('/todo-states/$id');
      return true;
    } catch (e) {
      debugPrint('TodoStateService.deleteTodoState error: $e');
      return false;
    }
  }
}
