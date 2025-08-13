import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeUserData(
  String accessToken,
  String refreshToken,
  bool isLogedIn,
) async {
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

Future<void> clearUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
  await prefs.remove('refreshToken');
  await prefs.remove('isLogedIn');
}

Future<void> confirmLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldLogout == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('isLogedIn');

    if (context.mounted) {
      context.go(RouteNames.login); // GoRouter redirect
    }
  }
}
