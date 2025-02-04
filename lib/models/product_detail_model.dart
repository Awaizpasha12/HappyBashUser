class ProductDetailModel {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;
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
  int? vendorId;
  int? timesRated;
  String? originalPrice;
  String? shippingPrice;
  List<Addon>? addons;
  String? priceType;
  String? checkOutType;
  String? availableStartDate;
  String? availableEndDate;
  String? availableStartTime;
  String? availableEndTime;
  List<ColorsNew>? colors;
  List<Sizes>? sizes;
  String? productType;
  ProductDetailModel(
      {this.id,
      this.name,
      this.description,
      this.createdAt,
      this.updatedAt,
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
      this.vendorId,
        this.timesRated,
        this.originalPrice,
      this.shippingPrice,
      this.addons,
      this.priceType,
        this.checkOutType,
      this.availableStartDate,
      this.availableEndDate,
      this.availableStartTime,
      this.availableEndTime,
      this.colors,
      this.sizes,
      this.productType});

  ProductDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    availableQuantity = json['available_quantity'];
    pricePerDay = json['price_per_day'] ?? "";
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
    }
    vendorId = json['user_id'];
    timesRated = json['how_many_times_rated'] ?? 0;
    originalPrice = json['original_price'] ?? "";
    shippingPrice = json['shipping_price'] ?? "";
    if (json['addons'] != null) {
      addons = <Addon>[];
      json['addons'].forEach((v) {
        addons!.add(Addon.fromJson(v));
      });
    }
    priceType = json['price_type'] ?? "price_per_day";
    checkOutType = json['checkout_type'] ?? "";
    availableStartDate = json['available_start_date'];
    availableEndDate = json['available_end_date'];
    availableStartTime = json['available_start_time'];
    availableEndTime = json['available_end_time'];

    if (json['colors'] != null) {
      colors = <ColorsNew>[];
      json['colors'].forEach((v) {
        colors!.add(ColorsNew.fromJson(v));
      });
    }
    if (json['sizes'] != null) {
      sizes = <Sizes>[];
      json['sizes'].forEach((v) {
        sizes!.add(Sizes.fromJson(v));
      });
    }
    productType = json['product_type'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
    data['user_id'] = vendorId;
    data['how_many_times_rated'] = timesRated;
    data['original_price'] = originalPrice;
    data['shipping_price'] = shippingPrice;
    if (addons != null) {
      data['addon'] = addons!.map((v) => v.toJson()).toList();
    }
    data['price_type'] = priceType;
    data['checkout_type'] = checkOutType;
    data['available_start_date'] = availableStartDate;
    data['available_end_date'] = availableEndDate;
    data['available_start_time'] = availableStartTime;
    data['available_end_time'] = availableEndTime;
    if (colors != null) {
      data['colors'] = colors!.map((v) => v.toJson()).toList();
    }
    if (sizes != null) {
      data['sizes'] = sizes!.map((v) => v.toJson()).toList();
    }
    data['product_type'] = productType;
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
class Addon {
  final int? id;
  final int? productId;
  final String? name;
  final String? description;
  final String? price;

  Addon({
    this.id,
    this.productId,
    this.name,
    this.description,
    this.price,
  });

  // Constructor for creating an Addon instance from a map (e.g., JSON)
  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: json['price'] as String?,
    );
  }

  // Method to convert Addon instance into a map, useful for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}
class ColorsNew {
  int? id;
  String? name;
  String? colorCode;

  ColorsNew({this.id, this.name, this.colorCode});

  ColorsNew.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    colorCode = json['color_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color_code'] = colorCode;
    return data;
  }
  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is ColorsNew &&
        other.id == id &&
        other.name == name &&
        other.colorCode == colorCode;
  }

  @override
  int get hashCode => Object.hash(id, name, colorCode);
}


class Sizes {
  int? id;
  String? name;

  Sizes({this.id, this.name});

  Sizes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sizes &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}


