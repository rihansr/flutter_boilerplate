import '../configs/app_config.dart';

class ServerEnv {
  static String baseUrl = '${appConfig.configs['base']['url']}';

  //Stripe-Payment
  static String stripeBaseUrl = appConfig.configs['payment']['stripe']['base_url'];
  static const String stripePaymentMethod = 'payment_methods';
  static const String stripeMakeCustomer = 'customers';
  static const String stripeCreateSession = 'checkout/sessions';
  static String stripePaymentLogo = appConfig.configs['payment']['stripe']['payment_logo'];

  //PayPal-Paymen
  static String basePaypalUrl = appConfig.configs['payment']['paypal']['base_url'];
  static const String paypalGetAccessToken =
      "v1/oauth2/token?grant_type=client_credentials";
  static const String paypalCreateOrder = "v2/checkout/orders/";


  static String paymentSuccessUrl = "$baseUrl/success";
  static String paymentCancelUrl = "$baseUrl/cancel";
}
