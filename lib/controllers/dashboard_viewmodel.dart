import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api.dart';
import '../shared/icons.dart';
import '../utils/debug.dart';
import '../utils/extensions.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this.context) : super();

  final BuildContext context;

  init() {
    //analyticsService.setUser();
  }

  List navigations = [
    {
      'icon': AppIcons.cart_rounded,
      'label': 'Cart',
    },
    {
      'icon': AppIcons.home_rounded,
      'label': 'Home',
    },
    {
      'icon': AppIcons.profile_outlined,
      'label': 'Profile',
    },
  ];

  get navigation => navigations[_selectedTab];

  int get centerTab => (navigations.length / 2).floor();
  bool get isCenterTab => _selectedTab == centerTab;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int i) => {
        if (_selectedTab != i) {_selectedTab = i, notifyListeners()}
      };

  httpCall() async {
    setBusy(true, key: 'Http');
    await api
        .invoke(
          via: InvokeType.http,
          method: Method.get,
          endpoint: 'https://httpbin.org',
          id: 'get',
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Http');
  }

  dioCall() async {
    setBusy(true, key: 'Dio');
    await api
        .invoke(
          via: InvokeType.dio,
          method: Method.post,
          baseUrl: 'https://httpbin.org',
          endpoint: 'post',
          queryParams: {'id': 56, 's': 'john'},
          body: {'name': 'John Doe', 'email': 'johndoe@example.com'},
          showMessage: true,
          contentTypeSupported: false,
          cacheDuration: const Duration(seconds: 30),
        )
        .then((response) => debug.print(response.data));
    setBusy(false, key: 'Dio');
  }

  uploadFile() async {
    await extension.pickPhoto(ImageSource.gallery).then((file) async {
      if (file.existsSync()) {
        api
            .invoke(
              via: InvokeType.multipart,
              method: Method.post,
              baseUrl: 'https://v2.convertapi.com',
              endpoint: 'upload',
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
    var documentDirectory = await getApplicationDocumentsDirectory();
    var path = '${documentDirectory.path}/pic.jpg';

    await api
        .invoke(
          via: InvokeType.download,
          method: Method.get,
          endpoint: url,
          path: path,
          onProgress: (p0) => setDownloadProgress = p0,
        )
        .then((response) => {
              setDownloadProgress = null,
            });
  }
}
