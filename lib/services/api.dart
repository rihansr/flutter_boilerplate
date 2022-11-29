import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_http_cache/dio_http_cache.dart' as dio;
import 'package:http/http.dart' as http;
import '../services/server_env.dart';
import '../shared/enums.dart';
import '../shared/strings.dart';
import '../shared/styles.dart';
import '../utils/debug.dart';

final api = Api.function;

enum Method { get, post, put, delete }

enum InvokeType { http, dio, multipart }

class Api {
  static Api get function => Api._();
  Api._();

  Future<T?> invoke<T>({
    InvokeType invokeType = InvokeType.http,
    var endpoint,
    String? baseUrl,
    Method method = Method.get,
    Map<String, String>? headers,
    Map<String, String>? additionalHeaders,
    Map<String, dynamic>? queryParams,
    var body,
    Duration? timeout,
    String? contentType,
    bool supportContentType = true,
    String? token,
    dynamic id,
    bool enableEncoding = true,
    bool justifyResponse = true,
    bool showMessage = true,
    Encoding? encoding,
    bool enableCaching = false,
    String? cachePrimaryKey,
    String? cacheSubKey,
    Duration? cacheDuration,
    bool? chacheForceRefresh = false,
  }) async {
    endpoint = Uri.parse(
        _buildEndpoint(endpoint: endpoint, id: id, query: queryParams));

    headers ??= _buildHeaders(
      token: token,
      contentType: contentType,
      supportContentType: supportContentType,
    )..addAll(additionalHeaders ?? {});

    if (body != null) {
      body = (enableEncoding && body is! http.MultipartRequest
          ? jsonEncode(body)
          : body);
    }

    encoding ??= enableEncoding ? utf8 : null;

    timeout ??= const Duration(seconds: 20);

    if (!enableCaching) enableCaching = cacheDuration != null;

    T? response = await _exceptionHandler(
      (() async {
        switch (invokeType) {
          case InvokeType.dio:
            dio.Dio dioClient = dio.Dio(dio.BaseOptions(
              method: method.name,
              baseUrl: baseUrl ?? ServerEnv.baseUrl,
              headers: headers,
              validateStatus: (status) => true,
            ))
              ..interceptors.addAll([
                if (enableCaching)
                  dio.DioCacheManager(
                    dio.CacheConfig(
                      baseUrl: baseUrl ?? ServerEnv.baseUrl,
                      defaultRequestMethod: method.name,
                    ),
                  ).interceptor,
                dio.LogInterceptor(
                  request: false,
                  requestHeader: false,
                  responseHeader: false,
                  error: false,
                  logPrint: (s) => {},
                )
              ]);
            return await dioClient
                .request(endpoint,
                    queryParameters: queryParams,
                    data: body,
                    options: enableCaching
                        ? dio.buildCacheOptions(
                            cacheDuration ?? const Duration(days: 7),
                            primaryKey: cachePrimaryKey ?? endpoint,
                            subKey: cacheSubKey,
                            forceRefresh: chacheForceRefresh,
                          )
                        : null)
                .onError((error, stackTrace) => throw (error.toString()));

          case InvokeType.multipart:
            (body as http.MultipartRequest).headers.addAll(headers!);
            http.StreamedResponse streamedResponse = await body.send();
            final response = await streamedResponse.stream.bytesToString();
            return http.Response(response, streamedResponse.statusCode);

          case InvokeType.http:
          default:
            http.Client client = http.Client();
            switch (method) {
              case Method.post:
                return await client
                    .post(endpoint,
                        headers: headers, body: body, encoding: encoding)
                    .timeout(
                      timeout!,
                      onTimeout: () => throw TimeoutException(null),
                    );
              case Method.put:
                return await client
                    .put(endpoint,
                        headers: headers, body: body, encoding: encoding)
                    .timeout(
                      timeout!,
                      onTimeout: () => throw TimeoutException(null),
                    );
              case Method.delete:
                return await client
                    .delete(endpoint,
                        headers: headers, body: body, encoding: encoding)
                    .timeout(
                      timeout!,
                      onTimeout: () => throw TimeoutException(null),
                    );
              default:
                return await client.get(endpoint, headers: headers).timeout(
                      timeout!,
                      onTimeout: () => throw TimeoutException(null),
                    );
            }
        }
      })(),
      showMessage,
    );

    return justifyResponse
        ? _justifyResponse(response, showMessage: showMessage)
        : response;
  }

