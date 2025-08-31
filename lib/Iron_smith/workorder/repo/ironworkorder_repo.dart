import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_detail.dart';
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_model.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class IronWorkOrderRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing');
    }
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    return headers;
  }

  Future<ClientResponse> getAllClients() async {
    final url = Uri.parse(AppUrl.getAllClients);

    try {
      final headers = await this.headers;
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return clientResponseFromJson(response.body)!;
      } else {
        throw Exception(
          "Failed to load clients: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Network error: SSL handshake failed');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<ShapeResponse> getAllShapeCodes() async {
    final url = Uri.parse(AppUrl.shapes);

    try {
      final headers = await this.headers;
      print('getShapeCodes URL: $url');
      print('getShapeCodes Headers: $headers');
      final response = await http.get(url, headers: headers);
      print(
        'ShapeCodes Response Status: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200) {
        return shapeResponseFromJson(response.body)!;
      } else {
        throw Exception(
          "Failed to load shape codes: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProjectResponse> getProjectsByClient(String clientId) async {
    final url = Uri.parse(AppUrl.getProjectsByClientId(clientId));

    try {
      final headers = await this.headers;
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return projectResponseFromJson(response.body)!;
      } else {
        throw Exception(
          "Failed to load projects: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Network error: SSL handshake failed');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<DiameterResponse> getDiameterByProjects(String projectId) async {
    final url = Uri.parse(AppUrl.getDiameterByProject(projectId));

    try {
      final headers = await this.headers;
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return diameterResponseFromJson(response.body)!;
      } else {
        throw Exception(
          "Failed to load projects: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Network error: SSL handshake failed');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<DimensionResponse> getDimensionByShape(String shapeId) async {
    if (shapeId.isEmpty) {
      print('DEBUG: getDimensionByShape: Empty shapeId received');
      throw Exception('Invalid shape ID: Cannot be empty');
    }
    final url = Uri.parse(AppUrl.getDimensionByShape(shapeId));
    print('DEBUG: getDimensionByShape: Input shapeId = $shapeId');
    print('DEBUG: getDimensionByShape: Constructed URL = $url');

    try {
      final headers = await this.headers;
      print('DEBUG: getDimensionByShape: Headers = $headers');
      print('DEBUG: getDimensionByShape: Sending GET request to $url');
      final response = await http.get(url, headers: headers);
      print(
        'DEBUG: getDimensionByShape: Response Status = ${response.statusCode}',
      );
      print('DEBUG: getDimensionByShape: Response Body = ${response.body}');

      if (response.statusCode == 200) {
        print('DEBUG: getDimensionByShape: Successfully parsed response');
        return dimensionResponseFromJson(response.body);
      } else {
        final error = jsonDecode(response.body);
        print('DEBUG: getDimensionByShape: Error Response = $error');
        throw Exception(
          'Failed to load dimensions: ${response.statusCode} - ${error['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('DEBUG: getDimensionByShape: Exception Caught = $e');
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Network error: SSL handshake failed');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<IronWorkOrder> fetchWorkOrders() async {
    final url = Uri.parse(AppUrl.getAllWorkOrder);

    try {
      final headers = await this.headers;

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        return IronWorkOrder.fromJson(decodedBody);
      } else {
        throw Exception(
          "Failed to load work orders: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      if (e.toString().contains('HandshakeException')) {}
      throw Exception('Network error: $e');
    }
  }

  /// Fetch a work order by ID
  Future<IoWorkOrderDetail> fetchWorkOrderById(String id) async {
    final url = Uri.parse(AppUrl.getWorkOrderById(id));

    try {
      final response = await http.get(url, headers: await headers);

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        return IoWorkOrderDetail.fromJson(decodedBody);
      } else {
        throw Exception(
          "Failed to load work order $id: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<IronWorkOrder> createWorkOrder(Map<String, dynamic> payload) async {
    final url = Uri.parse(AppUrl.createWorkOrder);

    try {
      print('DEBUG: createWorkOrder: Starting API call to $url');
      print('DEBUG: createWorkOrder: Payload = ${json.encode(payload)}');

      final headers = await this.headers;
      print('DEBUG: createWorkOrder: Headers = $headers');

      print('DEBUG: createWorkOrder: Sending POST request...');
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      print('DEBUG: createWorkOrder: Response Status = ${response.statusCode}');
      print('DEBUG: createWorkOrder: Response Body = ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = json.decode(response.body);
        print('DEBUG: createWorkOrder: Successfully parsed response body');
        return IronWorkOrder.fromJson(decodedBody);
      } else {
        print(
          'DEBUG: createWorkOrder: Failed with status ${response.statusCode}',
        );
        throw Exception(
          "Failed to create work order: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print('DEBUG: createWorkOrder: Exception Caught = $e');
      throw Exception('Network error: $e');
    }
  }

  Future<IronWorkOrder> updateWorkOrder(
    String workOrderId,
    Map<String, dynamic> payload,
  ) async {
    final url = Uri.parse(AppUrl.getWorkOrderById(workOrderId));

    try {
      print('DEBUG: updateWorkOrder: Starting API call to $url');
      print('DEBUG: updateWorkOrder: Payload = ${json.encode(payload)}');

      final headers = await this.headers;
      print('DEBUG: updateWorkOrder: Headers = $headers');

      print('DEBUG: updateWorkOrder: Sending PATCH request...');
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      print('DEBUG: updateWorkOrder: Response Status = ${response.statusCode}');
      print('DEBUG: updateWorkOrder: Response Body = ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = json.decode(response.body);
        print('DEBUG: updateWorkOrder: Successfully parsed response body');
        return IronWorkOrder.fromJson(decodedBody);
      } else {
        print(
          'DEBUG: updateWorkOrder: Failed with status ${response.statusCode}',
        );
        throw Exception(
          "Failed to update work order: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print('DEBUG: updateWorkOrder: Exception Caught = $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteWorkOrder(String workOrderId) async {
    final url = Uri.parse(AppUrl.getWorkOrderById(workOrderId));

    try {
      print('DEBUG: deleteWorkOrder: Starting API call to $url');

      final headers = await this.headers;
      print('DEBUG: deleteWorkOrder: Headers = $headers');

      print('DEBUG: deleteWorkOrder: Sending DELETE request...');
      final response = await http.delete(url, headers: headers);

      print('DEBUG: deleteWorkOrder: Response Status = ${response.statusCode}');
      print('DEBUG: deleteWorkOrder: Response Body = ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        if (decodedBody['success'] == true) {
          print('DEBUG: deleteWorkOrder: Work order deleted successfully');
          return;
        } else {
          print('DEBUG: deleteWorkOrder: Failed to delete work order');
          throw Exception(
            'Failed to delete work order: ${decodedBody['message']}',
          );
        }
      } else {
        print(
          'DEBUG: deleteWorkOrder: Failed with status ${response.statusCode}',
        );
        throw Exception(
          'Failed to delete work order: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('DEBUG: deleteWorkOrder: Exception Caught = $e');
      throw Exception('Network error: $e');
    }
  }
}
