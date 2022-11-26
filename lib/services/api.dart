import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import '../services/server_env.dart';
import '../shared/enums.dart';
import '../shared/strings.dart';
import '../shared/styles.dart';
import '../utils/debug.dart';
import 'navigation_service.dart';

final api = Api.function;

class Api {
  static Api get function => Api._();
  Api._();

  Future<dynamic> call({
    Map<String, String>? headers,
    Map<String, String>? additionalHeaders,
    String? token,
    dynamic userId,
    required Method method,
    required var endpoint,
    String? contentType,
    bool supportContentType = true,
    var body,
    dynamic id,
    String? query,
    enableEncoding = false,
  }) async {
    var apiEndpoint = buildEndpoint(endpoint: endpoint, id: id, query: query);

    Map<String, String> apiHeaders = headers ??
        buildHeaders(
          token: token,
          contentType: contentType,
          supportContentType: supportContentType,
        );

    if (additionalHeaders != null) apiHeaders.addAll(additionalHeaders);

    try {
      http.Response httpResponse;

      switch (method) {
        case Method.post:
          httpResponse = await http.Client().post(
            Uri.parse(apiEndpoint),
            body: body != null
                ? (enableEncoding ? jsonEncode(body) : body)
                : null,
            headers: apiHeaders,
            encoding: Encoding.getByName("utf-8"),
          );
          break;
        case Method.put:
          httpResponse = await http.Client().put(
            Uri.parse(apiEndpoint),
            body: body != null
                ? (enableEncoding ? jsonEncode(body) : body)
                : null,
            headers: apiHeaders,
          );
          break;
        case Method.delete:
          httpResponse = await http.Client().delete(
            Uri.parse(apiEndpoint),
            body: body != null
                ? (enableEncoding ? jsonEncode(body) : body)
                : null,
            headers: apiHeaders,
            encoding: Encoding.getByName("utf-8"),
          );
          break;
        default:
          httpResponse = await http.Client().get(
            Uri.parse(apiEndpoint),
            headers: apiHeaders,
          );
          break;
      }

      return httpResponse;
    } on SocketException {
      showMessage("Please check your intenet connection",
          type: MessageType.error);
      return null;
    } catch (e) {
      debug.print(e.toString(), boundedText: "API EXCEPTION");
      showMessage("Something went wrong", type: MessageType.error);
      return null;
    }
  }

  Future<dynamic> multipartCall({
    BuildContext? context,
    Map<String, String>? headers,
    String? token,
    String? contentType,
    bool supportContentType = true,
    required http.MultipartRequest requestBody,
  }) async {
    try {
      requestBody.headers.addAll(headers ??
          buildHeaders(
            token: token,
            contentType: contentType,
            supportContentType: supportContentType,
          ));

      http.StreamedResponse streamedResponse = await requestBody.send();
      final body = await streamedResponse.stream.bytesToString();

      return http.Response(body, streamedResponse.statusCode);
    } on SocketException {
      showMessage("Please check your intenet connection",
          type: MessageType.error);
      return null;
    } catch (e) {
      debug.print(e.toString(), boundedText: "Api Exception");
      showMessage("Something went wrong", type: MessageType.error);
      return null;
    }
  }

  Future<Response?> callDio({
    required BuildContext context,
    String? baseUrl,
    Map<String, String>? headers,
    String? token,
    required Method method,
    required var endpoint,
    var body,
    dynamic id,
    Map<String, dynamic>? queryParams,
    String? contentType,
    bool enableCaching = false,
    String? cachePrimaryKey,
    String? cacheSubKey,
    Duration? cacheDuration,
    bool? chacheForceRefresh = false,
    bool enableEncoding = false,
  }) async {
    var apiEndpoint = buildEndpoint(endpoint: endpoint, id: id);
    Map<String, String>? apiHeaders =
        headers ?? buildHeaders(token: token, contentType: contentType);

    try {
      Dio dio = Dio(BaseOptions(
        method: method.name,
        baseUrl: baseUrl ?? ServerEnv.baseUrl,
        headers: apiHeaders,
        validateStatus: (status) => true,
      ))
        ..interceptors.add(DioCacheManager(CacheConfig(
          baseUrl: baseUrl ?? ServerEnv.baseUrl,
          defaultRequestMethod: method.name,
        )).interceptor)
        ..interceptors.add(LogInterceptor(
          request: false,
          requestHeader: false,
          responseHeader: false,
          error: false,
          logPrint: (s) => {},
        ));

      Response response = await dio
          .request(apiEndpoint,
              queryParameters: queryParams,
              data: body != null
                  ? (enableEncoding ? jsonEncode(body) : body)
                  : null,
              options: enableCaching
                  ? buildCacheOptions(
                      cacheDuration ?? const Duration(days: 7),
                      primaryKey: cachePrimaryKey ?? apiEndpoint,
                      subKey: cacheSubKey,
                      forceRefresh: chacheForceRefresh,
                    )
                  : null)
          .onError((error, stackTrace) => throw (error.toString()));

      return response;
    } on SocketException {
      showMessage("Please check your intenet connection",
          type: MessageType.error);
      return null;
    } catch (e) {
      debug.print(e.toString(), boundedText: "Api Exception");
      showMessage("Something went wrong", type: MessageType.error);
      return null;
    }
  }

