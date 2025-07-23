import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/dashboard/view/dashboard_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_add_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machine_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/view/machines_list_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plants_screen_list.dart';
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
        path: RouteNames.clients,
        name: RouteNames.clients,
        builder: (BuildContext context, GoRouterState state) {
          return ClientsListView();
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
        path: RouteNames.plantsadd,
        name: RouteNames.plantsadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddPlantFormScreen();
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
        path: RouteNames.machinesadd,
        name: RouteNames.machinesadd,
        builder: (BuildContext context, GoRouterState state) {
          return MachineAddScreen();
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
            // Handle missing plantId gracefully
            return const PlantsListView(); // Redirect to plants list
          }
          return EditPlantFormScreen(plantId: plantId);
        },
      ),
      GoRoute(
        path: RouteNames.clientsedit,
        name: RouteNames.clientsedit,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId'];
          if (clientId == null) {
            // Handle missing clientId gracefully
            return const ClientsListView(); // Redirect to clients list
          }
          return EditClientFormScreen(clientId: clientId);
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
        path: RouteNames.homeScreen,
        name: RouteNames.homeScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardPage();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
