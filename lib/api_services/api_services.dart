class AppUrl {
  // static const String baseUrl/api = 'http://3.6.6.231/api';
  static const String baseUrl = 'http://43.204.242.233';

  static const String loginUrl = '$baseUrl/api/users/login';
  //Plants Urls
  static const String allPlantsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/plants';
  static const String addPlantUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/plant';

  static const String updatePlanturl =
      '$baseUrl/api/konkreteKlinkers/helpers/plants';
  static const String deletePlantUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/plants/delete';

  //Machine's Urls
  static const String createMachineUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/machine';
  static const String fetchMachineDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/machines';
  static const String updateMachineDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/machines';
  static const String deleteMachineDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/machines/delete';

  //Client's Urls
  static const String createClientUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/clients';
  static const String fetchClientDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/clients';

  static const String updateClientDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/clients';
  static const String deleteClientDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/clients/delete';

  //projects's Urls
  static const String createProjectUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/projects';
  static const String fetchProjectDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/projects';
  static const String updateProjectDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/projects';
  static const String deleteProjectDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/projects/delete';

  //inventory
  static const String getinventory =
      'http://3.6.6.231/api/konkreteKlinkers/inventories';

  //Products's Urls
  static const String createproductUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/products';
  static const String fetchproductDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/products';
  static const String updateproductDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/products';
  static const String deleteproductDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/helpers/products/delete';

  //WorkOrder's Urls
  static const String createWorkOrderUrl =
      '$baseUrl/api/konkreteKlinkers/workorder/create';
  static const String updateWorkOrderUrl =
      '$baseUrl/api/konkreteKlinkers/workorders';
  static const String fetchWorkOrderDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/workorders';
  static const String updateWorkOrderDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/workorders';
  static const String deleteWorkOrderDetailsUrl =
      '$baseUrl/api/konkreteKlinkers/workorders-delete';
  static const String getWOProjectbyClient =
      '$baseUrl/api/konkreteKlinkers/workorders-getProject?clientId=';
  static const String getjoborder = "$baseUrl/api/konkreteKlinkers/joborders";
  static const String createJoborder =
      "$baseUrl/api/konkreteKlinkers/joborder/create";
  static const String getproductsbyworkOrder =
      "$baseUrl/api/dropdown/products?work_order_id=";
  static const String updateJobOrder =
      "$baseUrl/api/konkreteKlinkers/joborders";

  static const String deleteJobOrder =
      "$baseUrl/api/konkreteKlinkers/joborders/delete";
  static const String getjoborderbyId =
      "$baseUrl/api/konkreteKlinkers/joborders";
  static const String getJOMachinesbyProduct =
      "$baseUrl/api/konkreteKlinkers/joborder-getMachine?material_code=";

  //production
  static const String getProductionJoborderBydate =
      "$baseUrl/api/konkreteKlinkers/production";
  static const String startTheProduction =
      "$baseUrl/api/konkreteKlinkers/production/action";
  static const String addDownTime =
      "$baseUrl/api/konkreteKlinkers/production/downtime";
  static const String fetchDownTimeLogs =
      "$baseUrl/api/konkreteKlinkers/production/downtime?product_id=";
  static const String fetchProductionLogs =
      "$baseUrl/api/konkreteKlinkers/production/log?product_id=";
  static const String updatedProduction =
      "$baseUrl/api/konkreteKlinkers/updated-production?product_id=";

  //Qc check
  static const String getKKqcCheckData =
      "$baseUrl/api/konkreteKlinkers/qc-check";
  static const String createKKQcCheckUrl =
      "$baseUrl/api/konkreteKlinkers/qc-check";
  static const String getProductByjobOrder =
      "$baseUrl/api/konkreteKlinkers/qc-check/products?id=";
  static const String getDropdownJobOrder =
      "https://k2k.kods.work/api/dropdown/joborders";
  static const String deleteQcCheck =
      "$baseUrl/api/konkreteKlinkers/qc-check/delete";

  //Packing
  static const String getpacking = "$baseUrl/api/konkreteKlinkers/packing";
  static const String getpackingqr =
      "$baseUrl/api/konkreteKlinkers/packing/create";
  static const String kkpackingByID =
      "$baseUrl/api/konkreteKlinkers/packing/get";
  static const String createPacking = "$baseUrl/api/konkreteKlinkers/packing";

  static const String deletePacking =
      "$baseUrl/api/konkreteKlinkers/packing/delete";

  static const String getpackingbundlesizeurl =
      "$baseUrl/api/konkreteKlinkers/packing/bundlesize";

  static const String fetchProductDetailsUrl =
      'https://k2k.kods.work/api/dropdown/products';

  //Dispatch
  static const String kkdispatch = "$baseUrl/api/konkreteKlinkers/dispatch";
  static const String createdispatch =
      "$baseUrl/api/konkreteKlinkers/dispatch/create";
  static const String getdispatchbundlesizeurl =
      "$baseUrl/api/konkreteKlinkers/dispatch/bundlesize";
  static const String qrScanUrl =
      "$baseUrl/api/konkreteKlinkers/dispatch/qrscan";

  //Inventory
  static const String kkinventories =
      "$baseUrl/api/konkreteKlinkers/inventories";
  static const String createinventories =
      "$baseUrl/api/konkreteKlinkers/inventories/create";
  static const String getinventoriesbyid =
      "$baseUrl/api/konkreteKlinkers/inventory";

  //Stock Managment
  //Stock Managment
  static const String kkStockManagement =
      "$baseUrl/api/konkreteKlinkers/transfer";
  static const String createStockManagement =
      "$baseUrl/api/konkreteKlinkers/transfer/create";
  // static const String getStockManagementbyid = "$baseUrl/api/konkreteKlinkers/inventory";
  static const String getwobyproduct =
      "$baseUrl/api/konkreteKlinkers/transfer-getworkorder";
  static const String getAchievedQuantity =
      "$baseUrl/api/konkreteKlinkers/transfer-getworkorderproduct";

  ////////////////////////////IRON SMITH///////////////////////////////////////////////////////
  //machines
  // static const String baseUrlIronSmith =
  //     'https://k2k-backend-1.onrender.com/api/ironSmith';
  //

  static const String baseUrlIronSmith = 'http://43.204.242.233/api/ironSmith';

  static const String getIsMachines = "$baseUrlIronSmith/helpers/machines";
  static String getIsMachineById(String id) => "$getIsMachines/$id";
  static const String deleteIsMachines =
      "$baseUrlIronSmith/helpers/machines/delete";

  //Clients
  static const String getAllClients = "$baseUrlIronSmith/helpers/clients";
  static String getClientById(String id) => "$getAllClients/$id";
  static const String deleteIsClient =
      "$baseUrlIronSmith/helpers/clients/delete";

  //Projects
  static const String getAllProjects = "$baseUrlIronSmith/helpers/projects";
  static String getProjectById(String id) => "$getAllProjects/$id";
  static const String deleteIsProject =
      "$baseUrlIronSmith/helpers/projects/delete";

  static String getProjectsByClientId(String clientId) =>
      "$baseUrlIronSmith/workorders-getProject?clientId=$clientId";

  static String getDiameterByProject(String projectId) =>
      "$baseUrlIronSmith/raw-data/$projectId";

  static String getDimensionByShape(String shapeId) =>
      "$baseUrlIronSmith/dimension-by-shape/$shapeId";

  //Shapes
  static const String shapes = "$baseUrlIronSmith/helpers/shapes";
  static const String dimension = "$baseUrlIronSmith/dropdown/dimensions";
  static String shapeById(String id) => "$shapes/$id";
  static const String deleteShapes = "$baseUrlIronSmith/helpers/shapes/delete";

  //work Orders
  static const String getAllWorkOrder = "$baseUrlIronSmith/workorder/get";
  static const String createWorkOrder = "$baseUrlIronSmith/workorder/create";

  static String getWorkOrderById(String id) =>
      "$baseUrlIronSmith/workorder/$id";

  //job Orders
  static const String getAllJobOrder = "$baseUrlIronSmith/joborder/get";
  static const String createISJobOrder = "$baseUrlIronSmith/joborder/create";
  static const String deleteISJobOrder = "$baseUrlIronSmith/joborder/delete";
  static String getWorkOrderByWorkOrderId(String id) =>
      "$baseUrlIronSmith/joborder/workorderdata/$id";

  static String getJobOrderById(String id) => "$baseUrlIronSmith/joborder/$id";
}
