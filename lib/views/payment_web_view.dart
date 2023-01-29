import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/extensions.dart';
import '../services/server_env.dart';
import '../utils/debug.dart';
import '../shared/enums.dart';

class PaymentWebView extends StatefulWidget {
  final PaymentMethod method;
  final Map<String, dynamic> args;

  const PaymentWebView(this.method, {Key? key, required this.args})
      : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
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
              debug.print(
                '${widget.method.name}_Payment Successful!!',
                boundedText: request.url,
              );
              Navigator.pop(context, 'success');
            } else if (request.url.startsWith(ServerEnv.paymentCancelUrl)) {
              debug.print(
                '${widget.method.name}_Payment Cancelled!!',
                boundedText: request.url,
              );
              Navigator.pop(context, 'closed');
            } else {
              debug.print(
                '${widget.method.name}_Payment Processing...',
                boundedText: request.url,
              );
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.args['payment_url']));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: widget.method != PaymentMethod.stripe
            ? AppBar(
                leading: IconButton(
                  onPressed: () => Navigator.pop(context, 'closed'),
                  icon: Icon(
                    Icons.arrow_back,
                    color: context.iconTheme.color,
                  ),
                ),
              )
            : null,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}
