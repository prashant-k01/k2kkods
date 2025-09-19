import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_raw_material_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/repo/is_project_repo.dart';

class IsProjectProvider with ChangeNotifier {
  final ProjectsRepository _repository = ProjectsRepository();

  // ---------------- PROJECT STATE ----------------
  List<IsProject> _projects = [];
  bool _isLoading = false;
  String? _error;

  String? selectedClientId;
  String? projectName;
  String? projectAddress;

  IsProject? _selectedProject;
  IsProject? get selectedProject => _selectedProject;

  String? _currentProjectId;
  String? get currentProjectId => _currentProjectId;

  List<IsProject> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------- RAW MATERIAL STATE ----------------
  final List<RawMaterial> _rawMaterials =
      []; // Changed from List<dynamic> to List<RawMaterial>
  Map<String, dynamic>? _consumption;
  RawMaterial? _selectedConsumptionRecord;

  List<RawMaterial> get rawMaterials => _rawMaterials; // Updated getter
  Map<String, dynamic>? get consumption => _consumption;
  RawMaterial? get selectedConsumptionRecord => _selectedConsumptionRecord;

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
        clientId,
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

  // ---------------- RAW MATERIAL CRUD ----------------

  Future<void> fetchRawMaterials(
    String projectId, {
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 👇 If project changed, reset everything
      if (_currentProjectId != projectId) {
        _rawMaterials.clear();
        _currentProjectId = projectId;
        notifyListeners();
      }

      if (refresh || _rawMaterials.isEmpty) {
        final materials = await _repository.fetchRawMaterials(projectId);
        _rawMaterials
          ..clear()
          ..addAll(materials);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRawMaterial(Map<String, dynamic> rawMaterial) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final newRawMaterial = RawMaterial.fromJson(
        rawMaterial,
      ); // Parse to RawMaterial
      _rawMaterials.insert(
        0,
        newRawMaterial,
      ); // Optimistic update with RawMaterial
      notifyListeners();

      await _repository.createRawMaterial(rawMaterial);
      _error = null;
      if (rawMaterial["projectId"] != null) {
        await fetchRawMaterials(rawMaterial["projectId"], refresh: true);
      }
    } catch (e) {
      _error = e.toString();
      if (_rawMaterials.isNotEmpty) {
        _rawMaterials.removeAt(0); // Rollback optimistic update
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRawMaterial(
    String rawMaterialId,
    Map<String, dynamic> updatedData,
  ) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateRawMaterial(rawMaterialId, updatedData);

      // ✅ Update local state instead of re-fetching
      final index = rawMaterials.indexWhere((rm) => rm.id == rawMaterialId);
      if (index != -1) {
        rawMaterials[index] = rawMaterials[index].copyWith(
          quantity:
              int.tryParse(updatedData["qty"].toString()) ??
              rawMaterials[index].quantity,
          diameter: updatedData["diameter"] ?? rawMaterials[index].diameter,
          // add more fields if needed
        );
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConsumption({
    required String dia,
    required String projectId,
    required String id,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final rawMaterial = await _repository.fetchConsumption(
        dia: dia,
        projectId: projectId,
        id: id,
      );

      _selectedConsumptionRecord = rawMaterial; // ✅ keep the fetched RM
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedConsumptionRecord = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
