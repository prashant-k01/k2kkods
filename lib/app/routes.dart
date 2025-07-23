import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/dashboard/view/dashboard_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/view/clients_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plant_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/view/plants_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/view/product_screen_list.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_add.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/view/projects_screen_list.dart';
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
        path: RouteNames.projects,
        name: RouteNames.projects,
        builder: (BuildContext context, GoRouterState state) {
          return ProjectsListView();
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
        path: RouteNames.projectsedit, // '/projects/edit/:projectsId'
        name: RouteNames.projectsedit,
        builder: (context, state) {
          final projectId = state
              .pathParameters['projectsId']; // Fix: Use 'projectsId' instead of 'plantId'
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
