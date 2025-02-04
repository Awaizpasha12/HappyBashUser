class GetLocationModel {
  int? id;
  String? name;

  GetLocationModel({
    this.id,
    this.name,
  });

  GetLocationModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
