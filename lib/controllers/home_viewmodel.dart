import 'dart:isolate';
import 'package:boilerplate/services/server_env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api.dart';
import '../utils/debug.dart';
import '../utils/extensions.dart';
import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel(this.context) : super();

  final BuildContext context;

  httpCall() async {
    setBusy(true, key: 'Http');

    await api
        .invoke(
          via: InvokeType.http,
          baseUrl: ServerEnv.baseUrl,
          endpoint: 'get',
          method: Method.get,
          showMessage: false,
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Http');
  }

  dioCall() async {
    setBusy(true, key: 'Dio');
    await api
        .invoke(
          via: InvokeType.dio,
          baseUrl: ServerEnv.baseUrl,
          endpoint: 'post',
          method: Method.post,
          queryParams: {'id': 56, 's': 'john'},
          body: {'name': 'John Doe', 'email': 'johndoe@example.com'},
          enableCaching: true,
          cacheDuration: const Duration(seconds: 30),
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Dio');
  }

  uploadFile() async {
    await extension.pickPhoto(ImageSource.camera).then((file) async {
      if (file.existsSync()) {
        api
            .invoke(
              via: InvokeType.multipart,
              baseUrl: 'https://v2.convertapi.com',
              endpoint: 'upload',
              method: Method.post,
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
    final port = ReceivePort();
    await Isolate.spawn(_downloadFile, [
      port.sendPort,
      url ?? '',
    ]);
    port.listen((message) {
      setDownloadProgress = message;
    });
  }

  static _downloadFile(List arguments) async {
    //var documentDirectory = await getApplicationDocumentsDirectory();
    //var path = '${documentDirectory.path}/pic.jpg';

    await api
        .invoke(
          via: InvokeType.download,
          method: Method.get,
          baseUrl: arguments[1],
          showMessage: false,
          onProgress: (p0) => arguments[0].send(p0),
        )
        .then((response) => arguments[0].send(null));
  }
}
