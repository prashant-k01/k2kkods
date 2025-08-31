import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/repo/is_project_repo.dart';

class IsProjectProvider with ChangeNotifier {
  final ProjectsRepository _repository = ProjectsRepository();
  List<IsProject> _projects = [];
  bool _isLoading = false;
  String? _error;

  String? selectedClientId;
  String? projectName;
  String? projectAddress;

  IsProject? _selectedProject;
  IsProject? get selectedProject => _selectedProject;

  List<IsProject> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (refresh) {
        _projects.clear();
      }

      final newProjects = await _repository.fetchProjects();
      _projects.addAll(newProjects);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    selectedClientId = null;
    projectName = null;
    projectAddress = null;
    notifyListeners();
  }

  Future<void> addProject(IsProject project) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print(
      'addProject - Starting, project: ${project.name}, ${project.address}',
    );

    try {
      // Optimistic update
      _projects.insert(0, project);
      notifyListeners();

      await _repository.addProject(project);
      _error = null;
      print('addProject - API call successful');
      await fetchProjects(refresh: true);
    } catch (e) {
      _error = e.toString();
      _projects.remove(project); // rollback
      print('addProject - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProjectById(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final project = await _repository.getProjectById(id);
      _selectedProject = project;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(
    String projectId,
    String projectAddress,
    String clientId,

    String projectName,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = IsProject(
          id: _projects[index].id,
          address: projectAddress,
          client: IsPClient(id: clientId, name: ""),
          name: projectName,
          isDeleted: _projects[index].isDeleted,
          createdBy: _projects[index].createdBy,
          createdAt: _projects[index].createdAt,
          updatedAt: _projects[index].updatedAt,
          v: _projects[index].v,
        );
        notifyListeners();
      }

      await _repository.updateProject(
        projectId,
        projectAddress,
        clientName,
        projectName,
      );
      _error = null;
      print('updateProject - API call successful');
      await fetchProjects(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      print('updateProject - Error: $e');
      await fetchProjects(refresh: true); // rollback
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String id) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();
    print('deleteProject - Starting, id: $id');

    try {
      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      print(
        'deleteProject - Optimistically removed, current count: ${_projects.length}',
      );

      await _repository.deleteProject(id);
      _error = null;
      print('deleteProject - API call successful');
      await fetchProjects(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      print('deleteProject - Error: $e');
      await fetchProjects(refresh: true);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
    print('clearError - Cleared error');
  }
}
