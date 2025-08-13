import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/login/model/login.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class LoginProvider with ChangeNotifier {
  LoginModel _loginModel = LoginModel(
    statusCode: 0,
    data: Data(
      user: User(
        id: '',
        phoneNumber: '',
        email: '',
        userType: '',
        fullName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
        username: '',
      ),
      accessToken: '',
      refreshToken: '',
    ),
    message: '',
    success: false,
  );
  LoginModel get loginModel => _loginModel;
  bool _obscurePassword = true;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _isLoginLoading = false;
  bool get isLoginLoading => _isLoginLoading;

  void setLoginLoading(bool value) {
    _isLoginLoading = value;
    notifyListeners();
  }

  bool get obscurePassword => _obscurePassword;

  Future<int> postLogin(String userName, String password) async {
    try {
      setLoginLoading(true);
      final url = AppUrl.loginUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": userName, "password": password}),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = loginModelFromJson(response.body);
          _loginModel = responseData;
          final accessToken = responseData.data?.accessToken;
          print("Access Token: $accessToken");
          final refreshToken = responseData.data?.refreshToken;
          if (accessToken != null) {
            await storeUserData(accessToken, refreshToken ?? '', true);
          }
          notifyListeners();
          return response.statusCode;
        } catch (e) {
          print("Error parsing response: $e");
          return 0;
        }
      } else {
        print("Login failed: ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      print("Network or unexpected error: $e");
      return 0;
    } finally {
      setLoginLoading(false); // Stop loading
    }
  }
}
