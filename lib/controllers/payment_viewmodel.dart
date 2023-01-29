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
import '../shared/enums.dart';
import '../utils/debug.dart';
import '../shared/strings.dart';
import '../shared/shared_prefs.dart';
import '../configs/app_config.dart';
import '../services/api.dart';
import '../services/server_env.dart';
import '../views/payment_web_view.dart';
import '../widgets/dialog_widget.dart';

class PaymentViewModel extends BaseViewModel {
  PaymentViewModel(this.context) : super();

  final BuildContext context;

  payVia(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.stripe:
        stripePaymet();
        break;
      case PaymentMethod.paypal:
        paypalPayment();
        break;
      case PaymentMethod.ssl:
        sslPayment();
        break;
      default:
        break;
    }
  }

  // STRIPE-PAYMENT
  stripePaymet() async {
    try {
      Map<String, dynamic>? sessionData = await _createStripeSession();
      showFullScreenDialog(
        child: PaymentWebView(PaymentMethod.stripe, args: sessionData!),
        onDispose: (status) {
          switch (status) {
            case "success":
              showMessage(string().paymentSuccessful);
              break;
            case "closed":
              break;
            default:
              showMessage(string().paymentFailed);
          }
        },
      );
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _createStripeSession() async {
    setBusy(true, key: 'stripe_payment');

    double price = 1;
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
      "custom_text[submit][message]":
          "We'll email you instructions on how to get started.",
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
      baseUrl: ServerEnv.stripeBaseUrl,
      endpoint: ServerEnv.stripeCreateSession,
      contentType: 'application/x-www-form-urlencoded',
      additionalHeaders: {
        HttpHeaders.authorizationHeader:
            'Bearer ${appConfig.configs['payment']['stripe']['credentials']['secret_key']}',
      },
      body: body,
      enableEncoding: false,
    );

    setBusy(false, key: 'stripe_payment');

    String? paymentUrl = response.data?['url'];
    String? paymentIntent = response.data?['payment_intent'];

    if (paymentUrl != null && paymentIntent != null) {
      return {'payment_url': paymentUrl, 'payment_intent': paymentIntent};
    }

    throw Exception(string().someErrorOccured);
  }

  // PAYPAL-PAYMENT
  paypalPayment() async {
    try {
      Map<String, dynamic>? paymentInfo;
      paymentInfo = await paypalGetAccessToken();
      paymentInfo = await createPaypalPayment(paymentInfo!);
      showFullScreenDialog(
        child: PaymentWebView(PaymentMethod.paypal, args: paymentInfo!),
        onDispose: (status) async {
          switch (status) {
            case "success":
              try {
                paymentInfo = await authorizePaypalPayment(paymentInfo!);
                await capturePaypalPayment(paymentInfo!);
                showMessage(string().paymentSuccessful);
              } catch (e) {
                showMessage(e.toString());
              }
              break;
            case "closed":
              break;
            default:
              showMessage(string().paymentFailed);
          }
        },
      );
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<Map<String, dynamic>?> paypalGetAccessToken() async {
    setBusy(true, key: 'paypal_payment');
    Response response = await api.invoke(
      via: InvokeType.http,
      method: Method.post,
      baseUrl: ServerEnv.basePaypalUrl,
      endpoint: ServerEnv.paypalGetAccessToken,
      additionalHeaders: {
        'authorization': api.basicAuthGenerator(
          username: appConfig.configs['payment']['paypal']['credentials']
              ['clint_id'],
          password: appConfig.configs['payment']['paypal']['credentials']
              ['secret_key'],
        ),
      },
      showMessage: false,
    );
    setBusy(false, key: 'paypal_payment');
    String? token = response.data?['access_token'];
    return token == null
        ? throw Exception(string().someErrorOccured)
        : {'access_token': token};
  }

  Future<Map<String, dynamic>?> createPaypalPayment(
      Map<String, dynamic> args) async {
    double price = 1;
    Map<String, dynamic> body = {
      "intent": "AUTHORIZE",
      "purchase_units": [
        {
          "reference_id": "1",
          "amount": {
            "currency_code": "USD",
            "value": price.toStringAsFixed(2),
          },
        },
      ],
       "application_context": {
        "return_url": ServerEnv.paymentSuccessUrl,
        "cancel_url": ServerEnv.paymentCancelUrl
      }
    };

    setBusy(true, key: 'paypal_payment');

    Response response = await api.invoke(
      via: InvokeType.http,
      method: Method.post,
      baseUrl: ServerEnv.basePaypalUrl,
      endpoint: ServerEnv.paypalCreateOrder,
      token: args['access_token'],
      contentTypeSupported: true,
      body: body,
      showMessage: false,
    );

    setBusy(false, key: 'paypal_payment');

    if (response.data != null) {
      if (response.data["links"] != null && response.data["links"].length > 0) {
        List links = response.data["links"];

        final item =
            links.firstWhere((o) => o["rel"] == "approve", orElse: () => null);
        if (item != null) args['payment_url'] = item["href"];

        final item1 = links.firstWhere((o) => o["rel"] == "authorize",
            orElse: () => null);
        if (item1 != null) args['authorize_url'] = item1["href"];

        return args['payment_url'] == null || args['authorize_url'] == null
            ? throw Exception(string().someErrorOccured)
            : args;
      }
    }
    throw Exception(string().someErrorOccured);
  }

  Future<Map<String, dynamic>?> authorizePaypalPayment(
      Map<String, dynamic> args) async {
    setBusy(true, key: 'paypal_payment');

    Response response = await api.invoke(
      via: InvokeType.http,
      method: Method.post,
      baseUrl: args['authorize_url'] ?? '',
      token: args['access_token'],
      contentTypeSupported: true,
      showMessage: false,
    );

    setBusy(false, key: 'paypal_payment');

    if (response.data != null) {
      List? tempLinks = response.data["purchase_units"]?[0]["payments"]
          ["authorizations"][0]["links"];
      if (tempLinks != null && tempLinks.isNotEmpty) {
        List links = tempLinks;

        final item =
            links.firstWhere((o) => o["rel"] == "capture", orElse: () => null);
        if (item != null) args['payment_url'] = item["href"];
        return args['payment_url'] == null
            ? throw Exception(string().someErrorOccured)
            : args;
      }
    }
    throw Exception(string().someErrorOccured);
  }

  Future<void> capturePaypalPayment(Map<String, dynamic> args) async {
    setBusy(true, key: 'paypal_payment');

    Response response = await api.invoke(
      via: InvokeType.http,
      method: Method.post,
      baseUrl: args['payment_url'] ?? '',
      token: args['access_token'],
      contentTypeSupported: true,
      showMessage: false,
    );

    setBusy(false, key: 'paypal_payment');

    if (response.statusCode != 201) throw Exception(string().someErrorOccured);
  }

  // SSL-PAYMENT
  sslPayment() async {
    setBusy(true, key: 'ssl_payment');

    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        ipn_url: appConfig.configs['payment']['ssl']['ipn_url'],
        multi_card_name: 'mastercard',
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: SSLCSdkType.TESTBOX,
        store_id: appConfig.configs['payment']['ssl']['credentials']
            ['store_id'],
        store_passwd: appConfig.configs['payment']['ssl']['credentials']
            ['store_password'],
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
              shipPostCode: "3100",
            ),
          ),
        )
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
          ),
        );

    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      debug.print(result.toJson(), boundedText: 'Payment Result');

      switch (result.status?.toLowerCase()) {
        case "failed":
          showMessage(string().paymentFailed);
          break;
        case "closed":
          break;
        default:
          debug.print(
            'Transaction is ${result.status} and Amount is ${result.amount}',
            boundedText: 'SSL-Payment Successful',
          );
          showMessage(string().paymentSuccessful);
      }
    } catch (e) {
      debug.print(e.toString(), boundedText: 'SSL-Payment Exception');
      showMessage(string().someErrorOccured);
    }

    setBusy(false, key: 'ssl_payment');
  }
}
