import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:k2k/core/exception/app_exception.dart';
import 'package:k2k/core/network/base_api_services.dart';
import 'package:k2k/core/shared_preference/shared_preference.dart';

class NetworkApiServices extends BaseApiServices {
  // Future<void> refreshAccessToken() async {
  //   final refreshToken = await SessionManager.getRefreshToken();
  //   if (refreshToken == null || refreshToken.isEmpty) {
  //     throw UnauthorizedException(
  //       "Refresh token missing",
  //     ); // Let SplashScreen handle login
  //   }

  //   final response = await http.post(
  //     Uri.parse(AppUrl.refreshToken),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'refreshToken': refreshToken}),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     await SessionManager.storeAccessToken(data['data']['accessToken']);
  //     await SessionManager.storeRefreshToken(data['data']['refreshToken']);
  //   } else {
  //     throw UnauthorizedException("Unable to refresh token");
  //   }
  // }

  @override
  Future<dynamic> getApiResponse(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      String? token = await SessionManager.getAccessToken();
      Map<String, String> finalHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await http.get(Uri.parse(url), headers: finalHeaders);
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException("No Internet connection");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> postApiResponse(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    List<XFile>? images,
    Map<String, PlatformFile>? files,
  }) async {
    try {
      String token = await SessionManager.getAccessToken() ?? '';
      Map<String, String> finalHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Handle multipart request if images/files are present
      if ((images != null && images.isNotEmpty) ||
          (files != null && files.isNotEmpty)) {
        var request = http.MultipartRequest("POST", Uri.parse(url));

        // Attach headers
        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Attach fields
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            Map<String, dynamic> data1 = json.decode(data);
            data1.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        // Attach images
        if (images != null) {
          for (var image in images) {
            final bytes = await image.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'screenshot',
                bytes,
                filename: image.name,
              ),
            );
          }
        }

        // Attach files (PDFs, Docs)
        if (files != null) {
          for (var entry in files.entries) {
            final key = entry.key;
            final file = entry.value;

            if (file.bytes != null) {
              request.files.add(
                http.MultipartFile.fromBytes(
                  key,
                  file.bytes!,
                  filename: file.name,
                ),
              );
            } else if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              request.files.add(
                http.MultipartFile.fromBytes(key, bytes, filename: file.name),
              );
            } else {
              throw Exception("File ${file.name} has no path or bytes");
            }
          }
        }

