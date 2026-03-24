// lib/core/services/enterprise_service.dart

import 'package:flutter/foundation.dart';
import 'package:pdbl_testing_custom_mobile/core/network/api_client.dart';

/// Service for the Industrial Enterprise Layer (v6.0).
/// Handles Workspaces, Projects, Folders, and Labels CRUD.
/// All endpoints are protected by Sanctum (auth token required).
class EnterpriseService {
  final ApiClient _api = ApiClient();

  // ── WORKSPACES ──────────────────────────────────────────────────

  /// List all workspaces for the current user.
  Future<List<dynamic>> getWorkspaces() async {
    try {
      final response = await _api.get('/workspaces');
      return response.data['data'] as List<dynamic>? ?? [];
    } catch (e) {
      debugPrint('EnterpriseService.getWorkspaces error: $e');
      return [];
    }
  }

  /// Get a single workspace by ID.
  Future<Map<String, dynamic>?> getWorkspace(int id) async {
    try {
      final response = await _api.get('/workspaces/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.getWorkspace error: $e');
      return null;
    }
  }

  /// Create a new workspace.
  Future<Map<String, dynamic>?> createWorkspace({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _api.post('/workspaces', data: {
        'name': name,
        if (description != null) 'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.createWorkspace error: $e');
      return null;
    }
  }

  /// Update workspace.
  Future<Map<String, dynamic>?> updateWorkspace(int id, {String? name, String? description}) async {
    try {
      final response = await _api.put('/workspaces/$id', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.updateWorkspace error: $e');
      return null;
    }
  }

  /// Delete workspace.
  Future<bool> deleteWorkspace(int id) async {
    try {
      await _api.delete('/workspaces/$id');
      return true;
    } catch (e) {
      debugPrint('EnterpriseService.deleteWorkspace error: $e');
      return false;
    }
  }

  // ── PROJECTS ────────────────────────────────────────────────────

  /// List all projects (optionally filtered by workspace).
  Future<List<dynamic>> getProjects({int? workspaceId}) async {
    try {
      final path = workspaceId != null
          ? '/projects?workspace_id=$workspaceId'
          : '/projects';
      final response = await _api.get(path);
      return response.data['data'] as List<dynamic>? ?? [];
    } catch (e) {
      debugPrint('EnterpriseService.getProjects error: $e');
      return [];
    }
  }

  /// Get a single project.
  Future<Map<String, dynamic>?> getProject(int id) async {
    try {
      final response = await _api.get('/projects/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.getProject error: $e');
      return null;
    }
  }

  /// Create a new project.
  Future<Map<String, dynamic>?> createProject({
    required String name,
    required int workspaceId,
    String? description,
  }) async {
    try {
      final response = await _api.post('/projects', data: {
        'name': name,
        'workspace_id': workspaceId,
        if (description != null) 'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.createProject error: $e');
      return null;
    }
  }

  /// Update project.
  Future<Map<String, dynamic>?> updateProject(int id, {String? name, String? description}) async {
    try {
      final response = await _api.put('/projects/$id', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.updateProject error: $e');
      return null;
    }
  }

  /// Delete project.
  Future<bool> deleteProject(int id) async {
    try {
      await _api.delete('/projects/$id');
      return true;
    } catch (e) {
      debugPrint('EnterpriseService.deleteProject error: $e');
      return false;
    }
  }

  // ── FOLDERS ─────────────────────────────────────────────────────

  /// List all folders (optionally filtered by project).
  Future<List<dynamic>> getFolders({int? projectId}) async {
    try {
      final path = projectId != null
          ? '/folders?project_id=$projectId'
          : '/folders';
      final response = await _api.get(path);
      return response.data['data'] as List<dynamic>? ?? [];
    } catch (e) {
      debugPrint('EnterpriseService.getFolders error: $e');
      return [];
    }
  }

  /// Create a new folder.
  Future<Map<String, dynamic>?> createFolder({
    required String name,
    required int projectId,
  }) async {
    try {
      final response = await _api.post('/folders', data: {
        'name': name,
        'project_id': projectId,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.createFolder error: $e');
      return null;
    }
  }

  /// Update folder.
  Future<Map<String, dynamic>?> updateFolder(int id, {String? name}) async {
    try {
      final response = await _api.put('/folders/$id', data: {
        if (name != null) 'name': name,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.updateFolder error: $e');
      return null;
    }
  }

  /// Delete folder.
  Future<bool> deleteFolder(int id) async {
    try {
      await _api.delete('/folders/$id');
      return true;
    } catch (e) {
      debugPrint('EnterpriseService.deleteFolder error: $e');
      return false;
    }
  }

  // ── LABELS ──────────────────────────────────────────────────────

  /// List all labels.
  Future<List<dynamic>> getLabels() async {
    try {
      final response = await _api.get('/labels');
      return response.data['data'] as List<dynamic>? ?? [];
    } catch (e) {
      debugPrint('EnterpriseService.getLabels error: $e');
      return [];
    }
  }

  /// Create a label.
  Future<Map<String, dynamic>?> createLabel({
    required String name,
    String? color,
  }) async {
    try {
      final response = await _api.post('/labels', data: {
        'name': name,
        if (color != null) 'color': color,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.createLabel error: $e');
      return null;
    }
  }

  /// Update label.
  Future<Map<String, dynamic>?> updateLabel(int id, {String? name, String? color}) async {
    try {
      final response = await _api.put('/labels/$id', data: {
        if (name != null) 'name': name,
        if (color != null) 'color': color,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('EnterpriseService.updateLabel error: $e');
      return null;
    }
  }

  /// Delete label.
  Future<bool> deleteLabel(int id) async {
    try {
      await _api.delete('/labels/$id');
      return true;
    } catch (e) {
      debugPrint('EnterpriseService.deleteLabel error: $e');
      return false;
    }
  }
}
