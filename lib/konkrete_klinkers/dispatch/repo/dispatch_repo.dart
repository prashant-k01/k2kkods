import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class DispatchRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Map<String, String>>> getWorkOrders() async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

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
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

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
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

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

  // Add this enhanced debugging to your createDispatch method in DispatchRepository:

  Future<void> createDispatch({
    required String workOrder,
    required String invoiceOrSto,
    required String vehicleNumber,
    required List<String> qrCodes,
    required String date,
    required File invoiceFile,
  }) async {
    print('🚀 Repository: createDispatch started');
    print('📋 Repository Parameters:');
    print('  - workOrder: "$workOrder"');
    print('  - invoiceOrSto: "$invoiceOrSto"');
    print('  - vehicleNumber: "$vehicleNumber"');
    print('  - qrCodes: $qrCodes');
    print('  - qrCodes length: ${qrCodes.length}');
    print('  - qrCodes JSON: ${jsonEncode(qrCodes)}');
    print('  - date: "$date"');
    print('  - invoiceFile: ${invoiceFile.path}');
    print('  - file exists: ${await invoiceFile.exists()}');
    print('  - file size: ${await invoiceFile.length()} bytes');

    try {
      print('🔐 Fetching access token...');
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        print('❌ No access token found');
        throw Exception('Authentication token not found.');
      }
      print('✅ Access token obtained: ${token.substring(0, 20)}...');

      final uri = Uri.parse(AppUrl.createdispatch);
      print('🌐 Request URL: $uri');

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      print('📦 Setting form fields...');

      // IMPORTANT: Make sure we're sending the data correctly
      request.fields['work_order'] = workOrder;
      request.fields['invoice_or_sto'] = invoiceOrSto;
      request.fields['vehicle_number'] = vehicleNumber;

      // Send QR codes as JSON array string (this is the key fix)
      String qrCodesJson = jsonEncode(qrCodes);
      request.fields['qr_codes'] = qrCodesJson;
      request.fields['date'] = date;

      print('📋 Final request fields:');
      request.fields.forEach((key, value) {
        print('  - $key: "$value"');
      });

      // Validate QR codes before sending
      if (qrCodes.isEmpty) {
        print('❌ ERROR: QR codes array is empty!');
        throw Exception('At least one QR code is required');
      }

      print('📎 Adding invoice file...');
      try {
        final multipartFile = await http.MultipartFile.fromPath(
          'invoice_file',
          invoiceFile.path,
        );
        request.files.add(multipartFile);
        print('✅ Invoice file added successfully');
        print('  - Field name: invoice_file');
        print('  - File name: ${multipartFile.filename}');
        print('  - File size: ${multipartFile.length} bytes');
        print('  - Content type: ${multipartFile.contentType}');
      } catch (e) {
        print('❌ Error adding file: $e');
        throw Exception('Failed to add invoice file: $e');
      }

      print('🔄 Sending request...');
      print('📤 REQUEST SUMMARY:');
      print('  URL: $uri');
      print('  Method: POST');
      print('  Headers: ${request.headers}');
      print('  Fields: ${request.fields}');
      print('  Files: ${request.files.length} file(s)');

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Request timeout after 30 seconds');
          throw Exception('Request timeout. Please try again.');
        },
      );

      print('📨 Response received:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Headers: ${response.headers}');

      final responseBody = await response.stream.bytesToString();
      print('📄 Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Success status code received');

        try {
          final jsonData = json.decode(responseBody);
          print('📊 Parsed JSON: $jsonData');

          if (jsonData['success'] == true) {
            print('🎉 Dispatch created successfully!');
            return;
          } else {
            final errorMsg =
                'Server returned success=false: ${jsonData['message'] ?? jsonData['errors']?.toString() ?? 'Unknown error'}';
            print('❌ $errorMsg');
            throw Exception(errorMsg);
          }
        } catch (jsonError) {
          if (jsonError is Exception &&
              jsonError.toString().contains('success=false')) {
            rethrow;
          }
          print('❌ JSON parsing error: $jsonError');
          print('📄 Raw response: $responseBody');
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';

        try {
          final jsonData = json.decode(responseBody);
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
          errorMsg = 'HTTP ${response.statusCode}: $responseBody';
        }

        print('❌ Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw Exception('No internet connection.');
    } catch (e) {
      print('❌ Unexpected error in createDispatch: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}
