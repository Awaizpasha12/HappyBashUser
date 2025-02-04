class GetBookingsModel {
  int? id;
  int? uniqueId;
  String? startDatetime;
  String? endDatetime;
  String? totalBookingAmount;
  List<Products>? products;
  String? status;
  String? paymentStatus;
  String? checkoutType;
  String? shippingCharges;

  // List<Null>? services;
  // List<Null>? addons;

  GetBookingsModel({
    this.id,
    this.uniqueId,
    this.startDatetime,
    this.endDatetime,
    this.totalBookingAmount,
    this.products,
    this.status,
    this.paymentStatus,
    this.checkoutType,
    this.shippingCharges,
    // this.services,
    // this.addons,
  });

  GetBookingsModel.fromJson(dynamic json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    startDatetime = json['start_datetime'];
    endDatetime = json['end_datetime'];
    totalBookingAmount = json['price'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    status = json['status'];
    paymentStatus = json['payment_status'];
    checkoutType = json['checkout_type'] ?? "";
    shippingCharges = json["shipping_price"] ?? "";
    // if (json['services'] != null) {
    //   services = <Null>[];
    //   json['services'].forEach((v) {
    //     services!.add(new Null.fromJson(v));
    //   });
    // }
    // if (json['addons'] != null) {
    //   addons = <Null>[];
    //   json['addons'].forEach((v) {
    //     addons!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unique_id'] = uniqueId;
    data['start_datetime'] = startDatetime;
    data['end_datetime'] = endDatetime;
    data['price'] = totalBookingAmount;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['status'] = status ?? "";
    data['payment_status'] = paymentStatus ?? "";
    data['checkout_type'] = checkoutType ?? "";
    data["shipping_price"] = shippingCharges ?? "";
    // if (services != null) {
    //   data['services'] = services!.map((v) => v.toJson()).toList();
    // }
    // if (addons != null) {
    //   data['addons'] = addons!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Products {
  int? id;
  String? name;
  String? pricePerDay;
  String? image;
  Pivot? pivot;
  String? priceType;
  List<Addon>? addons;
  String? productType;
  Products({this.id, this.name, this.pricePerDay, this.image, this.pivot,this.priceType,this.addons,this.productType});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pricePerDay = json['price_per_day'];
    image = json['image'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
    priceType = json['price_type'] ?? "price_per_day";
    if (json['addons'] != null) {
      addons = <Addon>[];
      json['addons'].forEach((v) {
        addons!.add(Addon.fromJson(v));
      });
    }
    productType = json["product_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price_per_day'] = pricePerDay;
    data['image'] = image;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    data['price_type'] = priceType;
    if (addons != null) {
      data['addon'] = addons!.map((v) => v.toJson()).toList();
    }
    data["product_type"] = productType;
    return data;
  }
}

class Pivot {
  int? bookingId;
  int? productId;
  int? quantity;
  String? color;
  String? size;
  String? price;
  Pivot({this.bookingId, this.productId, this.quantity,this.color,this.size,this.price});

  Pivot.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    color = json["color"];
    size = json["size"];
    price = json["price"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data["price"]= price;
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

