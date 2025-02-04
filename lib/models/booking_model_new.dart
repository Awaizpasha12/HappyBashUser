import 'get_bookings_model.dart';

class BookingModelNew {
   final Summary? summary;
   final List<GetBookingsModel> bookings;

  BookingModelNew({ this.summary, required this.bookings});

  factory BookingModelNew.fromJson(dynamic json) {
    return BookingModelNew(
      summary: Summary.fromJson(json['summary']),
      bookings: List<GetBookingsModel>.from(
          json['bookings'].map((x) => GetBookingsModel.fromJson(x))),
    );
  }
}

class Summary {
   int? uniqueId;
   String? shippingPrice;
   int? userId;
   int? addressId;
   String? status;
   String? paymentStatus;
   String? createdAt;
   User? user;
   Address? address;
   String? totalAmount;
  Summary({
     this.uniqueId,
     this.shippingPrice,
     this.userId,
     this.addressId,
     this.status,
     this.paymentStatus,
     this.createdAt,
     this.user,
     this.address,
    this.totalAmount
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      uniqueId: json['unique_id'],
      shippingPrice: json['shipping_price'],
      userId: json['user_id'],
      addressId: json['address_id'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      user: User.fromJson(json['user']),
      address: Address.fromJson(json['address']),
      totalAmount: json['total_amount'],
    );
  }
}

// class GetBookingsModel {
//    int id;
//    int uniqueId;
//    String createdAt;
//    String updatedAt;
//    String price;
//    String shippingPrice;
//    String startDatetime;
//    String endDatetime;
//    int userId;
//    int vendorId;
//    String status;
//    int addressId;
//    String checkoutType;
//    String paymentResponse;
//    String paymentStatus;
//    List<Product> products;
//
//   GetBookingsModel({
//      this.id,
//      this.uniqueId,
//      this.createdAt,
//      this.updatedAt,
//      this.price,
//      this.shippingPrice,
//      this.startDatetime,
//      this.endDatetime,
//      this.userId,
//      this.vendorId,
//      this.status,
//      this.addressId,
//      this.checkoutType,
//      this.paymentResponse,
//      this.paymentStatus,
//      this.products,
//   });
//
//   factory GetBookingsModel.fromJson(Map<String, dynamic> json) {
//     return GetBookingsModel(
//       id: json['id'],
//       uniqueId: json['unique_id'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       price: json['price'],
//       shippingPrice: json['shipping_price'],
//       startDatetime: json['start_datetime'],
//       endDatetime: json['end_datetime'],
//       userId: json['user_id'],
//       vendorId: json['vendor_id'],
//       status: json['status'],
//       addressId: json['address_id'],
//       checkoutType: json['checkout_type'],
//       paymentResponse: json['payment_response'],
//       paymentStatus: json['payment_status'],
//       products: List<Product>.from(
//           json['products'].map((x) => Product.fromJson(x))
//       ),
//     );
//   }
// }

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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
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
      id: json['id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
    );
  }
}

