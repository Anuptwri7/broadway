class ItemResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<ItemModel> results;

  ItemResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => ItemModel.fromJson(item))
          .toList(),
    );
  }
}

class ItemModel {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final Description description;
  final Unit unit;
  final User createdBy;
  final dynamic modifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.description,
    required this.unit,
    required this.createdBy,
    this.modifiedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isActive: json['isActive'],
      description: Description.fromJson(json['description']),
      unit: Unit.fromJson(json['unit']),
      createdBy: User.fromJson(json['createdBy']),
      modifiedBy: json['modifiedBy'] is Map<String, dynamic>
          ? User.fromJson(json['modifiedBy'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Description {
  final int id;
  final String name;

  Description({
    required this.id,
    required this.name,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Unit {
  final int id;
  final String name;

  Unit({
    required this.id,
    required this.name,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
    );
  }
}

class User {
  final int id;
  final String userName;

  User({
    required this.id,
    required this.userName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
    );
  }
}
