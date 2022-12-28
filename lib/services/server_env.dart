import '../configs/app_config.dart';

class ServerEnv {
  static String baseUrl = '${appConfig.configs['base']['url']}/wp-json';

  //Stripe getway endpoints
  static String stripeBaseUrl = appConfig.configs['stripe']['base_url'];
  static String stripePaymentMethod = "$stripeBaseUrl/payment_methods";
  static String stripeMakeCustomer = "$stripeBaseUrl/customers";
  static String stripeCreateSession = "$stripeBaseUrl/checkout/sessions";
  static String stripePaymentLogo = appConfig.configs['stripe']['payment_logo'];

  static String paymentSuccessUrl = "$baseUrl/success";
  static String paymentCancelUrl = "$baseUrl/cancel";
}
