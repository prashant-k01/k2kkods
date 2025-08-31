class Shape {
  String? id;
  Dimension? dimension;
  String? description;
  String? shapeCode;
  FileClass? file;
  CreatedBy? createdBy;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? v;

  Shape({
    this.id,
    this.dimension,
    this.description,
    this.shapeCode,
    this.file,
    this.createdBy,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Shape.fromJson(Map<String, dynamic> json) {
    print('Shape.fromJson: Parsing JSON: $json');
    try {
      return Shape(
        id: json['_id']?.toString(),
        dimension: json['dimension'] != null
            ? Dimension.fromJson(json['dimension'] as Map<String, dynamic>)
            : null,
        description: json['description']?.toString(),
        shapeCode: json['shape_code']?.toString(),
        file: json['file'] != null
            ? FileClass.fromJson(json['file'] as Map<String, dynamic>)
            : null,
        createdBy: json['created_by'] != null
            ? CreatedBy.fromJson(json['created_by'] as Map<String, dynamic>)
            : null,
        isDeleted: json['isDeleted'] as bool?,
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        v: json['__v'] != null ? int.tryParse(json['__v'].toString()) : null,
      );
    } catch (e) {
      print('Shape.fromJson: Error parsing JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'dimension': dimension?.toJson(),
    'description': description,
    'shape_code': shapeCode,
    'file': file?.toJson(),
    'created_by': createdBy?.toJson(),
    'isDeleted': isDeleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
  };
}

class Dimension {
  String? id;
  String? dimensionName;

  Dimension({this.id, this.dimensionName});

  factory Dimension.fromJson(Map<String, dynamic> json) {
    print('Dimension.fromJson: Parsing JSON: $json');
    try {
      return Dimension(
        id: json['_id']?.toString(),
        dimensionName: json['dimension_name']?.toString(),
      );
    } catch (e) {
      print('Dimension.fromJson: Error parsing JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {'_id': id, 'dimension_name': dimensionName};
}

class FileClass {
  String? fileName;
  String? fileUrl;

  FileClass({this.fileName, this.fileUrl});

  factory FileClass.fromJson(Map<String, dynamic> json) {
    print('FileClass.fromJson: Parsing JSON: $json');
    try {
      return FileClass(
        fileName: json['file_name']?.toString(),
        fileUrl: json['file_url']?.toString(),
      );
    } catch (e) {
      print('FileClass.fromJson: Error parsing JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {'file_name': fileName, 'file_url': fileUrl};
}

class CreatedBy {
  String? id;
  String? email;
  String? username;

  CreatedBy({this.id, this.email, this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    print('CreatedBy.fromJson: Parsing JSON: $json');
    try {
      return CreatedBy(
        id: json['_id']?.toString(),
        email: json['email']?.toString(),
        username: json['username']?.toString(),
      );
    } catch (e) {
      print('CreatedBy.fromJson: Error parsing JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'username': username,
  };
}
