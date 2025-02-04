class ProductModel {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? checkOutType;
  int? availableQuantity;
  String? pricePerDay;
  int? subcategoryId;
  String? rating;
  int? timesBooked;
  List<String>? includedItems;
  List<String>? notIncludedItems;
  List<String>? additionalInformation;
  List<String>? termsConditions;
  Subcategory? subcategory;
  List<Images>? images;
  int? timesRated;
  String? originalPrice;
  String? priceType;
  String productType = "";
  ProductModel(
      {this.id,
      this.name,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.checkOutType,
      this.availableQuantity,
      this.pricePerDay,
      this.subcategoryId,
      this.rating,
      this.timesBooked,
      this.includedItems,
      this.notIncludedItems,
      this.additionalInformation,
      this.termsConditions,
      this.subcategory,
      this.images,
      this.timesRated,
      this.originalPrice,
        this.priceType,
        this.productType = ""
      });

  ProductModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    checkOutType = json['checkout_type'] ?? "";
    availableQuantity = json['available_quantity'];
    pricePerDay = json['price_per_day'];
    subcategoryId = json['subcategory_id'];
    rating = json['rating'] ?? "";
    timesBooked = json['times_booked'];
    includedItems = json['included_items'].cast<String>();
    notIncludedItems = json['not_included_items'].cast<String>();
    additionalInformation = json['additional_information'].cast<String>();
    termsConditions = json['terms_conditions'].cast<String>();
    subcategory = json['subcategory'] != null
        ? Subcategory.fromJson(json['subcategory'])
        : null;
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
      timesRated = json['how_many_times_rated'] ?? 0;
      originalPrice = json['original_price'] ?? "";
      priceType = json['price_type'] ?? "price_per_day";
      productType = json["product_type"] ?? "";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['checkout_type'] = checkOutType;
    data['available_quantity'] = availableQuantity;
    data['price_per_day'] = pricePerDay;
    data['subcategory_id'] = subcategoryId;
    data['rating'] = rating;
    data['times_booked'] = timesBooked;
    data['included_items'] = includedItems;
    data['not_included_items'] = notIncludedItems;
    data['additional_information'] = additionalInformation;
    data['terms_conditions'] = termsConditions;
    if (subcategory != null) {
      data['subcategory'] = subcategory!.toJson();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['how_many_times_rated'] = timesRated;
    data['original_price'] = originalPrice;
    data['price_type'] = priceType;
    data["product_type"] = productType;
    return data;
  }
}

class Subcategory {
  int? id;
  String? createdAt;
  String? updatedAt;
  int? categoryId;
  String? name;

  Subcategory(
      {this.id, this.createdAt, this.updatedAt, this.categoryId, this.name});

  Subcategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryId = json['category_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['category_id'] = categoryId;
    data['name'] = name;
    return data;
  }
}

class Images {
  int? id;
  int? productId;
  String? imageUrl;
  String? createdAt;
  String? updatedAt;

  Images(
      {this.id, this.productId, this.imageUrl, this.createdAt, this.updatedAt});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    imageUrl = json['image_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['image_url'] = imageUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
