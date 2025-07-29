import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/model/projects.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/repo/projects_repo.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository = ProjectRepository();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';
  int _lastIndex = 0;

  bool _isAddProjectLoading = false;
  bool _isUpdateProjectLoading = false;
  bool _isDeleteProjectLoading = false;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddProjectLoading => _isAddProjectLoading;
  bool get isUpdateProjectLoading => _isUpdateProjectLoading;
  bool get isDeleteProjectLoading => _isDeleteProjectLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  Future<void> loadAllProjects({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) {
      _hasMore = true; // Reset only on explicit refresh
      _projects.clear();
      _lastIndex = 0;
    }
    _error = null;
    notifyListeners();

    try {
      print('Loading Projects - Search: $_searchQuery, LastIndex: $_lastIndex');

      final response = await _repository.getAllProjects(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      final newProjects = response.projectModels;
      _projects.addAll(newProjects);
      _lastIndex += newProjects.length;
      _hasMore = false; // Assume all projects are loaded in one response
      _error = null;

      print('Loaded ${_projects.length} Projects');
    } catch (e) {
      _error = _getErrorMessage(e);
      if (refresh) {
        _projects.clear();
        _lastIndex = 0;
      }
      print('Error loading Projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProjects(String query) async {
    if (_searchQuery == query) return; // Avoid redundant searches
    _searchQuery = query;
    await loadAllProjects(refresh: true);
  }

  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return; // Avoid redundant clears
    _searchQuery = '';
    await loadAllProjects(refresh: true);
  }

  Future<bool> createProject(
    String projectName,
    String address,
    String clientId,
  ) async {
    _isAddProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProject = await _repository.createProject(
        projectName,
        address,
        clientId,
      );

      if (newProject.id.isNotEmpty) {
        await loadAllProjects(refresh: true);
        return true;
      } else {
        _error = 'Created project has no ID';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Create Project Error: $_error');
      return false;
    } finally {
      _isAddProjectLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(
    String projectId,
    String projectName,
    String address,
    String clientId,
  ) async {
    _isUpdateProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateProject(
        projectId,
        projectName,
        address,
        clientId,
      );

      if (success) {
        await loadAllProjects(refresh: true);
        return true;
      } else {
        _error = 'Failed to update Project';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateProjectLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _isDeleteProjectLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteProject(projectId);

      if (success) {
        await loadAllProjects(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete Project';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteProjectLoading = false;
      notifyListeners();
    }
  }

  Future<ProjectModel?> getProject(String projectId) async {
    try {
      _error = null;
      final project = await _repository.getProject(projectId);
      return project;
    } catch (e) {
      _error = _getErrorMessage(e);
      return null;
    }
  }

  ProjectModel? getProjectByIndex(int index) {
    if (index >= 0 && index < _projects.length) {
      return _projects[index];
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
}