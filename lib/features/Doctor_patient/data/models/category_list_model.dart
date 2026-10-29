class CategoryListModel {
  final int? id;
  final String? lookupValue;

  CategoryListModel({this.id, this.lookupValue});

  factory CategoryListModel.fromJson(Map<String, dynamic> json) {
    return CategoryListModel(
      id: json['id'],
      lookupValue: json['lookup_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'lookup_value': lookupValue};
  }
}
