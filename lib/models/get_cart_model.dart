// class GetCartModel {
//   Cart? cart;
//
//   GetCartModel({this.cart});
//
//   GetCartModel.fromJson(Map<String, dynamic> json) {
//     cart = json['cart'] != null ? Cart.fromJson(json['cart']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (cart != null) {
//       data['cart'] = cart!.toJson();
//     }
//     return data;
//   }
// }
//
// class Cart {
//   int? id;
//   int? userId;
//   String? createdAt;
//   String? updatedAt;
//   List<CartItems>? cartItems;
//
//   Cart({this.id, this.userId, this.createdAt, this.updatedAt, this.cartItems});
//
//   Cart.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     if (json['cart_items'] != null) {
//       cartItems = <CartItems>[];
//       json['cart_items'].forEach((v) {
//         cartItems!.add(CartItems.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['user_id'] = userId;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     if (cartItems != null) {
//       data['cart_items'] = cartItems!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class CartItems {
//   int? id;
//   int? cartId;
//   int? productId;
//   int? quantity;
//   String? createdAt;
//   String? updatedAt;
//   Product? product;
//
//   CartItems({
//     this.id,
//     this.cartId,
//     this.productId,
//     this.quantity,
//     this.createdAt,
//     this.updatedAt,
//     this.product,
//   });
//
//   CartItems.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     cartId = json['cart_id'];
//     productId = json['product_id'];
//     quantity = json['quantity'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     product =
//         json['product'] != null ? Product.fromJson(json['product']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['cart_id'] = cartId;
//     data['product_id'] = productId;
//     data['quantity'] = quantity;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     if (product != null) {
//       data['product'] = product!.toJson();
//     }
//     return data;
//   }
// }
//
// class Product {
//   int? id;
//   String? name;
//   String? description;
//   String? createdAt;
//   String? updatedAt;
//   int? availableQuantity;
//   String? pricePerDay;
//   int? subcategoryId;
//   int? rating;
//   int? timesBooked;
//   List<String>? includedItems;
//   List<String>? notIncludedItems;
//   List<String>? additionalInformation;
//   List<String>? termsConditions;
//   List<Images>? images;
//
//   Product({
//     this.id,
//     this.name,
//     this.description,
//     this.createdAt,
//     this.updatedAt,
//     this.availableQuantity,
//     this.pricePerDay,
//     this.subcategoryId,
//     this.rating,
//     this.timesBooked,
//     this.includedItems,
//     this.notIncludedItems,
//     this.additionalInformation,
//     this.termsConditions,
//     this.images,
//   });
//
//   Product.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     description = json['description'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     availableQuantity = json['available_quantity'];
//     pricePerDay = json['price_per_day'];
//     subcategoryId = json['subcategory_id'];
//     rating = json['rating'];
//     timesBooked = json['times_booked'];
//     includedItems = json['included_items'].cast<String>();
//     notIncludedItems = json['not_included_items'].cast<String>();
//     additionalInformation = json['additional_information'].cast<String>();
//     termsConditions = json['terms_conditions'].cast<String>();
//     if (json['images'] != null) {
//       images = <Images>[];
//       json['images'].forEach((v) {
//         images!.add(Images.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['description'] = description;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['available_quantity'] = availableQuantity;
//     data['price_per_day'] = pricePerDay;
//     data['subcategory_id'] = subcategoryId;
//     data['rating'] = rating;
//     data['times_booked'] = timesBooked;
//     data['included_items'] = includedItems;
//     data['not_included_items'] = notIncludedItems;
//     data['additional_information'] = additionalInformation;
//     data['terms_conditions'] = termsConditions;
//     if (images != null) {
//       data['images'] = images!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Images {
//   int? id;
//   int? productId;
//   String? imageUrl;
//   String? createdAt;
//   String? updatedAt;
//
//   Images(
//       {this.id, this.productId, this.imageUrl, this.createdAt, this.updatedAt});
//
//   Images.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     productId = json['product_id'];
//     imageUrl = json['image_url'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['product_id'] = productId;
//     data['image_url'] = imageUrl;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     return data;
//   }
// }

