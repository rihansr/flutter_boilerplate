import 'package:boilerplate/services/api.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import '../utils/extensions.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel() : super();
  init() {}

  httpCall() async {
    api.invoke<http.Response>(
      endpoint:
          'https://gpwarehouse.wpengine.com/wp-content/plugins/sa-geekphone-erp/json',
      id: 'all_products.json',
      method: Method.get,
      invokeType: InvokeType.http,
      justifyResponse: false,
    );
  }

  dioCall() async {
    api.invoke<dio.Response>(
      endpoint:
          'https://gpwarehouse.wpengine.com/wp-content/plugins/sa-geekphone-erp/json',
      id: 'all_products.json',
      method: Method.get,
      invokeType: InvokeType.dio,
      justifyResponse: false,
    );
  }

  multipartCall() async {
    await extension.pickPhoto(ImageSource.gallery).then((file) async {
      if (file.existsSync()) {
        var request = http.MultipartRequest(
            'GET', Uri.parse('https://v2.convertapi.com/upload'));

        request.files
            .add(await http.MultipartFile.fromPath('filename', file.path));

        api.invoke<http.Response>(
          body: request,
          headers: {},
        );
      }
    });
  }
}
