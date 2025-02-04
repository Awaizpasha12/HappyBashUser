class SubCategoriesModel {
  int? id;
  int? categoryId;
  String? name;
  String? imageUrl;

  SubCategoriesModel({this.id, this.categoryId, this.name, this.imageUrl});

  SubCategoriesModel.fromJson(dynamic json) {
    id = json['id'];
    categoryId = json['category_id'];
    name = json['name'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['name'] = name;
    data['image_url'] = imageUrl;
    return data;
  }
}