class GetCartModel {
  Cart? cart;

  String? total = "0.000";
  String? toBePaidNow = "0.000";
  String? shippingCharges = "0.000";
  String? totalAmount = "0.000";
  GetCartModel({this.cart});

  GetCartModel.fromJson(Map<String, dynamic> json) {
    cart = json['cart'] != null ? Cart.fromJson(json['cart']) : null;
    total = json['total'];
    toBePaidNow = json['toBePaidNow'];
    shippingCharges = json['shippingCharges'];
    totalAmount = json['totalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cart != null) {
      data['cart'] = cart!.toJson();
    }
    data['total'] = total;
    data['toBePaidNow'] = toBePaidNow;
    data['shippingCharges'] = shippingCharges;
    data['totalAmount'] = totalAmount;
    return data;
  }
}

class Cart {
  int? id;
  int? userId;
  String? createdAt;
  String? updatedAt;
  List<CartItems>? cartItems;
  Cart({this.id, this.userId, this.createdAt, this.updatedAt, this.cartItems});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['cart_items'] != null) {
      cartItems = <CartItems>[];
      json['cart_items'].forEach((v) {
        cartItems!.add(CartItems.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (cartItems != null) {
      data['cart_items'] = cartItems!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class CartItems {
  int? id;
  int? cartId;
  int? productId;
  int? quantity;
  String? createdAt;
  String? updatedAt;
  String? startDate;
  String? endDate;
  Product? product;
  String? shippingPrice;
  String? total;
  List<Addon>? addons;
  CartItems(
      {this.id,
      this.cartId,
      this.productId,
      this.quantity,
      this.createdAt,
      this.updatedAt,
      this.startDate,
      this.endDate,
      this.product,
      this.shippingPrice,
      this.total,
      this.addons});

  CartItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cartId = json['cart_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    shippingPrice = json['shipping_price'];
    total = json['total'];
    if (json['addons'] != null) {
      addons = <Addon>[];
      json['addons'].forEach((v) {
        addons!.add(Addon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cart_id'] = cartId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['shipping_price'] = shippingPrice;
    data['total'] = total;
    if (addons != null) {
      data['addon'] = addons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? availableQuantity;
  String? pricePerDay;
  int? subcategoryId;
  // void rating;
  int? timesBooked;
  List<String>? includedItems;
  List<String>? notIncludedItems;
  List<String>? additionalInformation;
  List<String>? termsConditions;
  List<Images>? images;
  String? priceType;
  String? checkOutType;

  Product(
      {this.id,
      this.name,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.availableQuantity,
      this.pricePerDay,
      this.subcategoryId,
      // this.rating,
      this.timesBooked,
      this.includedItems,
      this.notIncludedItems,
      this.additionalInformation,
      this.termsConditions,
      this.images,
      this.priceType,
      this.checkOutType});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    availableQuantity = json['available_quantity'];
    pricePerDay = json['price_per_day'];
    subcategoryId = json['subcategory_id'];
    // rating = json['rating'];
    timesBooked = json['times_booked'];
    includedItems = json['included_items'].cast<String>();
    notIncludedItems = json['not_included_items'].cast<String>();
    additionalInformation = json['additional_information'].cast<String>();
    termsConditions = json['terms_conditions'].cast<String>();
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    priceType = json['price_type'] ?? "price_per_day";
    checkOutType = json['checkout_type'] ?? "";
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
    // data['rating'] = rating;
    data['times_booked'] = timesBooked;
    data['included_items'] = includedItems;
    data['not_included_items'] = notIncludedItems;
    data['additional_information'] = additionalInformation;
    data['terms_conditions'] = termsConditions;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['price_type'] = priceType;
    data['checkout_type'] = checkOutType;
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

