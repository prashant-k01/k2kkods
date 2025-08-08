class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String homeScreen = '/homescreen';
  //clients
  static const String clientsadd = '/clientsadd';
  static const String clientsedit = '/clients/edit/:clientId';
  static const String clients = '/clients';
  //plants
  static const String plants = '/plants';
  static const String inventory = '/inventory';
  static const String inventorydetail= '/inventorydetail';
  static const String plantsadd = '/plantsadd';
  static const String plantsedit = '/plants/edit/:plantId';
  //projects
  static const String projects = '/projects';
  static const String projectsadd = '/projectsadd';
  static const String projectsedit = '/projects/edit/:projectsId';
  //products
  static const String products = '/products';
  static const String productedit = '/product/edit/:productId';
  static const String productsadd = '/productsadd';
  //job order
  static const String jobOrder = '/joborder';
  static const String joborderadd = '/joborderadd';
  static const String jobOrderedit = '/joborder/edit/:mongoId';
  static const jobOrderView = 'job-order-view';
  //qc check
  static const qcCheck = '/qc-check';
  static const String qcCheckAdd = '/qcadd';
  static const String qcCheckEdit = 'qcCheckEdit';
  //machines
  static const String machines = '/machines';
  static const String machinesadd = '/machinesadd';
  static const String machinesedit = '/machines/edit/:machineId';
  //packing
  static const String packing = '/packing';
  static const String packingadd = '/packingadd';
  static const String packingDetails =
      '/packing-details/:workOrderId/:productId';
  //workorder
  static const String workordersadd = '/workordersadd';
  static const String workordersedit = '/workorders/edit/:workorderId';
  static const String workorders = '/workorders';
  static const String workorderdetail = '/workorderdetail';
  //stock management
  static const String stockmanagement = "/stockmanagement";
  static const String stockmanagementAdd = "/stockmanagementAdd";
  static const String stockmanagementview = "/stockmanagementview";
  //production
  static const String production = '/production';
  static const String downtime = '/downtime';
  static const String logs = '/logs';
  //dispatch
  static const String dispatch = "/dispatch";
  static const String dispatchAdd = "/dispatchAdd";
  static const String dispatchEdit = "/dispatchEdit";
}
