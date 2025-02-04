class AddAddressModel {
  String? street;
  String? city;
  String? state;
  String? postalCode;
  int? userId;
  String? updatedAt;
  String? createdAt;
  int? id;

  AddAddressModel(
      {this.street,
      this.city,
      this.state,
      this.postalCode,
      this.userId,
      this.updatedAt,
      this.createdAt,
      this.id});

  AddAddressModel.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    userId = json['user_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['postal_code'] = postalCode;
    data['user_id'] = userId;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
