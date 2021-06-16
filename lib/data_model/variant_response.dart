// To parse this JSON data, do
//
//     final variantResponse = variantResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

VariantResponse variantResponseFromJson(String str) => VariantResponse.fromJson(json.decode(str));

String variantResponseToJson(VariantResponse data) => json.encode(data.toJson());

class VariantResponse {
  VariantResponse({
    this.product_id,
    this.variant,
    this.price,
    this.price_string,
    this.stock,
  });

  int product_id;
  String variant;
  int price;
  String price_string;
  int stock;

  factory VariantResponse.fromJson(Map<String, dynamic> json) => VariantResponse(
    product_id: json["product_id"],
    variant: json["variant"],
    price: json["price"],
    price_string: json["price_string"],
    stock: json["stock"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": product_id,
    "variant": variant,
    "price": price,
    "price_string": price_string,
    "stock": stock,
  };
}