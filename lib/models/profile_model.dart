class ProfileModel {
  int? id;
  String? name;
  String? email;
  int? locationId;
  String? role;
  String? phone;
  String? avatar;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  ProfileModel(
      {this.id,
      this.name,
      this.email,
      this.locationId,
      this.role,
      this.phone,
      this.avatar,
      this.emailVerifiedAt,
      this.createdAt,
      this.updatedAt});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    locationId = json['location_id'];
    role = json['role'];
    phone = json['phone'];
    avatar = json['avatar'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['location_id'] = locationId;
    data['role'] = role;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
