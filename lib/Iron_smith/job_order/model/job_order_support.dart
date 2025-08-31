class DateRange {
  String? from;
  String? to;

  DateRange({this.from, this.to});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      DateRange(from: json["from"], to: json["to"]);

  Map<String, dynamic> toJson() => {"from": from, "to": to};
}

class ProductIS {
  String? id;
  String? shapeId;
  String? shapeCode;
  String? uom;
  String? member;
  String? barMark;
  String? weight;
  String? description;
  int? plannedQuantity;
  String? scheduleDate;
  int? dia;
  int? achievedQuantity;
  int? rejectedQuantity;
  List<Machine>? selectedMachines;
  String? qrCodeId;
  String? qrCodeUrl;
  int? poQuantity;
  List<Dimension>? dimensions;

  ProductIS({
    this.id,
    this.shapeId,
    this.shapeCode,
    this.uom,
    this.member,
    this.barMark,
    this.weight,
    this.description,
    this.plannedQuantity,
    this.scheduleDate,
    this.dia,
    this.achievedQuantity,
    this.rejectedQuantity,
    this.selectedMachines,
    this.qrCodeId,
    this.qrCodeUrl,
    this.poQuantity,
    this.dimensions,
  });

  factory ProductIS.fromJson(Map<String, dynamic> json) => ProductIS(
    id: json["_id"],
    shapeId: json["shape_id"],
    shapeCode: json["shape_code"],
    uom: json["uom"],
    member: json["member"],
    barMark: json["barMark"],
    weight: json["weight"],
    description: json["description"],
    plannedQuantity: json["planned_quantity"],
    scheduleDate: json["schedule_date"],
    dia: json["dia"],
    achievedQuantity: json["achieved_quantity"],
    rejectedQuantity: json["rejected_quantity"],
    selectedMachines: json["selected_machines"] == null
        ? []
        : List<Machine>.from(
            json["selected_machines"].map((x) => Machine.fromJson(x)),
          ),
    qrCodeId: json["qr_code_id"],
    qrCodeUrl: json["qr_code_url"],
    poQuantity: json["po_quantity"],
    dimensions: json["dimensions"] == null
        ? []
        : List<Dimension>.from(
            json["dimensions"].map((x) => Dimension.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "shape_id": shapeId,
    "shape_code": shapeCode,
    "uom": uom,
    "member": member,
    "barMark": barMark,
    "weight": weight,
    "description": description,
    "planned_quantity": plannedQuantity,
    "schedule_date": scheduleDate,
    "dia": dia,
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
    "selected_machines": selectedMachines == null
        ? []
        : List<dynamic>.from(selectedMachines!.map((x) => x.toJson())),
    "qr_code_id": qrCodeId,
    "qr_code_url": qrCodeUrl,
    "po_quantity": poQuantity,
    "dimensions": dimensions == null
        ? []
        : List<dynamic>.from(dimensions!.map((x) => x.toJson())),
  };
}

class Dimension {
  String? name;
  String? value;

  Dimension({this.name, this.value});

  factory Dimension.fromJson(Map<String, dynamic> json) =>
      Dimension(name: json["name"], value: json["value"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value};
}

class Machine {
  String? id;
  String? name;

  Machine({this.id, this.name});

  factory Machine.fromJson(Map<String, dynamic> json) =>
      Machine(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class User {
  String? id;
  String? email;
  String? username;

  User({this.id, this.email, this.username});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["_id"], email: json["email"], username: json["username"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}

class WorkOrderIS {
  String? id;
  String? workOrderNumber;

  WorkOrderIS({this.id, this.workOrderNumber});

  factory WorkOrderIS.fromJson(Map<String, dynamic> json) {
    return WorkOrderIS(
      id: json["_id"],
      workOrderNumber: json["workOrderNumber"],
    );
  }
  Map<String, dynamic> toJson() => {
    "_id": id,
    "workOrderNumber": workOrderNumber,
  };
}
