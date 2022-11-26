import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/debug.dart';

final extension = Extension.function;

class Extension {
  static Extension get function => Extension._();
  Extension._();

  String maskRegex = r"\\w(?=\\w{4})";

  /* String? string(var value, {var orElse = '', bool lowercase = false}) {
    if (validator.isEmpty(value)) return orElse;
    return value is TextEditingController
        ? lowercase
            ? value.text.toString().trim().toLowerCase()
            : value.text.toString().trim()
        : lowercase
            ? value.toString().trim().toLowerCase()
            : value.toString().trim();
  } */

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
      {double? maxWidth, double? maxHeight, int? imageQuality}) async {
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

    return File(path);
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

  Future<bool> saveFileToDownloads({var data, String? fileName}) async {
    try {
      String downloadFolder = (await getApplicationDocumentsDirectory()).path;

      fileName ??= fileName?.isEmpty ?? true
          ? '${DateTime.now().millisecondsSinceEpoch}'
          : fileName;

      File saveFile = File("$downloadFolder/$fileName");

      saveFile.writeAsBytesSync(
          data is File ? data.readAsBytesSync() : data.bodyBytes);

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

  String generateRandomString({int length = 6}) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
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

extension DigitExtension on dynamic {
  String stringAsFixed(int fractionDigits) {
    if (this == null) return '';
    double digit = double.parse("$this");
    return this.toStringAsFixed((digit % 1) == 0 ? 0 : fractionDigits);
  }
}

extension DateTimeParser on dynamic {
   /* bool dateExpired({int multipliedBy = 1}) => validator.isEmpty(this)
      ? false
      : validator.isNotMatch(this, 0) &&
          (int.parse('${this ?? 0}') * multipliedBy) <
              DateTime.now().toUtc().millisecondsSinceEpoch; */

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

  String? remainingTime(
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

double toDouble(dynamic val) => double.parse('${val ?? 0}');
int toInteger(dynamic val) => int.parse('${val ?? 0}');
bool toBool(dynamic val) => val is bool ? val : '${val ?? 0}' == '1';
int fromBool(bool val) => val ? 1 : 0;