  void showMessage(
    var response, {
    String? orElse,
    String? actionLabel,
    dynamic Function()? onAction,
    MessageType? type,
    bool showToast = false,
  }) {
    if (response == null) return;
    String message;
    if (response is String) {
      message = response;
    } else {
      var data =
          response is Response ? response.data : jsonDecode(response.body);
      if (data is Map) {
        message = data.containsKey('error')
            ? data['error'] is Map
                ? data['error']['message']
                : data['error']
            : data.containsKey('message')
                ? data['message']
                : data.containsKey('errors')
                    ? data['errors'].toString()
                    : orElse ?? string.someErrorOccured;
      } else if (data is String) {
        message = data;
      } else {
        message = string.someErrorOccured;
      }
    }

    if (showToast) {
      style.toast(message, type: type);
    } else {
      ScaffoldMessenger.of(navigator.context).showSnackBar(style.snackBarStyle(
        message,
        actionLabel: actionLabel ??
            (() {
              switch (type) {
                case MessageType.info:
                  return string.okay;
                case MessageType.error:
                  return string.retry;
                default:
                  return null;
              }
            }()),
        duration: 3,
        onAction: onAction,
      ));
    }
  }

  justifyResponse(
    var response, {
    bool fromAuth = false,
    bool handleResponse = true,
  }) {
    if (response != null &&
        (response is Response || response is http.Response)) {
      debug.print(
          'Status Code: ${response?.statusCode}\nData: ${response is Response ? response.data : response.body}',
          boundedText: 'API');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 409) {
        var data =
            response is Response ? response.data : jsonDecode(response.body);
        if (data is Map && data.containsKey('success')) {
          showMessage(
              data['success']
                  ? null
                  : data['data'] ??
                      (data['message'] ?? string.someErrorOccured),
              type: MessageType.error);
          return data['success'] ? data : null;
        } else {
          return data;
        }
      }
      if (handleResponse) {
        if (response.statusCode == 401) {
          showMessage(response,
              orElse: 'Unauthenticated', type: MessageType.error);
        } else if (response.statusCode == 402) {
          showMessage(response,
              orElse: "Payment Required", type: MessageType.error);
        } else if (response.statusCode == 400) {
          showMessage(response, orElse: "Bad Request", type: MessageType.error);
        } else if (response.statusCode == 404) {
          showMessage(response,
              orElse:
                  fromAuth ? 'Could not authenticate the user' : 'Not Found',
              type: MessageType.error);
        } else if (response.statusCode == 424) {
          showMessage(response, type: MessageType.error);
        } else {
          showMessage(response,
              orElse: string.someErrorOccured, type: MessageType.error);
        }
      }
      return null;
    } else {
      return null;
    }
  }

  decode(var data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      debug.print(data, boundedText: "Response.body in error!");
      debug.print(e);
      return null;
    }
  }

  String buildEndpoint({String? endpoint, var id, var query}) =>
      '$endpoint${id != null ? '/$id' : ''}${query != null ? '?$query' : ''}';

  buildHeaders(
          {String? token,
          String? contentType,
          bool supportContentType = true}) =>
      {
        HttpHeaders.acceptHeader: 'application/json',
        if (supportContentType)
          HttpHeaders.contentTypeHeader: contentType ?? Headers.jsonContentType,
        if (token != null) HttpHeaders.authorizationHeader: "Bearer $token"
      };

  String basicAuthGenerator(
          {required String username, required String password}) =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';
}
