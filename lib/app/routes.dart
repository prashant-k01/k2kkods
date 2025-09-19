import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/job_order/view/job_order_detail_screen.dart';
import 'package:k2k/Iron_smith/job_order/view/job_order_list_screen.dart';
import 'package:k2k/Iron_smith/job_order/view/joborder_add_screen.dart';
import 'package:k2k/Iron_smith/master_data/clients/view/is_client_add_screen.dart';
import 'package:k2k/Iron_smith/master_data/clients/view/is_client_edit_screen.dart';
import 'package:k2k/Iron_smith/master_data/clients/view/is_client_list_screen.dart';
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/Iron_smith/master_data/machines/view/machine_add.dart';
import 'package:k2k/Iron_smith/master_data/machines/view/machine_edit.dart';
import 'package:k2k/Iron_smith/master_data/machines/view/machine_list.dart';
import 'package:k2k/Iron_smith/master_data/projects/view/is_project_add_screen.dart';
import 'package:k2k/Iron_smith/master_data/projects/view/is_project_edit_screen.dart';
import 'package:k2k/Iron_smith/master_data/projects/view/is_project_list_screen.dart';
import 'package:k2k/Iron_smith/master_data/projects/view/is_raw_material_screen.dart';
import 'package:k2k/Iron_smith/master_data/shapes/view/shape_add_screen.dart';
import 'package:k2k/Iron_smith/master_data/shapes/view/shape_detail_screen.dart';
import 'package:k2k/Iron_smith/master_data/shapes/view/shape_edit_screen.dart';
import 'package:k2k/Iron_smith/master_data/shapes/view/shapes_list_screen.dart';
import 'package:k2k/Iron_smith/workorder/view/iron_workorder_add_screen.dart';
import 'package:k2k/Iron_smith/workorder/view/iron_workorder_edit_screen.dart';
import 'package:k2k/Iron_smith/workorder/view/iron_workorder_list_screen.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/dashboard/view/dashboard_screen.dart';
import 'package:k2k/konkrete_klinkers/dispatch/view/dispatch_add_screen.dart';
import 'package:k2k/konkrete_klinkers/dispatch/view/dispatch_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/dispatch/view/dispatch_list_screen.dart';
import 'package:k2k/konkrete_klinkers/inventory/view/inventory_detailscreen.dart';
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
import 'package:k2k/konkrete_klinkers/packing/view/packing_view.dart';
import 'package:k2k/konkrete_klinkers/production/view/downtime_screen.dart';
import 'package:k2k/konkrete_klinkers/production/view/production%20planning%20screen.dart';
import 'package:k2k/konkrete_klinkers/production/view/production_log_screen.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_add_screen.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_edit.dart';
import 'package:k2k/konkrete_klinkers/qc_check/view/qc_check_list_screen.dart';
import 'package:k2k/konkrete_klinkers/stock_management/view/stock_add_screen.dart';
import 'package:k2k/konkrete_klinkers/stock_management/view/stock_list_screen.dart';
import 'package:k2k/konkrete_klinkers/stock_management/view/stock_view_screen.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_add_screen.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_detail_page.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_edit_screen.dart';
import 'package:k2k/konkrete_klinkers/work_order/view/work_order_list_screen.dart';
import 'package:k2k/login/view/login_screen.dart';
import 'package:k2k/utils/splashscreen/splash_screen.dart';

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
        path: RouteNames.inventorydetail,
        name: RouteNames.inventorydetail,
        builder: (BuildContext context, GoRouterState state) {
          final productId = state.extra as String? ?? '';
          return InventoryDetailScreen(productId: productId);
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
        path: RouteNames.stockmanagementAdd,
        name: RouteNames.stockmanagementAdd,
        builder: (BuildContext context, GoRouterState state) {
          return const StockManagementFormScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.stockmanagementview}/:id',
        name: RouteNames.stockmanagementview,
        builder: (BuildContext context, GoRouterState state) {
          final id =
              state.pathParameters['id']; // Extract the id from path parameters
          if (id == null) {
            return const Center(child: Text('ID is required'));
          }
          return StockDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: RouteNames.stockmanagement,
        name: RouteNames.stockmanagement,
        builder: (BuildContext context, GoRouterState state) {
          return const StockManagementListView();
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
        path: RouteNames.packingDetails,
        name: RouteNames.packingDetails,
        builder: (context, state) {
          final workOrderId = state.pathParameters['workOrderId']!;
          final productId = state.pathParameters['productId']!;
          return PackingDetailsView(
            workOrderId: workOrderId,
            productId: productId,
          );
        },
      ),

      GoRoute(
        path: RouteNames.dispatchAdd,
        name: RouteNames.dispatchAdd,
        builder: (BuildContext context, GoRouterState state) {
          return const AddDispatchFormScreen();
        },
      ),
      GoRoute(
        path: '/edit-dispatch/:dispatchId',
        name: RouteNames.dispatchEdit,
        builder: (context, state) => EditDispatchFormScreen(
          dispatchId: state.pathParameters['dispatchId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.production,
        name: RouteNames.production,
        builder: (BuildContext context, GoRouterState state) {
          return ProductionScreen();
        },
      ),
      GoRoute(
        path: RouteNames.downtime,
        name: RouteNames.downtime,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return DowntimeScreen(
            productId: extra['productId'],
            jobOrder: extra['jobOrder'],
          );
        },
      ),
      GoRoute(
        path: RouteNames.logs,
        name: RouteNames.logs,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return ProductionLogScreen(
            productId: extra['productId'],
            jobOrder: extra['jobOrder'],
          );
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
        path: RouteNames.workorderdetail,
        name: RouteNames.workorderdetail,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'];
          if (id == null) {
            return const Center(child: Text('Work Order ID is required'));
          }
          return WorkOrderDetailsPage(workOrderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.workorders,
        name: RouteNames.workorders,
        builder: (BuildContext context, GoRouterState state) {
          return WorkOrderListView();
        },
      ),
      GoRoute(
        path: RouteNames.dispatch,
        name: RouteNames.dispatch,
        builder: (BuildContext context, GoRouterState state) {
          return DispatchListView();
        },
      ),
      GoRoute(
        path: RouteNames.workordersadd,
        name: RouteNames.workordersadd,
        builder: (BuildContext context, GoRouterState state) {
          return AddWorkOrderScreen();
        },
      ),
      GoRoute(
        path: RouteNames.workordersedit,
        name: RouteNames.workordersedit,
        builder: (context, state) {
          final workOrderId = state.pathParameters['workorderId'];
          if (workOrderId == null) {
            return const WorkOrderListView();
          }
          return EditWorkOrderScreen(workOrderId: workOrderId);
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

      //IRON SMITH//
      GoRoute(
        path: RouteNames.isMachineAdd,
        name: RouteNames.isMachineAdd,
        builder: (BuildContext context, GoRouterState state) {
          return const IsMachineAddScreen();
        },
      ),
      GoRoute(
        path: RouteNames.ismachine,
        name: RouteNames.ismachine,
        builder: (BuildContext context, GoRouterState state) {
          return const IsMachinesListScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.isMachineEdit}/:machineId',
        name: RouteNames.isMachineEdit,
        builder: (BuildContext context, GoRouterState state) {
          final machineId = state.pathParameters['machineId'];

          if (machineId == null || machineId.isEmpty) {
            context.go(RouteNames.ismachine);
            return const IsMachinesListScreen();
          }

          return IsMachineEditScreen(machineId: machineId);
        },
      ),

      //IsClients
      GoRoute(
        path: RouteNames.isclients,
        name: RouteNames.isclients,
        builder: (BuildContext context, GoRouterState state) {
          return const IsClientsListScreen();
        },
      ),

      GoRoute(
        path: RouteNames.isClientAdd,
        name: RouteNames.isClientAdd,
        builder: (BuildContext context, GoRouterState state) {
          return const IsClientAddScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.isClientEdit}/:clientId',
        name: RouteNames.isClientEdit,
        builder: (BuildContext context, GoRouterState state) {
          final clientId = state.pathParameters['clientId'];

          if (clientId == null || clientId.isEmpty) {
            context.go(RouteNames.ismachine);
            return const IsClientsListScreen();
          }

          return IsClientEditScreen(clientId: clientId);
        },
      ),

      //IsProjects
      GoRoute(
        path: RouteNames.isProjects,
        name: RouteNames.isProjects,
        builder: (BuildContext context, GoRouterState state) {
          return const IsProjectsListScreen();
        },
      ),
      GoRoute(
        path:
            '${RouteNames.isRawMaterial}/:projectId', // Define the path with projectId as a parameter
        name: RouteNames.isRawMaterial,
        builder: (BuildContext context, GoRouterState state) {
          final projectId =
              state.pathParameters['projectId']!; // Extract projectId from path
          return IsRawMaterialScreen(
            projectId: projectId,
          ); // Pass it to the widget
        },
      ),
      GoRoute(
        path: RouteNames.isProjectAdd,
        name: RouteNames.isProjectAdd,
        builder: (BuildContext context, GoRouterState state) {
          return const IsProjectAddScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.isProjectEdit}/:projectId',
        name: RouteNames.isProjectEdit,
        builder: (BuildContext context, GoRouterState state) {
          final projectId = state.pathParameters['projectId'];

          if (projectId == null || projectId.isEmpty) {
            context.go(RouteNames.ismachine);
            return const IsProjectsListScreen();
          }

          return IsProjectEditScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: RouteNames.allshapes,
        name: RouteNames.allshapes,
        builder: (BuildContext context, GoRouterState state) {
          return const ShapesListScreen();
        },
      ),
      GoRoute(
        path: RouteNames.addshapes,
        name: RouteNames.addshapes,
        builder: (BuildContext context, GoRouterState state) {
          return const ShapeAddScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.editshapes}/:shapeId',
        name: RouteNames.editshapes,
        builder: (BuildContext context, GoRouterState state) {
          final shapeId = state
              .pathParameters['shapeId']; // Extract shapeId from path parameters
          if (shapeId == null || shapeId.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.allshapes);
            });
            return const SizedBox();
          }
          return ShapeEditScreen(shapeId: shapeId);
        },
      ),
      GoRoute(
        path: '${RouteNames.viewshapes}/:shapeId',
        name: RouteNames.viewshapes,
        builder: (BuildContext context, GoRouterState state) {
          final shapeId = state.pathParameters['shapeId'];
          if (shapeId == null || shapeId.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.allshapes);
            });
            return const SizedBox();
          }
          return ShapeDetailsScreen(shapeId: shapeId);
        },
      ),
      GoRoute(
        path: RouteNames.getAllIronWO,
        name: RouteNames.getAllIronWO,
        builder: (BuildContext context, GoRouterState state) {
          return const IronWorkOrderListView();
        },
      ),
      GoRoute(
        path: RouteNames.addIronWO,
        name: RouteNames.addIronWO,
        builder: (BuildContext context, GoRouterState state) {
          return const IronWorkorderAddScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.editIronWO}/:workorderId',
        name: RouteNames.editIronWO,
        builder: (context, state) {
          final workOrderId = state.pathParameters['workorderId'];
          if (workOrderId == null) {
            return const IronWorkOrderListView();
          }
          return IronWorkorderEditScreen(workorderId: workOrderId);
        },
      ),
      GoRoute(
        path: RouteNames.ironJobOrder,
        name: RouteNames.ironJobOrder,
        builder: (BuildContext context, GoRouterState state) {
          return const JobOrderListViewIS();
        },
      ),
      GoRoute(
        path: RouteNames.addIronJobOrder,
        name: RouteNames.addIronJobOrder,
        builder: (BuildContext context, GoRouterState state) {
          return const IronJoborderAddScreen();
        },
      ),
      GoRoute(
        path: '${RouteNames.viewIronJobOrder}/:joborderId',
        name: RouteNames.viewIronJobOrder,
        builder: (BuildContext context, GoRouterState state) {
          final joborderId = state.pathParameters['joborderId'];
          if (joborderId == null) {
            return const JobOrderListViewIS();
          }
          return IronJobOrderViewScreen(jobOrderId: joborderId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
