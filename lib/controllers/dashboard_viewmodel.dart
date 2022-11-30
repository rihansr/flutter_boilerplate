import 'dart:io';

import 'package:boilerplate/services/api.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/debug.dart';
import '../utils/extensions.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel() : super();
  init() {}

  httpCall() async {
    api
        .invoke(
          via: InvokeType.http,
          method: Method.get,
          endpoint: 'https://httpbin.org',
          id: 'get',
        )
        .then((response) => debug.print(response.data));
  }

  dioCall() async {
    api
        .invoke(
          via: InvokeType.dio,
          method: Method.post,
          baseUrl: 'https://httpbin.org',
          endpoint: 'post',
          body: {'name': 'John Doe', 'email': 'johndoe@example.com'},
          showMessage: false,
          timeout: const Duration(seconds: 10),
          enableCaching: true,
          cacheDuration: const Duration(days: 1),
        )
        .then((response) => debug.print(response.data));
  }

  multipartCall() async {
    await extension.pickPhoto(ImageSource.gallery).then((file) async {
      if (file.existsSync()) {
        api.invoke(
          via: InvokeType.multipart,
          baseUrl: 'https://v2.convertapi.com',
          endpoint: 'upload',
          body: {
            'filename': await MultipartFile.fromPath('filename', file.path),
          },
        ).then((response) =>
            {debug.print(response.data), url = response.data['Url']});
      }
    });
  }

  String? url;

  downloadFile() async {
    url = 'http://download.dcloud.net.cn/HBuilder.9.0.2.macosx_64.dmg';
    String downloadFolder = (await getApplicationDocumentsDirectory()).path;
    File saveFile = File("$downloadFolder/fileName");
    api
        .download(url!, saveFile.path, (p0) => debug.print(p0))
        .then((response) => debug.print(response.data));
  }
}
