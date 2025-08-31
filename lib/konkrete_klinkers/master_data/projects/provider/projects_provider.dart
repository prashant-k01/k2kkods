import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/model/projects.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/repo/projects_repo.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository = ProjectRepository();

  // Project list state
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';

  // CRUD loading states
  bool _isAddProjectLoading = false;
  bool _isUpdateProjectLoading = false;
  bool _isDeleteProjectLoading = false;

  // Edit form state
  bool _isLoadingEditForm = false;
  ProjectModel? _editProject;
  String? _editProjectError;

  // Getters
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddProjectLoading => _isAddProjectLoading;
  bool get isUpdateProjectLoading => _isUpdateProjectLoading;
  bool get isDeleteProjectLoading => _isDeleteProjectLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool get isLoadingEditForm => _isLoadingEditForm;
  ProjectModel? get editProject => _editProject;
  String? get editProjectError => _editProjectError;

  // =====================
  // Project List
  // =====================
  Future<void> loadAllProjects({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) {
      _projects.clear();
      _hasMore = true;
      _error = null;
    }
    notifyListeners();

    try {
      final response = await _repository.getAllProjects(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _projects.addAll(response.projectModels);
      _hasMore = false; // Assume all projects are loaded in one go
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (refresh) _projects.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProjects(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await loadAllProjects(refresh: true);
  }

  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    await loadAllProjects(refresh: true);
  }

  // =====================
  // Create / Update / Delete
  // =====================
  Future<bool> createProject(
    String name,
    String address,
    String clientId,
  ) async {
    _isAddProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProject = await _repository.createProject(
        name,
        address,
        clientId,
      );
      if (newProject.id.isNotEmpty) {
        await loadAllProjects(refresh: true);
        return true;
      }
      _error = 'Created project has no ID';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isAddProjectLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(
    String id,
    String name,
    String address,
    String clientId,
  ) async {
    _isUpdateProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateProject(
        id,
        name,
        address,
        clientId,
      );
      if (success) {
        await loadAllProjects(refresh: true);
        return true;
      }
      _error = 'Failed to update Project';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdateProjectLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String id) async {
    _isDeleteProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteProject(id);
      if (success) {
        await loadAllProjects(refresh: true);
        return true;
      }
      _error = 'Failed to delete Project';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDeleteProjectLoading = false;
      notifyListeners();
    }
  }

  // =====================
  // Single Project
  // =====================
  Future<void> loadEditProject(String id) async {
    _isLoadingEditForm = true;
    _editProject = null;
    _editProjectError = null;
    notifyListeners();

    try {
      final project = await _repository.getProject(id);
      if (project == null) {
        _editProjectError = 'Project not found';
      } else {
        _editProject = project;
      }
    } catch (e) {
      _editProjectError = e.toString();
    } finally {
      _isLoadingEditForm = false;
      notifyListeners();
    }
  }

  void clearEditProject() {
    _isLoadingEditForm = false;
    _editProject = null;
    _editProjectError = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
