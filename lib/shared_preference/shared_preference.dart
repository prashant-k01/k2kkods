import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeUserData(String accessToken, String refreshToken, bool isLogedIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (accessToken.isNotEmpty) {
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', accessToken);
    await prefs.setBool('isLogedIn', isLogedIn);
  } else {}
}

Future<String?> fetchAccessToken() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? accessToken = preferences.getString("accessToken");
  if (accessToken != null && accessToken.isNotEmpty) {
    return accessToken;
  } else {
    return null;
  }
}
