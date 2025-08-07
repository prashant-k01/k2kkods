import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';
import 'package:k2k/konkrete_klinkers/inventory/provider/inventory_provider.dart';
import 'package:k2k/konkrete_klinkers/job_order/provider/job_order_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/provider/clients_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/provider/product_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/provider/projects_provider.dart';
import 'package:k2k/konkrete_klinkers/packing/provider/packing_provider.dart';
import 'package:k2k/konkrete_klinkers/production/provider/production_provider.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:k2k/konkrete_klinkers/stock_management/provider/stock_provider.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
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
            ChangeNotifierProvider(create: (_) => ProjectProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => JobOrderProvider()),
            ChangeNotifierProvider(create: (_) => InventoryProvider()),
            ChangeNotifierProvider(create: (_) => QcCheckProvider()),
            ChangeNotifierProvider(create: (_) => MachinesProvider()),
            ChangeNotifierProvider(create: (_) => PackingProvider()),
            ChangeNotifierProvider(create: (_) => WorkOrderProvider()),
            ChangeNotifierProvider(create: (_) => DispatchProvider()),
            ChangeNotifierProvider(create: (_) => StockProvider()),
            ChangeNotifierProvider(create: (_) => ProductionProvider()),
          ],
          child: Consumer<LoginProvider>(
            builder: (context, value, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRoutes.router,
              );
            },
          ),
        );
      },
    );
  }
}
