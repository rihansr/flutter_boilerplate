import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/server_env.dart';
import '../../utils/debug.dart';

class StripePayment extends StatefulWidget {
  final String url;

  const StripePayment({Key? key, required this.url}) : super(key: key);

  @override
  _StripePaymentState createState() => _StripePaymentState();
}

class _StripePaymentState extends State<StripePayment> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debug.print('Progress: $progress', boundedText: 'onProgress');
          },
          onPageStarted: (String url) {
            debug.print(url.toString(), boundedText: 'onPageStarted');
          },
          onPageFinished: (String url) {
            debug.print(url.toString(), boundedText: 'onPageFinished');
          },
          onWebResourceError: (WebResourceError error) {
            debug.print(error.toString(), boundedText: 'onWebResourceError');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(ServerEnv.paymentSuccessUrl)) {
              debug.print('${request.url} : Success',
                  boundedText: 'Checkout success', bounded: true);
              Navigator.pop(context, true);
            } else if (request.url.startsWith(ServerEnv.paymentCancelUrl)) {
              debug.print("UR: ${request.url}",
                  boundedText: "Checkout Failed!!");
              Navigator.pop(context, false);
            } else {
              debug.print(request.url,
                  boundedText: 'STRIPE Checkout Url', bounded: true);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}
