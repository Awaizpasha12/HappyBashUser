class AddToCartModel {
  String? message;
  CartItem? cartItem;

  AddToCartModel({this.message, this.cartItem});

  AddToCartModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    cartItem =
        json['cartItem'] != null ? CartItem.fromJson(json['cartItem']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (cartItem != null) {
      data['cartItem'] = cartItem!.toJson();
    }
    return data;
  }
}

class CartItem {
  int? productId;
  int? quantity;
  int? cartId;
  String? updatedAt;
  String? createdAt;
  int? id;

  CartItem(
      {this.productId,
      this.quantity,
      this.cartId,
      this.updatedAt,
      this.createdAt,
      this.id});

  CartItem.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    quantity = json['quantity'];
    cartId = json['cart_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['cart_id'] = cartId;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    return data;
  }
}
