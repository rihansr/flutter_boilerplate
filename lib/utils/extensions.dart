import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../services/navigation_service.dart';
import '../utils/debug.dart';

final extension = Extension.function;

class Extension {
  static Extension get function => Extension._();
  Extension._();

  String maskRegex = r"\\w(?=\\w{4})";

  Future<bool> hasPermission(Permission permission,
      {bool doAction = true}) async {
    PermissionStatus status = await permission.status;

    bool permit = false;

    if (status.isGranted) {
      permit = true;
    } else {
      if (doAction) {
        if (status.isRestricted) {
          await permission.shouldShowRequestRationale;
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        } else {
          await permission
              .request()
              .then((status) => permit = status.isGranted);
        }
      }
    }

    return permit;
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(
      String assetName) async {
    String svgString =
        await DefaultAssetBundle.of(navigator.context).loadString(assetName);
    DrawableRoot svgDrawableRoot =
        await svg.fromSvgString(svgString, assetName);
    ui.Picture picture = svgDrawableRoot.toPicture();
    ui.Image image = await picture.toImage(80, 80);
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void screenOrientation({bool landscape = false, fullscreen = false}) => {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: fullscreen ? [] : SystemUiOverlay.values),
        SystemChrome.setPreferredOrientations([
          landscape
              ? DeviceOrientation.landscapeRight
              : DeviceOrientation.portraitUp,
          landscape
              ? DeviceOrientation.landscapeLeft
              : DeviceOrientation.portraitDown,
        ]),
      };

  Future<File> pickPhoto(ImageSource source,
      {Function(File file)? onPicked,
      double? maxWidth,
      double? maxHeight,
      int? imageQuality}) async {
    String path = '';
    await extension
        .hasPermission(source == ImageSource.camera
            ? Permission.camera
            : Permission.storage)
        .then((hasPermission) async {
      if (!hasPermission) {
        path = '';
      } else {
        var pickedFile = await ImagePicker().pickImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
        path = pickedFile?.path ?? '';
      }
    });
    if (File(path).existsSync()) onPicked?.call(File(path));
    return File(path);
  }

  Future<dynamic> pickFiles(
      {bool allowMultiple = false,
      FileType type = FileType.custom,
      List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: type,
      allowCompression: true,
      allowedExtensions: allowedExtensions ??
          [
            'mp4',
            'm4v',
            'hevc',
            'mov',
            'avi',
            '3gp',
            'mkv',
            'flv',
            'zip',
            'doc',
            'docx',
            'csv',
            'xlx',
            'jpg',
            'png',
            'jpeg',
            'pdf'
          ],
    );

    if (result != null) {
      return allowMultiple
          ? result.paths.map((path) => File(path ?? '')).toList()
          : File(result.files.single.path ?? '');
    } else {
      return allowMultiple ? [] : File('');
    }
  }

  Future<bool> isFileSizeExceeded(File file,
      {int? sizeInKb, int? sizeInMb}) async {
    if (!file.existsSync() || (sizeInKb == null && sizeInMb == null)) {
      return false;
    }

    /// Get length of file in bytes
    int fileSizeInBytes = await file.length();

    /// Convert the bytes to Kilobytes (1 KB = 1024 Bytes)
    double fileSizeInKB = fileSizeInBytes / 1024;
    if (sizeInKb != null && fileSizeInKB > sizeInKb) return true;

    /// Convert the KB to MegaBytes (1 MB = 1024 KBytes)
    double fileSizeInMB = fileSizeInKB / 1024;
    if (sizeInMb != null && fileSizeInMB > sizeInMb) return true;

    return false;
  }

  String fileSizeFormat(var value) {
    if (value == null) return '0 bytes';

    /// Get length of file in bytes
    int fileSizeInBytes =
        value is File ? value.length() as int : int.parse('$value');

    /// Convert the bytes to Kilobytes (1 KB = 1024 Bytes)
    double fileSizeInKB = fileSizeInBytes / 1024;

    /// Convert the KB to MegaBytes (1 MB = 1024 KBytes)
    double fileSizeInMB = fileSizeInKB / 1024;

    if (fileSizeInMB > 1) {
      return '${fileSizeInMB.toStringAsFixed(1)} mb';
    } else if (fileSizeInKB > 1) {
      return '${fileSizeInKB.toStringAsFixed(1)} kb';
    } else {
      return '${fileSizeInBytes.toStringAsFixed(1)} bytes';
    }
  }

  Future<bool> saveFileToDownloads(var data, [String? fileName]) async {
    try {
      String downloadFolder = (await getApplicationDocumentsDirectory()).path;

      fileName ??= fileName?.isEmpty ?? true
          ? '${DateTime.now().millisecondsSinceEpoch}'
          : fileName;

      File saveFile = File("$downloadFolder/$fileName");

      saveFile.writeAsBytesSync(data is File ? data.readAsBytesSync() : data);

      return true;
    } catch (ex) {
      debug.print('Saving file to downloads, failure reason: $ex',
          bounded: true, boundedText: 'Exception');
      return false;
    }
  }

  Future<void> launchURL(String? url) async =>
      await canLaunchUrlString(url ?? '')
          ? await launchUrlString(url!)
          : throw 'Could not launch $url';

  String generateRandomString({int length = 6, digitsOnly = false}) {
    const digits = "1234567890";
    const letters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    var chars = digitsOnly ? digits : (letters + digits);
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}

extension CapExtension on String {
  String get inCaps =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get allInCaps => toUpperCase();
  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

extension DateTimeParser on dynamic {
  String get parseTime {
    int duration = 0;
    duration = int.parse('$this');

    String seconds = '', minutes = '', hour = '';
    seconds = (duration % 60).toString();
    minutes = ((duration ~/ 60) % 60).toString();
    hour = (duration ~/ 3600).toString();
    if (seconds.length == 1) seconds = "0$seconds";
    if (minutes.length == 1) minutes = "0$minutes";
    if (hour.length == 1) hour = "0$hour";

    return '${hour}h ${minutes}m';
  }

  String? timeRemains(
      {String existingFormat = 'dd/MM/yyyy', String orElse = ''}) {
    if (this == null) return orElse;
    DateTime date1 =
        this is DateTime ? this : DateFormat(existingFormat).parse(this);
    DateTime date2 = DateTime.now();
    int hours = date1.difference(date2).inHours;
    int mins = date1.difference(date2).inMinutes;

    bool isTimeOver = hours < 0;
    if (isTimeOver) hours = date2.difference(date1).inHours;
    if (isTimeOver) mins = date2.difference(date1).inMinutes;

    return (hours > 0
            ? '$hours hours ${mins - (hours * 60)} minutes'
            : '$mins minutes') +
        (isTimeOver ? ' overdue' : '');
  }

  String? parseDateTime(String format,
      {String existingFormat = 'dd/MM/yyyy',
      String orElse = '',
      Duration? duration}) {
    if (this == null) return orElse;
    DateTime finalDateTime =
        this is DateTime ? this : DateFormat(existingFormat).parse(this);
    if (duration != null) finalDateTime = finalDateTime.add(duration);
    return DateFormat(format).format(finalDateTime);
  }

  String timeAgo(
      {bool numericDates = true,
      String existingFormat = 'dd/MM/yyyy',
      String orElse = ''}) {
    if (this == null) return orElse;
    DateTime date1 =
        this is DateTime ? this : DateFormat(existingFormat).parse(this);
    DateTime date2 = DateTime.now();
    final difference = date2.difference(date1);

    if (difference.inDays > 8) {
      return '${difference.inDays} days ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}

extension ContextExtension on BuildContext? {
  MediaQueryData get mediaQuery => MediaQuery.of(this ?? navigator.context);
  EdgeInsets get padding => mediaQuery.padding;
  Size get size => mediaQuery.size;
  double get height => size.height;
  double get width => size.width;

  ThemeData get theme => Theme.of(this ?? navigator.context);
  TextTheme get textTheme => theme.textTheme;
  IconThemeData get iconTheme => theme.iconTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

extension ObjectConversion on Object? {
  String stringAsFixed({int fractionDigits = 2, String orElse = ''}) {
    if (this == null) return orElse;
    double digit = this?.toDouble() ?? 0.0;
    return digit.toStringAsFixed((digit % 1) == 0 ? 0 : fractionDigits);
  }

  double toDouble({double orElse = 0}) =>
      this != null ? double.parse('$this') : orElse;

  int toInteger({int orElse = 0}) => this != null ? int.parse('$this') : orElse;

  bool toBool({bool orElse = false}) => this == null
      ? orElse
      : this is bool
          ? this as bool
          : '$this' == '1';

  int fromBool({int orElse = 0}) => this is bool
      ? this as bool
          ? 1
          : 0
      : toInteger(orElse: orElse);
}

double toDouble(dynamic val) => double.parse('${val ?? 0}');
int toInteger(dynamic val) => int.parse('${val ?? 0}');
bool toBool(dynamic val) => val is bool ? val : '${val ?? 0}' == '1';
int fromBool(bool val) => val ? 1 : 0;
