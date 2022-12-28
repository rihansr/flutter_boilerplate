import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../shared/shared_prefs.dart';
import '../configs/app_config.dart';
import '../services/api.dart';
import '../services/server_env.dart';
import '../shared/icons.dart';
import '../shared/strings.dart';
import '../utils/debug.dart';
import '../utils/extensions.dart';
import '../views/stripe_payment.dart';
import '../widgets/dialog_widget.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this.context) : super();

  final BuildContext context;

  init() {
    _selectedTab = centerTab;
  }

  List get navigations => [
        {
          'icon': AppIcons.profile_outlined,
          'label': string(context).profile,
        },
        {
          'icon': AppIcons.home_rounded,
          'label': string(context).home,
        },
        {
          'icon': AppIcons.filter_outlined,
          'label': string(context).settings,
        },
      ];

  get navigation => navigations[_selectedTab];

  int get centerTab => (navigations.length / 2).floor();
  bool get isCenterTab => _selectedTab == centerTab;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int i) => {
        if (_selectedTab != i) {_selectedTab = i, notifyListeners()}
      };

  httpCall() async {
    setBusy(true, key: 'Http');
    await api
        .invoke(
          via: InvokeType.http,
          method: Method.get,
          endpoint: 'https://httpbin.org',
          id: 'get',
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Http');
  }

  dioCall() async {
    setBusy(true, key: 'Dio');
    await api
        .invoke(
          via: InvokeType.dio,
          method: Method.post,
          baseUrl: 'https://httpbin.org',
          endpoint: 'post',
          queryParams: {'id': 56, 's': 'john'},
          body: {'name': 'John Doe', 'email': 'johndoe@example.com'},
          showMessage: true,
          contentTypeSupported: false,
          cacheDuration: const Duration(seconds: 30),
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Dio');
  }

  uploadFile() async {
    await extension.pickPhoto(ImageSource.gallery).then((file) async {
      if (file.existsSync()) {
        api
            .invoke(
              via: InvokeType.multipart,
              method: Method.post,
              baseUrl: 'https://v2.convertapi.com',
              endpoint: 'upload',
              body: {
                'filename': await MultipartFile.fromFile(
                  file.path,
                  filename: 'filename.jpg',
                ),
              },
              onProgress: (p0) => setUloadProgress = p0,
            )
            .then((response) => {
                  debug.print(response.data),
                  setUloadProgress = null,
                  setUrl = response.data?['Url'],
                });
      }
    });
  }

  String? url;
  set setUrl(String? url) => {this.url = url, notifyListeners()};

  int? uploadProgress;
  set setUloadProgress(int? percentage) =>
      {uploadProgress = percentage, notifyListeners()};

  int? downloadProgress;
  set setDownloadProgress(int? percentage) =>
      {downloadProgress = percentage, notifyListeners()};

  downloadFile() async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var path = '${documentDirectory.path}/pic.jpg';

    await api
        .invoke(
          via: InvokeType.download,
          method: Method.get,
          endpoint: url,
          path: path,
          onProgress: (p0) => setDownloadProgress = p0,
        )
        .then((response) => {
              setDownloadProgress = null,
            });
  }

  makePaymet() async {
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
    setBusy(true, key: 'Payment');

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
      endpoint: ServerEnv.stripeCreateSession,
      justifyResponse: true,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'Bearer ${appConfig.configs['stripe']['credentials']['secret_key']}',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
      body: body,
    );

    setBusy(false, key: 'Payment');

    if (response.data != null && response.data.containsKey("url")) {
      return {
        'url': response.data['url'],
        'pi': response.data["payment_intent"]
      };
    }
    return null;
  }
}
