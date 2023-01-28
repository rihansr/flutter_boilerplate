import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCShipmentInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/General.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'base_viewmodel.dart';
import '../utils/debug.dart';
import '../shared/strings.dart';
import '../shared/shared_prefs.dart';
import '../configs/app_config.dart';
import '../services/api.dart';
import '../services/server_env.dart';
import '../views/stripe_payment.dart';
import '../widgets/dialog_widget.dart';

class PaymentViewModel extends BaseViewModel {
  PaymentViewModel(this.context) : super();

  final BuildContext context;

  // STRIPE-PAYMENT
  stripePaymet() async {
    Map<String, String>? sessionData = await _createStripeSession();
    if (sessionData != null) {
      showFullScreenDialog(
        child: StripePayment(url: sessionData['url']!),
        onDispose: (isSuccessful) => {},
      );
    } else {
      showMessage(string().someErrorOccured);
    }
  }

  Future<Map<String, String>?> _createStripeSession() async {
    setBusy(true, key: 'stripe_payment');

    double price = 100;
    double shipping = 0;
    Map<String, dynamic> body = {
      "mode": 'payment',
      "payment_method_types[0]": "card",
      "customer_email": 'johndoe@example.com',
      "success_url": ServerEnv.paymentSuccessUrl,
      "cancel_url": ServerEnv.paymentCancelUrl,

      // Shipping
      if (shipping != 0) ...{
        "phone_number_collection[enabled]": "true",
        "shipping_options[0][shipping_rate_data][type]": "fixed_amount",
        "shipping_options[0][shipping_rate_data][fixed_amount][amount]":
            (shipping * 100).floor().toString(),
        "shipping_options[0][shipping_rate_data][fixed_amount][currency]":
            'usd',
        "shipping_options[0][shipping_rate_data][display_name]": 'Charge',
        "shipping_address_collection[allowed_countries][0]":
            sharedPrefs.address?.countryCode ?? '',
        "custom_text[shipping_address][message]":
            "Please note that we can't guarantee 2-day delivery for PO boxes at this time."
      },

      // Additional
      /* "custom_text[submit][message]":
          "We'll email you instructions on how to get started.", */
    };

    for (int i = 0; i < 2; i++) {
      body.addAll(
        {
          "line_items[$i][price_data][product_data][images][0]":
              ServerEnv.stripePaymentLogo,
          "line_items[$i][price_data][product_data][name]": 'Cart items',
          "line_items[$i][quantity]": '1',
          "line_items[$i][price_data][currency]": 'usd',
          "line_items[$i][price_data][unit_amount]":
              (price * 100).floor().toString(),
        },
      );
    }

    var response = await api.invoke(
      via: InvokeType.http,
      method: Method.post,
      baseUrl: ServerEnv.stripeCreateSession,
      justifyResponse: true,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'Bearer ${appConfig.configs['stripe']['credentials']['secret_key']}',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
      body: body,
    );

    setBusy(false, key: 'stripe_payment');

    if (response.data != null && response.data.containsKey("url")) {
      return {
        'url': response.data['url'],
        'pi': response.data["payment_intent"]
      };
    }
    return null;
  }

  // SSL-PAYMENT
  sslPaymet() async {
    setBusy(true, key: 'ssl_payment');

    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        ipn_url: appConfig.configs['ssl']['credentials']['ipn_url'],
        multi_card_name: 'mastercard',
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: SSLCSdkType.TESTBOX,
        store_id: appConfig.configs['ssl']['credentials']['store_id'],
        store_passwd: appConfig.configs['ssl']['credentials']['store_password'],
        total_amount: 100,
        tran_id: "1231123131212",
      ),
    );

    sslcommerz
        .addShipmentInfoInitializer(
            sslcShipmentInfoInitializer: SSLCShipmentInfoInitializer(
                shipmentMethod: "yes",
                numOfItems: 5,
                shipmentDetails: ShipmentDetails(
                    shipAddress1: "Shahjalal Uposhahar",
                    shipCity: "Sylhet",
                    shipCountry: "Bangladesh",
                    shipName: "Foods Shipment",
                    shipPostCode: "3100")))
        .addCustomerInfoInitializer(
          customerInfoInitializer: SSLCCustomerInfoInitializer(
            customerState: "Sylhet",
            customerName: "John Doe",
            customerEmail: "example@gmail.com",
            customerAddress1: "Shahjalal Uposhahar",
            customerCity: "Sylhet",
            customerPostCode: "3100",
            customerCountry: "Bangladesh",
            customerPhone: '+8801811342435',
          ),
        )
        .addProductInitializer(
            sslcProductInitializer: SSLCProductInitializer(
          productName: "Set Meal",
          productCategory: "Foods",
          general: General(
            general: "General Purpose",
            productProfile: "Product Profile",
          ),
        ));

    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      setBusy(false, key: 'ssl_payment');

      debug.print(result.toJson(), boundedText: 'Payment Result');

      switch (result.status?.toLowerCase()) {
        case "failed":
          showMessage('Transaction is Failed....');
          break;
        case "closed":
          showMessage('User cancelled the transaction....');
          break;
        default:
          showMessage(
              'Transaction is ${result.status} and Amount is ${result.amount}');
      }
    } catch (e) {
      debug.print(e.toString(), boundedText: 'Payment Exception');
      showMessage(string().someErrorOccured);
      setBusy(false, key: 'ssl_payment');
    }
  }
}