import 'package:boilerplate/services/api.dart';
import 'package:dio/dio.dart';
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
          via: InvokeType.multipart,
          method: Method.post,
          baseUrl: 'https://httpbin.org',
          endpoint: 'post',
          queryParams: {'id': 56, 's': 'john'},
          body: {'name': 'John Doe', 'email': 'johndoe@example.com'},
          showMessage: true,
          contentTypeSupported: false,
          cacheDuration: const Duration(seconds: 1),
        )
        .then((response) => debug.print(response.data));
  }

  uploadFile() async {
    await extension.pickPhoto(ImageSource.gallery).then((file) async {
      if (file.existsSync()) {
        api.invoke(
          via: InvokeType.multipart,
          method: Method.post,
          baseUrl: 'https://v2.convertapi.com',
          endpoint: 'upload',
          contentTypeSupported: false,
          body: {
            'filename': await MultipartFile.fromFile(
              file.path,
              filename: 'filename.jpg',
            ),
          },
          //onProgress: (p0) => setUploadProgress = p0,
        ).then((response) => {
              debug.print(response.data),
              setUrl = response.data['Url'],
            });
      }
    });
  }

  String? url;
  set setUrl(String? url) => {this.url = url, notifyListeners()};

  int? uploadProgress;
  set setUploadProgress(int percentage) =>
      {setUploadProgress = percentage, notifyListeners()};

  int? downloadProgress;
  set setDownloadProgress(int percentage) =>
      {downloadProgress = percentage, notifyListeners()};

  downloadFile() async {
    api
        .invoke(
          via: InvokeType.download,
          method: Method.get,
          endpoint: url,
          path:
              '${(await getApplicationDocumentsDirectory()).path}/fileName.jpg',
          onProgress: (p0) => setDownloadProgress = p0,
        )
        .then((response) => {
              //debug.print(response.data),
              extension
                  .saveFileToDownloads(response.data)
                  .then((value) => debug.print(value)),
            });
  }
}
