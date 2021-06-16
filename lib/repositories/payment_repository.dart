import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:active_ecommerce_flutter/data_model/payment_type_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_create_response.dart';
import 'package:active_ecommerce_flutter/data_model/paypal_url_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/data_model/razorpay_payment_success_response.dart';

class PaymentRepository {
  Future<List<PaymentTypeResponse>> getPaymentResponseList({mode = ""}) async {
    final response = await http.get(
      "${AppConfig.BASE_URL}/payment-types?mode=${mode}",
    );

    return paymentTypeResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponse(
      @required int owner_id, @required payment_method) async {
    var post_body = jsonEncode({
      "owner_id": "${owner_id}",
      "user_id": "${user_id.value}",
      "payment_type": "${payment_method}"
    });

    final response = await http.post("${AppConfig.BASE_URL}/order/store",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.value}"
        },
        body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

  Future<PaypalUrlResponse> getPaypalUrlResponse(@required String payment_type,
      @required int order_id, @required double amount) async {
    final response = await http.get(
      "${AppConfig.BASE_URL}/paypal/payment/url?payment_type=${payment_type}&order_id=${order_id}&amount=${amount}&user_id=${user_id.value}",
    );

    print(response.body.toString());
    return paypalUrlResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponseFromWallet(
      @required int owner_id,
      @required payment_method,
      @required double amount) async {
    var post_body = jsonEncode({
      "owner_id": "${owner_id}",
      "user_id": "${user_id.value}",
      "payment_type": "${payment_method}",
      "amount": "${amount}"
    });

    final response =
        await http.post("${AppConfig.BASE_URL}/payments/pay/wallet",
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${access_token.value}"
            },
            body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

  Future<OrderCreateResponse> getOrderCreateResponseFromCod(
      @required int owner_id, @required payment_method) async {
    var post_body = jsonEncode({
      "owner_id": "${owner_id}",
      "user_id": "${user_id.value}",
      "payment_type": "${payment_method}"
    });

    final response = await http.post("${AppConfig.BASE_URL}/payments/pay/cod",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.value}"
        },
        body: post_body);

    //print(response.body.toString());
    return orderCreateResponseFromJson(response.body);
  }

  Future<RazorpayPaymentSuccessResponse> getRazorpayPaymentSuccessResponseResponse(
       @required payment_type,@required double amount,@required int order_id,@required String payment_details) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.value}",
      "payment_type": "${payment_type}",
      "order_id": "${order_id}",
      "amount": "${amount}",
      "payment_details": "${payment_details}"
    });

    final response = await http.post("${AppConfig.BASE_URL}/razorpay/success",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.value}"
        },
        body: post_body);

    //print(response.body.toString());
    return razorpayPaymentSuccessResponseFromJson(response.body);
  }
}
