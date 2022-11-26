import '../configs/app_config.dart';

class ServerEnv {
  static String baseUrl = '${appConfig.configs['base']['url']}/wp-json';

  // static const String example = "$baseUrl/example";
}
