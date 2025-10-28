import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:k2k/common/constant/app_url.dart';
import 'package:k2k/core/network/network_api_services.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch.dart';
import 'package:k2k/core/shared_preference/shared_preference.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch_detail.dart';

class DispatchRepository {
  final NetworkApiServices _repository = NetworkApiServices();
  Future<Map<String, String>> get headers async {
    final token = await SessionManager.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Map<String, String>>> getWorkOrders() async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchWorkOrderDetailsUrl);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) return [];

        final jsonData = json.decode(responseBody);
        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'id': item['_id'] as String? ?? '',
                'number': item['work_order_number'] as String? ?? '',
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load work orders: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    }
  }

  Future<List<DispatchModel>> getDispatches() async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.kkdispatch);

      print('Fetching dispatches from: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Dispatches API Response Status: ${response.statusCode}');
      print('Dispatches API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty response body for dispatches');
          return [];
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Dispatches JSON: $jsonData');

        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(DispatchModel.fromJson)
            .toList()
            .reversed
            .toList();
      } else {
        final jsonData = json.decode(response.body);
        print('Error Response JSON: $jsonData');
        throw Exception(
          'Failed to load dispatches: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      print('No internet connection while fetching dispatches');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in getDispatches: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchQrScanData(String qrId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.qrScanUrl}?id=$qrId');

      print('Fetching QR scan data from: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('QR Scan API Response Status: ${response.statusCode}');
      print('QR Scan API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            'QR scan failed: ${jsonData['errors']?.toString() ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch QR data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in fetchQrScanData: $e');
      rethrow;
    }
  }

  Future<DispatchDetailResponse> fetchDispatchById(String dispatchId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.kkdispatch}/$dispatchId');

      print('Fetching dispatch from: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Fetch Dispatch API Response Status: ${response.statusCode}');
      print('Fetch Dispatch API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return DispatchDetailResponse.fromJson(jsonData);
        } else {
          throw Exception(
            'Failed to fetch dispatch: ${jsonData['errors']?.toString() ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to fetch dispatch: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in fetchDispatchById: $e');
      rethrow;
    }
  }

  Future<void> createDispatch({
    required String workOrder,
    required String invoiceOrSto,
    required String vehicleNumber,
    required String date,
    required File invoiceFile,
    required List<String> qrCodes,
  }) async {
    // Convert invoice file to PlatformFile (binary upload)
    final invoiceBytes = await invoiceFile.readAsBytes();
    final invoicePlatformFile = PlatformFile(
      name: invoiceFile.path.split('/').last,
      size: invoiceBytes.length,
      bytes: invoiceBytes,
    );

    // Prepare body (QR codes as JSON array)
    final body = {
      'work_order': workOrder,
      'invoice_or_sto': invoiceOrSto,
      'vehicle_number': vehicleNumber,
      'qr_codes': jsonEncode(qrCodes),
      'date': date,
    };

    final files = {'invoice_file': invoicePlatformFile};

    final response = await _repository.postApiResponse(
      AppUrl.createdispatch,
      body,
      files: files,
    );

    if (response['success'] != true) {
      final errorMsg =
          response['message'] ??
          response['errors']?.toString() ??
          'Unknown error';
      throw Exception('Failed to create dispatch: $errorMsg');
    }
  }

  Future<void> updateDispatch({
    required String dispatchId,
    required String invoiceOrSto,
    required String vehicleNumber,
    required String date,
  }) async {
    print('🚀 Repository: updateDispatch started');
    print('📋 Repository Parameters:');
    print('  - dispatchId: "$dispatchId"');
    print('  - invoiceOrSto: "$invoiceOrSto"');
    print('  - vehicleNumber: "$vehicleNumber"');
    print('  - date: "$date"');

    try {
      final uri = Uri.parse('${AppUrl.kkdispatch}/$dispatchId');
      print('🌐 Request URL: $uri');

      final authHeaders = await headers;
      final body = jsonEncode({
        'invoice_or_sto': invoiceOrSto,
        'vehicle_number': vehicleNumber,
        'date': date,
      });

      print('📋 Request Body: $body');

      final response = await http
          .put(uri, headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      print('📨 Response received:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Headers: ${response.headers}');
      print('  - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        print('📊 Parsed JSON: $jsonData');

        if (jsonData['success'] == true) {
          print('🎉 Dispatch updated successfully!');
          return;
        } else {
          final errorMsg =
              'Server returned success=false: ${jsonData['message'] ?? jsonData['errors']?.toString() ?? 'Unknown error'}';
          print('❌ $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final jsonData = json.decode(response.body);
          print('❌ ERROR RESPONSE PARSED: $jsonData');

          if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('message')) {
              errorMsg = jsonData['message'].toString();
            } else if (jsonData.containsKey('error')) {
              errorMsg = jsonData['error'].toString();
            } else if (jsonData.containsKey('errors')) {
              errorMsg = jsonData['errors'].toString();
            }
          }
        } catch (e) {
          print('⚠️ Could not parse error response: $e');
          errorMsg = 'HTTP ${response.statusCode}: ${response.body}';
        }

        print('❌ Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw Exception('No internet connection.');
    } catch (e) {
      print('❌ Unexpected error in updateDispatch: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}
