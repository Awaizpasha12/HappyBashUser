class GetWishlistModel {
  int? id;
  int? userId;
  int? productId;
  // Null? createdAt;
  // Null? updatedAt;
  Product? product;

  GetWishlistModel(
      {this.id,
      this.userId,
      this.productId,
      // this.createdAt,
      // this.updatedAt,
      this.product});

  GetWishlistModel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    // createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['product_id'] = productId;
    // data['created_at'] = createdAt;
    // data['updated_at'] = updatedAt;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? pricePerDay;
  List<Images>? images;

  Product({this.id, this.name, this.pricePerDay, this.images});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pricePerDay = json['price_per_day'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price_per_day'] = pricePerDay;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int? productId;
  String? imageUrl;

  Images({this.productId, this.imageUrl});

  Images.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['image_url'] = imageUrl;
    return data;
  }
}
