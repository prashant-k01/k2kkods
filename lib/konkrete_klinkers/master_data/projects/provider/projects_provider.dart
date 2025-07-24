import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/model/projects.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/repo/projects_repo.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository = ProjectRepository();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  final int _limit = 10;
  String _searchQuery = '';

  // Loading states for specific operations
  bool _isAddProjectLoading = false;
  bool _isUpdateProjectLoading = false;
  bool _isDeleteProjectLoading = false;

  // Getters
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddProjectLoading => _isAddProjectLoading;
  bool get isUpdateProjectLoading => _isUpdateProjectLoading;
  bool get isDeleteProjectLoading => _isDeleteProjectLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;

  // Load Projects for current page
  Future<void> loadAllProjects({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _projects.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Loading Projects - Page: $_currentPage, Limit: $_limit, Search: $_searchQuery',
      );

      final response = await _repository.getAllProjects(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _projects = response.projects;
      _updatePaginationInfo(response.pagination);
      _error = null;

      print(
        'Loaded ${_projects.length} Projects, Total: $_totalItems, Pages: $_totalPages',
      );
    } catch (e) {
      _error = _getErrorMessage(e);
      _projects.clear();
      print('Error loading Projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    _currentPage = page;
    await loadAllProjects();
  }

  // Go to next page
  Future<void> nextPage() async {
    if (!_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  // Go to previous page
  Future<void> previousPage() async {
    if (!_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  // Go to first page
  Future<void> firstPage() async {
    await loadPage(1);
  }

  // Go to last page
  Future<void> lastPage() async {
    await loadPage(_totalPages);
  }

  // Search Projects
  Future<void> searchProjects(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllProjects();
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllProjects();
  }

  // Update pagination info
  void _updatePaginationInfo(PaginationInfo pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
    notifyListeners();
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
        _currentPage = 1;
        await loadAllProjects();
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
        await loadAllProjects();
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
        if (_projects.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
        await loadAllProjects();
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
      return error.toString();
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
}