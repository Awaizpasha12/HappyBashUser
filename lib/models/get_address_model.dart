class GetAddressModel {
  int? id;
  int? userId;
  String? street;
  String? city;
  String? state;
  String? postalCode;
  String? createdAt;
  String? updatedAt;

  GetAddressModel(
      {this.id,
      this.userId,
      this.street,
      this.city,
      this.state,
      this.postalCode,
      this.createdAt,
      this.updatedAt});

  GetAddressModel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    street = json['street'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['postal_code'] = postalCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