  Future<dynamic>? _exceptionHandler(Future function,
      [showMessage = true]) async {
    try {
      return await function;
    } on SocketException {
      if (showMessage) {
        _showMessage(string().someErrorOccured,
            type: MessageType.error, tag: "Socket Exception");
      } else {
        debug.print(string().someErrorOccured, boundedText: "Socket Exception");
      }
    } on TimeoutException {
      if (showMessage) {
        _showMessage(string().requestTimeout,
            type: MessageType.error, tag: "Timeout Exception");
      } else {
        debug.print(string().requestTimeout, boundedText: "Timeout Exception");
      }
    } catch (e) {
      if (showMessage) {
        _showMessage(e.toString(), type: MessageType.error, tag: "Exception");
      } else {
        debug.print(e.toString(), boundedText: "Exception");
      }
    }
    return null;
  }

  void _showMessage(
    var response, {
    String? tag,
    String? orElse,
    String? actionLabel,
    dynamic Function()? onAction,
    MessageType? type,
    bool showToast = false,
  }) {
    if (response == null) return;
    String message = (() {
      if (response is String) {
        return response;
      } else {
        var data = response is dio.Response
            ? response.data
            : jsonDecode(response.body);
        if (data is Map) {
          return data.containsKey('error')
              ? data['error'] is Map
                  ? data['error']['message']
                  : data['error']
              : data.containsKey('message')
                  ? data['message']
                  : data.containsKey('errors')
                      ? data['errors'].toString()
                      : orElse ?? string().someErrorOccured;
        } else if (data is String) {
          return data;
        } else {
          return string().someErrorOccured;
        }
      }
    }());

    debug.print(message, boundedText: tag ?? "Response Message");

    if (showToast) {
      style.toast(message, type: type);
    } else {
      ScaffoldMessenger.of(navigator.context).showSnackBar(style.snackBarStyle(
        message,
        actionLabel: actionLabel ??
            (() {
              switch (type) {
                case MessageType.info:
                  return string().okay;
                case MessageType.error:
                  return string().retry;
                default:
                  return null;
              }
            }()),
        duration: 3,
        onAction: onAction,
      ));
    }
  }

  _justifyResponse(
    var response, {
    bool showMessage = true,
  }) {
    if (response != null &&
        (response is dio.Response || response is http.Response)) {
      debug.print(
          'Status Code: ${response?.statusCode}\nData: ${response is dio.Response ? response.data : response.body}',
          boundedText: 'API');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 409) {
        var data = response is dio.Response
            ? response.data
            : jsonDecode(response.body);
        if (data is Map && data.containsKey('success')) {
          if (showMessage) {
            _showMessage(
              data['success']
                  ? null
                  : data['data'] ??
                      (data['message'] ?? string().someErrorOccured),
              type: MessageType.error,
            );
          }
          return data['success'] ? data : null;
        } else {
          return data;
        }
      } else if (showMessage) {
        _showMessage(
          response,
          orElse: (() {
            switch (response.statusCode) {
              case 401:
                return 'Unauthenticated';
              case 402:
                return "Payment Required";
              case 400:
                return "Bad Request";
              case 404:
                return 'Not Found';
              case 424:
                return 'Failed Dependency';
              default:
                return string().someErrorOccured;
            }
          }()),
          type: MessageType.error,
        );
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String _buildEndpoint(
          {String? endpoint, var id, Map<String, dynamic>? query}) =>
      '$endpoint'
      '${id != null ? '/$id' : ''}'
      '${(query?.isNotEmpty ?? false) ? '?${query?.entries.map((e) => '${e.key}=${e.value?.toString() ?? ''}').join('&')}' : ''}';

  Map<String, String> _buildHeaders(
          {String? token,
          String? contentType,
          bool supportContentType = true}) =>
      {
        HttpHeaders.acceptHeader: 'application/json',
        if (supportContentType)
          HttpHeaders.contentTypeHeader:
              contentType ?? dio.Headers.jsonContentType,
        if (token != null) HttpHeaders.authorizationHeader: "Bearer $token"
      };

  String basicAuthGenerator(
          {required String username, required String password}) =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';
}
