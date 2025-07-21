import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/provider/clients_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/login/provider/login_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411.43, 867.43),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => PlantProvider()),
            ChangeNotifierProvider(create: (_) => ClientsProvider()),
          ],
          child: Consumer<LoginProvider>(
            builder: (context, value, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRoutes.router, // <-- GoRouter config
              );
            },
          ),
        );
      },
    );
  }
}
