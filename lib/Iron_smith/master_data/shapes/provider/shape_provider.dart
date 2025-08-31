import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2k/Iron_smith/master_data/shapes/model/shape_model.dart';
import 'package:k2k/Iron_smith/master_data/shapes/repo/shape_repo.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/snackbar.dart';

class ShapesProvider with ChangeNotifier {
  final ShapesRepository _repository = ShapesRepository();
  final List<Shape> _shapes = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;

  // Form-specific fields for add/edit
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  String? _selectedDimensionId;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shapeCodeController = TextEditingController();
  String? _selectedImage;
  List<Map<String, String>> _dimensions = [];

  // Getters
  List<Shape> get shapes => _shapes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  GlobalKey<FormBuilderState> get formKey => _formKey;
  String? get selectedDimensionId => _selectedDimensionId;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get shapeCodeController => _shapeCodeController;
  String? get selectedImage => _selectedImage;
  List<Map<String, String>> get dimensions => _dimensions;

  Future<void> fetchDimensions() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _dimensions = await _repository.fetchDimensions();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching dimensions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> fetchShapes({bool refresh = false}) async {
    if (_isLoading || !_hasMore) return;
    if (refresh) {
      _shapes.clear();
      _hasMore = true;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final newShapes = await _repository.fetchAllShapes();
      if (newShapes.isEmpty)
        _hasMore = false;
      else
        _shapes.addAll(newShapes);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Shape?> fetchShapeById(BuildContext context, String id) async {
    if (_isLoading) {
      print('FetchShapeById: Already loading, skipping fetch for ID: $id');
      return null;
    }
    _isLoading = true;
    notifyListeners();
    try {
      print('FetchShapeById: Fetching shape with ID: $id');
      final shape = await _repository.fetchShapeById(id);
      if (shape == null) {
        print('FetchShapeById: Shape not found for ID: $id');
        _error = 'Shape not found';
        context.showErrorSnackbar('Shape not found for ID: $id');
        return null;
      }
      print('FetchShapeById: Successfully fetched shape: ${shape.toJson()}');
      _error = null;
      return shape;
    } catch (e) {
      print('FetchShapeById: Error fetching shape with ID $id: $e');
      _error = e.toString();
      context.showErrorSnackbar('Failed to fetch shape: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializeEditForm(Shape shape) {
    print('InitializeEditForm: Initializing form for shape ID: ${shape.id}');
    _selectedDimensionId = shape.dimension?.id;
    _descriptionController.text = shape.description ?? '';
    _shapeCodeController.text = shape.shapeCode ?? '';
    _selectedImage = null;
    if (_formKey.currentState != null) {
      _formKey.currentState!.patchValue({
        'dimension': _selectedDimensionId,
        'description': _descriptionController.text,
        'shape_code': _shapeCodeController.text,
      });
    }
    notifyListeners();
  }

  void resetForm() {
    _selectedDimensionId = null;
    _descriptionController.clear();
    _shapeCodeController.clear();
    _selectedImage = null;
    _formKey.currentState?.reset();
    notifyListeners();
  }

  void updateDimensionId(String? value) {
    _selectedDimensionId = value;
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _selectedImage = pickedFile.path;
        print('ShapesProvider: Picked image: $_selectedImage');
        notifyListeners();
      }
    } catch (e) {
      print('ShapesProvider: Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<Shape?> _validateAndCreateShape(BuildContext context) async {
    if (!_formKey.currentState!.saveAndValidate()) return null;
    final formData = _formKey.currentState!.value;
    if (_selectedDimensionId == null) {
      context.showWarningSnackbar('Please select a dimension!!');
      return null;
    }
    if (_selectedImage == null) {
      context.showWarningSnackbar('Please upload an image!!');
      return null;
    }
    return Shape(
      dimension: Dimension(id: formData['dimension']),
      description: formData['description'],
      shapeCode: formData['shape_code'],
    );
  }

  Future<void> submitForm(BuildContext context) async {
    if (_isLoading) return;
    final shape = await _validateAndCreateShape(context);
    if (shape == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.addShape(shape, imageFile: _selectedImage);
      _shapes.insert(0, shape);
      _clearForm();
      context.showSuccessSnackbar('Shape added successfully!!');
      context.go(RouteNames.allshapes);
    } catch (e) {
      _error = e.toString();
      context.showErrorSnackbar('Failed to add shape: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editShape(BuildContext context, String id) async {
    if (_isLoading) return;
    final shape = await _validateAndCreateShape(context);
    if (shape == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.editShape(id, shape, imageFile: _selectedImage);
      final index = _shapes.indexWhere((s) => s.id == id);
      if (index != -1)
        _shapes[index] = shape;
      else
        _shapes.insert(0, shape);
      _clearForm();
      context.showSuccessSnackbar('Shape updated successfully!!');
      context.go(RouteNames.allshapes);
    } catch (e) {
      _error = e.toString();
      context.showErrorSnackbar('Failed to update shape: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteShape(BuildContext context, String id) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteShape(id);
      _shapes.removeWhere((shape) => shape.id == id);
      context.showSuccessSnackbar('Shape deleted successfully!!');
    } catch (e) {
      _error = e.toString();
      context.showErrorSnackbar('Failed to delete shape: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    _selectedDimensionId = null;
    _descriptionController.clear();
    _shapeCodeController.clear();
    _selectedImage = null;
    _formKey.currentState?.reset();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _shapeCodeController.dispose();
    super.dispose();
  }
}
