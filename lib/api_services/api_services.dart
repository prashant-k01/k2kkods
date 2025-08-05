class AppUrl {
  static const String baseUrl = 'http://3.6.6.231/api';

  static const String loginUrl = '$baseUrl/users/login';
  //Plants Urls
  static const String allPlantsUrl = '$baseUrl/konkreteKlinkers/helpers/plants';
  static const String addPlantUrl = '$baseUrl/konkreteKlinkers/helpers/plant';

  static const String updatePlanturl =
      '$baseUrl/konkreteKlinkers/helpers/plants';
  static const String deletePlantUrl =
      '$baseUrl/konkreteKlinkers/helpers/plants/delete';

  //Machine's Urls
  static const String createMachineUrl =
      '$baseUrl/konkreteKlinkers/helpers/machine';
  static const String fetchMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines';
  static const String updateMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines';
  static const String deleteMachineDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/machines/delete';

  //Client's Urls
  static const String createClientUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';
  static const String fetchClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';

  static const String updateClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients';
  static const String deleteClientDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/clients/delete';

  //projects's Urls
  static const String createProjectUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String fetchProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String updateProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects';
  static const String deleteProjectDetailsUrl =
      '$baseUrl/konkreteKlinkers/helpers/projects/delete';

  //inventory
  static const String getinventory =
      'http://3.6.6.231/api/konkreteKlinkers/inventories';

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

  static const String getjoborder = "$baseUrl/konkreteKlinkers/joborders";
  static const String createJoborder =
      "$baseUrl/konkreteKlinkers/joborder/create";
  static const String getproductsbyworkOrder =
      "$baseUrl/dropdown/products?work_order_id=";
  static const String updateJobOrder = "$baseUrl/konkreteKlinkers/joborders";

  static const String deleteJobOrder =
      "$baseUrl/konkreteKlinkers/joborders/delete";
  static const String getjoborderbyId = "$baseUrl/konkreteKlinkers/joborders";
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
  static const String getDropdownJobOrder =
      "https://k2k.kods.work/api/dropdown/joborders";
  static const String deleteQcCheck =
      "$baseUrl/konkreteKlinkers/qc-check/delete";

  //Packing
  static const String getpacking = "$baseUrl/konkreteKlinkers/packing";
  static const String getpackingqr = "$baseUrl/konkreteKlinkers/packing/create";
  static const String kkpackingByID = "$baseUrl/konkreteKlinkers/packing/get";
  static const String createPacking =
      "$baseUrl/konkreteKlinkers/packing";
      
  static const String getpackingbundlesizeurl =
      "$baseUrl/konkreteKlinkers/packing/bundlesize";

  static const String fetchProductDetailsUrl =
      'https://k2k.kods.work/api/dropdown/products';

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
