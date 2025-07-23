class AppUrl {
  //   static const String baseUrl = 'https://k2k_new-iot-backend-2.onrender.com';
  //   static const String baseUrl = 'https://k2k-iot-backend-2.onrender.com/api/';
  static const String baseUrl = 'http://3.6.6.231/api';

  static const String loginUrl = '$baseUrl/users/login';
  //Plants Urls
  static const String allPlantsUrl = '$baseUrl/konkreteKlinkers/helpers/plants';
  static const String addPlantUrl = '$baseUrl/konkreteKlinkers/helpers/plant';

  static const String updatePlanturl =
      '$baseUrl/konkreteKlinkers/helpers/plants';
  static const String deletePlantUrl =
      '$baseUrl/konkreteKlinkers/helpers/plants/delete';

  static const String addMachineUrl =
      '$baseUrl/konkreteKlinkers/helpers/machine';
  static const String fetchMachineUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines';
  static const String deleteMachineUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines/delete';
  static const String updateMachineurl =
      '$baseUrl/konkreteKlinkers/helpers/machines/';

  //Client's Urls
  static const String createClientUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';
  static const String fetchClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';
  static const String updateClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';
  static const String deleteClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients/delete';

  //Machine's Urls
  static const String createMachineUrl =
      '$baseUrl/konkreteKlinkers/helpers/machine';
  static const String fetchMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines';
  static const String updateMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines';
  static const String deleteMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines/delete';

  //projects's Urls
  static const String createProjectUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String fetchProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String updateProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String deleteProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects/delete';

  //Products's Urls
  static const String createproductUrl =
      '$baseUrl/konkreteKlinkers/helpers/products';
  static const String fetchproductDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/products';
  static const String updateproductDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/products';
  static const String deleteproductDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/products/delete';

  //WorkOrder's Urls
  static const String createWorkOrderUrl =
      '$baseUrl/konkreteKlinkers/workorder/create';
  static const String updateWorkOrderUrl =
      '$baseUrl/konkreteKlinkers/workorders';
  static const String fetchWorkOrderDetailsUrl =
      '$baseUrl/konkreteKlinkers/workorders';
  static const String updateWorkOrderDetailsUrl =
      '$baseUrl/konkreteKlinkers/workorders';
  static const String deleteWorkOrderDetailsUrl =
      '$baseUrl/konkreteKlinkers/workorders-delete';
  static const String getWOProjectbyClient =
      '$baseUrl/konkreteKlinkers/workorders-getProject?clientId=';

  //JobOrder
  static const String joborder = "$baseUrl/konkreteKlinkers/joborders";
  static const String createJoborder =
      "$baseUrl/konkreteKlinkers/joborder/create";
  static const String getproductsbyworkOrder =
      "$baseUrl/dropdown/products?work_order_id=";
  static const String getJOMachinesbyProduct =
      "$baseUrl/konkreteKlinkers/joborder-getMachine?material_code=";

  //production
  static const String getProductionJoborderBydate =
      "$baseUrl/konkreteKlinkers/production";
  static const String startTheProduction =
      "$baseUrl/konkreteKlinkers/production/action";
  static const String addDownTime =
      "$baseUrl/konkreteKlinkers/production/downtime";
  static const String fetchDownTimeLogs =
      "$baseUrl/konkreteKlinkers/production/downtime?product_id=";
  static const String fetchProductionLogs =
      "$baseUrl/konkreteKlinkers/production/log?product_id=";
  static const String updatedProduction =
      "$baseUrl/konkreteKlinkers/updated-production";

  //Qc check
  static const String getKKqcCheckData = "$baseUrl/konkreteKlinkers/qc-check";
  static const String createKKQcCheckUrl = "$baseUrl/konkreteKlinkers/qc-check";
  static const String getProductByjobOrder =
      "$baseUrl/konkreteKlinkers/qc-check/products?id=";

  //Packing
  static const String kkpacking = "$baseUrl/konkreteKlinkers/packing";
  static const String kkpackingByID = "$baseUrl/konkreteKlinkers/packing/get";
  static const String createPacking =
      "$baseUrl/konkreteKlinkers/packing/create";
  static const String getpackingbundlesizeurl =
      "$baseUrl/konkreteKlinkers/packing/bundlesize";

  //Dispatch
  static const String kkdispatch = "$baseUrl/konkreteKlinkers/dispatch";
  static const String createdispatch =
      "$baseUrl/konkreteKlinkers/dispatch/create";
  static const String getdispatchbundlesizeurl =
      "$baseUrl/konkreteKlinkers/dispatch/bundlesize";

  //Inventory
  static const String kkinventories = "$baseUrl/konkreteKlinkers/inventories";
  static const String createinventories =
      "$baseUrl/konkreteKlinkers/inventories/create";
  static const String getinventoriesbyid =
      "$baseUrl/konkreteKlinkers/inventory";

  //Stock Managment
  static const String kkStockManagement = "$baseUrl/konkreteKlinkers/transfer";
  static const String createStockManagement =
      "$baseUrl/konkreteKlinkers/transfer/create";
  // static const String getStockManagementbyid = "$baseUrl/konkreteKlinkers/inventory";
  static const String getwobyproduct =
      "$baseUrl/konkreteKlinkers/transfer-getworkorder?prId=";
}
