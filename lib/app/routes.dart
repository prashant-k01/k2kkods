import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/dashboard/view/dashboard_screen.dart';
import 'package:k2k/konkrete_klinkers/inventory/view/inventory_list.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/view/job_order_add.dart';
import 'package:k2k/konkrete_klinkers/job_order/view/job_order_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/job_order/view/job_order_screen_list.dart';
import 'package:k2k/konkrete_klinkers/job_order/view/job_order_view.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_add_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machines_list_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plants_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_screen_list.dart';
import 'package:k2k/konkrete_klinkers/packing/view/packing_add.dart';
import 'package:k2k/konkrete_klinkers/packing/view/packing_list.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_add_screen.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_edit.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_list_screen.dart';
import 'package:k2k/login/view/login_screen.dart';
import 'package:k2k/splashscreen/splash_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: RouteNames.plants,
        name: RouteNames.plants,
        builder: (BuildContext context, GoRouterState state) {
          return PlantsListView();
        },
      ),
      GoRoute(
        path: RouteNames.inventory,
        name: RouteNames.inventory,
        builder: (BuildContext context, GoRouterState state) {
          return InventoryListScreen();
        },
      ),
      GoRoute(
        path: RouteNames.projects,
        name: RouteNames.projects,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectsListView();
        },
      ),
      GoRoute(
        path: RouteNames.qcCheck,
        name: RouteNames.qcCheck,
        builder: (BuildContext context, GoRouterState state) {
          return QcCheckListView();
        },
      ),
      GoRoute(
        path: RouteNames.qcCheckAdd,
        name: RouteNames.qcCheckAdd,
        builder: (BuildContext context, GoRouterState state) {
          return QcCheckFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.products,
        name: RouteNames.products,
        builder: (BuildContext context, GoRouterState state) {
          return ProductsListView();
        },
      ),
      GoRoute(
        path: RouteNames.clients,
        name: RouteNames.clients,
        builder: (BuildContext context, GoRouterState state) {
          return ClientsListView();
        },
      ),
      GoRoute(
        path: RouteNames.plantsadd,
        name: RouteNames.plantsadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddPlantFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.productsadd,
        name: RouteNames.productsadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddProductFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.clientsadd,
        name: RouteNames.clientsadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddClientFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.projectsadd,
        name: RouteNames.projectsadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddProjectFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.joborderadd,
        name: RouteNames.joborderadd,
        builder: (BuildContext context, GoRouterState state) {
          return JobOrdersFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: RouteNames.plantsedit, // '/plants/edit/:plantId'
        name: RouteNames.plantsedit,
        builder: (context, state) {
          final plantId = state.pathParameters['plantId'];
          if (plantId == null) {
            return const PlantsListView();
          }
          return EditPlantFormScreen(plantId: plantId);
        },
      ),
      GoRoute(
        path: '/qc-check/edit/:qcCheckId',
        name: 'qcCheckEdit', // MUST be a simple string used for navigation
        builder: (context, state) {
          final qcCheckId = state.pathParameters['qcCheckId'];
          return QcCheckEditScreen(qcCheckId: qcCheckId!);
        },
      ),
      GoRoute(
        path: RouteNames.machines,
        name: RouteNames.machines,
        builder: (BuildContext context, GoRouterState state) {
          return MachinesListScreen();
        },
      ),
      GoRoute(
        path: RouteNames.packing,
        name: RouteNames.packing,
        builder: (BuildContext context, GoRouterState state) {
          return PackingListView();
        },
      ),
      GoRoute(
        path: RouteNames.packingadd,
        name: RouteNames.packingadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddPackingFormScreen();
        },
      ),
      GoRoute(
        path: RouteNames.machinesadd,
        name: RouteNames.machinesadd,
        builder: (BuildContext context, GoRouterState state) {
          return MachineAddScreen();
        },
      ),
      GoRoute(
        path: RouteNames.machinesedit,
        name: RouteNames.machinesedit,
        builder: (context, state) {
          final machineId = state.pathParameters['machineId'];
          if (machineId == null) {
            // Handle missing plantId gracefully
            return const MachinesListScreen(); // Redirect to plants list
          }
          return MachineEditScreen(machineId: machineId);
        },
      ),
      GoRoute(
        path: RouteNames.productedit,
        name: RouteNames.productedit,
        builder: (context, state) {
          final productId = state.pathParameters['productId'];
          if (productId == null) {
            return const ProductsListView();
          }
          return EditProductFormScreen(productId: productId);
        },
      ),
      GoRoute(
        path: RouteNames.projectsedit,
        name: RouteNames.projectsedit,
        builder: (context, state) {
          final projectId = state.pathParameters['projectsId'];
          if (projectId == null) {
            return const ProjectsListView(); // Redirect to projects list
          }
          return EditProjectFormScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: RouteNames.clientsedit, // '/plants/edit/:plantId'
        name: RouteNames.clientsedit,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId'];
          if (clientId == null) {
            return const ClientsListView();
          }
          return EditClientFormScreen(clientId: clientId);
        },
      ),
      GoRoute(
        path: RouteNames.jobOrderedit, // '/plants/edit/:plantId'
        name: RouteNames.jobOrderedit,
        builder: (context, state) {
          final mongoId = state.pathParameters['mongoId'];
          if (mongoId == null) {
            return const JobOrderListView();
          }
          return JobOrderEditFormScreen(mongoId: mongoId);
        },
      ),
      GoRoute(
        name: RouteNames.jobOrderView,
        path: '/job-order/view/:mongoId',
        builder: (context, state) {
          final jobOrder = state.extra as JobOrderModel;
          return JobOrderViewScreen(jobOrder: jobOrder);
        },
      ),
      GoRoute(
        path: RouteNames.homeScreen,
        name: RouteNames.homeScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: RouteNames.jobOrder,
        name: RouteNames.jobOrder,
        builder: (BuildContext context, GoRouterState state) {
          return const JobOrderListView();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
