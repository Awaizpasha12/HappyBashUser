class BookSummaryModel {
   int? uniqueId;
   String? shippingPrice;
   int? userId;
   int? addressId;
   String? status;
   String? paymentStatus;
   String? createdAt;
   User? user;
   Address? address;
   String? bookingDateTime;
   String? totalAmount;
  BookSummaryModel({
    this.uniqueId,
    this.shippingPrice,
    this.userId,
    this.addressId,
    this.status,
    this.paymentStatus,
    this.createdAt,
    this.user,
    this.address,
    this.bookingDateTime,
    this.totalAmount
  });

  BookSummaryModel.fromJson(dynamic json) {
    uniqueId = json['unique_id'] ;
    shippingPrice = json['shipping_price'] as String?;
    userId = json['user_id'] as int?;
    addressId = json['address_id'] as int?;
    status = json['status'] as String?;
    paymentStatus = json['payment_status'] as String?;
    createdAt = json['created_at'] as String?;
    user = json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null;
    address = json['address'] != null ? Address.fromJson(json['address'] as Map<String, dynamic>) : null;
    bookingDateTime = json['booking_datetime'] as String?;
    totalAmount = json["total_amount"] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'unique_id': uniqueId,
      'shipping_price': shippingPrice,
      'user_id': userId,
      'address_id': addressId,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'user': user?.toJson(),
      'address': address?.toJson(),
      'bookingDateTime':bookingDateTime,
      'total_amount':totalAmount
    };
  }
}

class User {
   int? id;
   String? name;
   String? email;
   String? phone;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class Address {
   int? id;
   String? street;
   String? city;
   String? state;
   String? postalCode;

  Address({
    this.id,
    this.street,
    this.city,
    this.state,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
    };
  }
}