        final response = await http.Response.fromStream(await request.send());
        return _processResponse(response);
      } else {
        // Regular JSON POST
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: finalHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> putApiResponse(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    List<XFile>? images,
    Map<String, PlatformFile>? files,
  }) async {
    try {
      String token = await SessionManager.getAccessToken() ?? '';
      Map<String, String> finalHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Multipart request if images or files are provided
      if ((images != null && images.isNotEmpty) ||
          (files != null && files.isNotEmpty)) {
        var request = http.MultipartRequest("PUT", Uri.parse(url));
        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Add data fields
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            final jsonData = json.decode(data);
            jsonData.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        // Add image files
        if (images != null) {
          for (var image in images) {
            final bytes = await image.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'screenshot',
                bytes,
                filename: image.name,
              ),
            );
          }
        }

        // Add other files (PDFs, docs, etc.)
        if (files != null) {
          for (var entry in files.entries) {
            final key = entry.key;
            final file = entry.value;

            if (file.bytes != null) {
              request.files.add(
                http.MultipartFile.fromBytes(
                  key,
                  file.bytes!,
                  filename: file.name,
                ),
              );
            } else if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              request.files.add(
                http.MultipartFile.fromBytes(key, bytes, filename: file.name),
              );
            } else {
              throw Exception("File ${file.name} has no path or bytes");
            }
          }
        }

        final response = await http.Response.fromStream(await request.send());
        return _processResponse(response);
      } else {
        // Regular PUT request
        final response = await http.put(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: finalHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patchApiResponse(
    String url,
    dynamic data, {
    Map<String, String>? headers,
    XFile? uploadFile, // single file field
    List<XFile>? viewFiles, // multiple file field
    Map<String, PlatformFile>? files, // additional files
  }) async {
    try {
      String token = await SessionManager.getAccessToken() ?? '';
      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      };

      // Multipart request if files are provided
      if (uploadFile != null ||
          (viewFiles != null && viewFiles.isNotEmpty) ||
          (files != null && files.isNotEmpty)) {
        var request = http.MultipartRequest("PATCH", Uri.parse(url));
        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Add data fields
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            final Map<String, dynamic> dataMap = json.decode(data);
            dataMap.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        // Single file upload
        if (uploadFile != null) {
          final bytes = await uploadFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              "uploadFile",
              bytes,
              filename: uploadFile.name,
            ),
          );
        }

        // Multiple files upload
        if (viewFiles != null && viewFiles.isNotEmpty) {
          for (var file in viewFiles) {
            final bytes = await file.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                "viewFile",
                bytes,
                filename: file.name,
              ),
            );
          }
        }

        // Additional files
        if (files != null) {
          for (var entry in files.entries) {
            final key = entry.key;
            final file = entry.value;

            if (file.bytes != null) {
              request.files.add(
                http.MultipartFile.fromBytes(
                  key,
                  file.bytes!,
                  filename: file.name,
                ),
              );
            } else if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              request.files.add(
                http.MultipartFile.fromBytes(key, bytes, filename: file.name),
              );
            } else {
              throw Exception("File ${file.name} has no path or bytes");
            }
          }
        }

        final response = await http.Response.fromStream(await request.send());
        return _processResponse(response);
      } else {
        // Regular PATCH request
        final response = await http.patch(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: requestHeaders,
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteApiResponse(
    String url, {
    Map<String, String>? headers,
    dynamic data,
    List<XFile>? images,
    Map<String, PlatformFile>? files, // additional files
  }) async {
    try {
      String token = await SessionManager.getAccessToken() ?? '';
      Map<String, String> requestHeaders = {
        'Authorization': 'Bearer $token',
        if (headers != null) ...headers,
      };

      // Multipart request if files/images are provided
      if ((images != null && images.isNotEmpty) ||
          (files != null && files.isNotEmpty)) {
        var request = http.MultipartRequest("DELETE", Uri.parse(url));
        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Add data fields
        if (data != null) {
          if (data is Map<String, dynamic>) {
            data.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          } else if (data is String) {
            final Map<String, dynamic> dataMap = json.decode(data);
            dataMap.forEach((key, value) {
              request.fields[key] = value.toString();
            });
          }
        }

        // Attach images
        if (images != null) {
          for (var image in images) {
            final bytes = await image.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                bytes,
                filename: image.name,
              ),
            );
          }
        }

        // Attach additional files
        if (files != null) {
          for (var entry in files.entries) {
            final key = entry.key;
            final file = entry.value;

            if (file.bytes != null) {
              request.files.add(
                http.MultipartFile.fromBytes(
                  key,
                  file.bytes!,
                  filename: file.name,
                ),
              );
            } else if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              request.files.add(
                http.MultipartFile.fromBytes(key, bytes, filename: file.name),
              );
            } else {
              throw Exception("File ${file.name} has no path or bytes");
            }
          }
        }

        final response = await http.Response.fromStream(await request.send());
        return await _processResponse(response);
      } else {
        // Regular DELETE request
        final response = await http.delete(
          Uri.parse(url),
          headers: requestHeaders,
          body: jsonEncode(data),
        );
        return _processResponse(response);
      }
    } on SocketException {
      throw FetchDataException("No Internet connection");
    } catch (e) {
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic responseJson;
    try {
      responseJson = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
    } catch (_) {
      // fallback for HTML or plain text
      responseJson = {"message": response.body};
    }

    final message = (responseJson is Map && responseJson["message"] != null)
        ? responseJson["message"].toString()
        : "Something went wrong";

    switch (response.statusCode) {
      case 200:
      case 201:
        return responseJson ?? response;

      case 400: // Validation / bad input
        throw BadRequestException(message);

      case 401:
        throw UnauthorizedException(message);

      case 403:
        throw UnauthorizedException(message);
      case 404: // Not found

        throw NotFoundException(message);

      case 500:
        if (message.toLowerCase().contains("length") ||
            message.toLowerCase().contains("required") ||
            message.toLowerCase().contains("not registered") || // ✅ Add this
            message.toLowerCase().contains("not active")) {
          throw BadRequestException(message);
        }
        throw FetchDataException(message);

      default:
        throw FetchDataException(
          "Unexpected error [${response.statusCode}]: $message",
        );
    }
  }
}
