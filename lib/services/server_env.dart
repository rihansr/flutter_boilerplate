import '../configs/app_config.dart';

class ServerEnv {
  static String baseUrl = '${appConfig.configs['base']['url']}';

  //Stripe getway endpoints
  static String stripeBaseUrl = appConfig.configs['stripe']['base_url'];
  static const String stripePaymentMethod = 'payment_methods';
  static const String stripeMakeCustomer = 'customers';
  static const String stripeCreateSession = 'checkout/sessions';
  static String stripePaymentLogo = appConfig.configs['stripe']['payment_logo'];

  static String paymentSuccessUrl = "$baseUrl/success";
  static String paymentCancelUrl = "$baseUrl/cancel";
}
