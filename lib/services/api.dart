import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_http_cache/dio_http_cache.dart' as dio;
import 'package:http/http.dart' as http;
import '../services/server_env.dart';
import '../shared/enums.dart';
import '../shared/strings.dart';
import '../shared/styles.dart';
import '../utils/debug.dart';
import 'navigation_service.dart';

final api = Api.function;

enum Method { get, post, put, delete }

enum InvokeType { http, dio, multipart, download }

class Api {
  static Api get function => Api._();
  Api._();

  Future<Response> invoke({
    InvokeType? via,
    String? baseUrl,
    required var endpoint,
    var path,
    Method method = Method.get,
    Map<String, String>? headers,
    Map<String, String>? additionalHeaders,
    Map<String, dynamic>? queryParams,
    var body,
    Duration timeout = const Duration(seconds: 20),
    String? contentType,
    bool contentTypeSupported = true,
    String? token,
    dynamic id,
    bool enableEncoding = false,
    bool justifyResponse = false,
    bool showMessage = true,
    Encoding? encoding,
    bool enableCaching = false,
    String? cachePrimaryKey,
    String? cacheSubKey,
    Duration? cacheDuration,
    bool chacheForceRefresh = false,
    Function(int)? onProgress,
  }) async {
    via ??= (() {
      if (enableCaching ||
          chacheForceRefresh ||
          (cacheDuration ?? cachePrimaryKey ?? cacheSubKey) != null) {
        return InvokeType.dio;
      } else {
        return InvokeType.http;
      }
    }());

    endpoint = _buildEndpoint(
      baseUrl: baseUrl,
      endpoint: endpoint,
      id: id,
      query: via == InvokeType.http ? queryParams : null,
    );

    headers ??= _buildHeaders(
      token: token,
      contentType: contentType,
      contentTypeSupported: contentTypeSupported,
    )..addAll(additionalHeaders ?? {});

    if (body != null) body = enableEncoding ? jsonEncode(body) : body;

    encoding ??= enableEncoding ? utf8 : null;

    if (!enableCaching) enableCaching = cacheDuration != null;

    dio.BaseOptions baseOptions = dio.BaseOptions(
      method: method.name,
      baseUrl: baseUrl ?? ServerEnv.baseUrl,
      connectTimeout: timeout.inMilliseconds,
      headers: headers,
      queryParameters: queryParams,
      validateStatus: (status) => true,
    );

    final dio.LogInterceptor logInterceptor = dio.LogInterceptor(
      request: false,
      requestHeader: false,
      responseHeader: false,
      error: false,
      logPrint: (s) => {},
    );

    Response response = await _exceptionHandler(
          (() async {
            switch (via) {
              case InvokeType.dio:
              case InvokeType.multipart:
              case InvokeType.download:
                int progress = -1;
                dio.Dio dioClient = dio.Dio(
                  (() {
                    switch (via) {
                      case InvokeType.dio:
                        return baseOptions.copyWith(
                          sendTimeout: timeout.inMilliseconds,
                          receiveTimeout: timeout.inMilliseconds,
                        );
                      case InvokeType.download:
                        return baseOptions.copyWith(
                          responseType: dio.ResponseType.bytes,
                          followRedirects: false,
                        );
                      default:
                        return baseOptions;
                    }
                  }()),
                )..interceptors.addAll([
                    if (enableCaching)
                      dio.DioCacheManager(
                        dio.CacheConfig(
                          baseUrl: baseUrl ?? ServerEnv.baseUrl,
                          defaultRequestMethod: method.name,
                        ),
                      ).interceptor,
                    logInterceptor,
                  ]);

                return await dioClient
                    .request(
                      endpoint,
                      data: via == InvokeType.multipart
                          ? dio.FormData.fromMap(body as Map<String, dynamic>)
                          : body,
                      options: enableCaching
                          ? dio.buildCacheOptions(
                              cacheDuration ?? const Duration(days: 7),
                              primaryKey: cachePrimaryKey ?? endpoint,
                              subKey: cacheSubKey,
                              forceRefresh: chacheForceRefresh,
                            )
                          : null,
                      onSendProgress: (received, total) {
                        int newPercentage =
                            total != -1 ? (received / total * 100).toInt() : 0;
                        if (progress != newPercentage) {
                          progress = newPercentage;
                          onProgress?.call(progress);
                        }
                      },
                      onReceiveProgress: (received, total) {
                        int newPercentage =
                            total != -1 ? (received / total * 100).toInt() : 0;
                        if (progress != newPercentage) {
                          progress = newPercentage;
                          onProgress?.call(progress);
                        }
                      },
                    )
                    .onError((error, stackTrace) => throw (error.toString()))
                    .timeout(
                      timeout,
                      onTimeout: () => throw TimeoutException(null),
                    )
                    .then(
                      (response) => Response(
                          statusCode: response.statusCode ?? 404,
                          data: response.data),
                    );

              /* case InvokeType.multipart:
                if (body == null && body != Map) return Response();
                int progress = -1;
                var formData = dio.FormData();

                (body as Map).forEach((key, value) {
                  value is http.MultipartFile
                      ? formData.files.add(MapEntry(
                          '$key',
                          value as dio.MultipartFile,
                        ))
                      : formData.fields.add(MapEntry('$key', '$value'));
                }); */

              /* http.MultipartRequest request = http.MultipartRequest(
                    method.name.toUpperCase(), Uri.parse(endpoint));

                (body as Map).forEach((key, value) {
                  value is http.MultipartFile
                      ? request.files.add(value)
                      : request.fields.addAll({'$key': '$value'});
                });

                request.headers.addAll(headers!);
                http.StreamedResponse streamedResponse = await request.send();
                final responseToString =
                    await streamedResponse.stream.bytesToString();
                http.Response response = http.Response(
                    responseToString, streamedResponse.statusCode);
                return Response(
                    statusCode: response.statusCode,
                    data: jsonDecode(response.body)); */

              case InvokeType.http:
              default:
                http.Client client = http.Client();
                switch (method) {
                  case Method.post:
                    return await client
                        .post(Uri.parse(endpoint),
                            headers: headers, body: body, encoding: encoding)
                        .timeout(
                          timeout,
                          onTimeout: () => throw TimeoutException(null),
                        )
                        .then(
                          (response) => Response(
                              statusCode: response.statusCode,
                              data: jsonDecode(response.body)),
                        );
                  case Method.put:
                    return await client
                        .put(Uri.parse(endpoint),
                            headers: headers, body: body, encoding: encoding)
                        .timeout(
                          timeout,
                          onTimeout: () => throw TimeoutException(null),
                        )
                        .then(
                          (response) => Response(
                              statusCode: response.statusCode,
                              data: jsonDecode(response.body)),
                        );
                  case Method.delete:
                    return await client
                        .delete(Uri.parse(endpoint),
                            headers: headers, body: body, encoding: encoding)
                        .timeout(
                          timeout,
                          onTimeout: () => throw TimeoutException(null),
                        )
                        .then(
                          (response) => Response(
                              statusCode: response.statusCode,
                              data: jsonDecode(response.body)),
                        );
                  default:
                    return await client
                        .get(Uri.parse(endpoint), headers: headers)
                        .timeout(
                          timeout,
                          onTimeout: () => throw TimeoutException(null),
                        )
                        .then(
                          (response) => Response(
                              statusCode: response.statusCode,
                              data: jsonDecode(response.body)),
                        );
                }
            }
          })(),
          showMessage,
        ) ??
        Response();

    return justifyResponse
        ? _justifyResponse(response, showMessage: showMessage)
        : response;
  }

  String _buildEndpoint(
          {String? baseUrl,
          String? endpoint,
          var id,
          Map<String, dynamic>? query}) =>
      '${(baseUrl != null ? '$baseUrl/' : '') + (endpoint ?? '')}'
      '${id != null ? '/$id' : ''}'
      '${(query?.isNotEmpty ?? false) ? '?${query?.entries.map((e) => '${e.key}=${e.value?.toString() ?? ''}').join('&')}' : ''}';

  Map<String, String> _buildHeaders(
          {String? token,
          String? contentType,
          bool contentTypeSupported = true}) =>
      {
        HttpHeaders.acceptHeader: 'application/json',
        if (contentTypeSupported)
          HttpHeaders.contentTypeHeader:
              contentType ?? dio.Headers.jsonContentType,
        if (token != null) HttpHeaders.authorizationHeader: "Bearer $token"
      };

  String basicAuthGenerator(
          {required String username, required String password}) =>
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  Future<dynamic>? _exceptionHandler(Future function,
      [showMessage = true]) async {
    try {
      return await function;
    } on SocketException {
      _showErrorMessage(
        string().someErrorOccured,
        type: MessageType.error,
        logOnly: !showMessage,
        tag: "Socket Exception",
      );
    } on TimeoutException {
      _showErrorMessage(
        string().requestTimeout,
        type: MessageType.error,
        logOnly: !showMessage,
        tag: "Timeout Exception",
      );
    } catch (e) {
      _showErrorMessage(
        e.toString(),
        type: MessageType.error,
        logOnly: !showMessage,
        tag: "Exception",
      );
    }
    return null;
  }

  Response _justifyResponse(
    Response response, {
    bool showMessage = true,
  }) {
    debug.print('Status Code: ${response.statusCode}\nData: ${response.data}',
        boundedText: 'API');

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202 ||
        response.statusCode == 409) {
      return response;
    } else if (showMessage) {
      _showErrorMessage(response, type: MessageType.error);
    }
    return response.copyWith(data: null);
  }

  void _showErrorMessage(
    Object? response, {
    String? tag,
    String? orElse,
    String? actionLabel,
    dynamic Function()? onAction,
    MessageType? type,
    bool showToast = false,
    bool logOnly = false,
  }) {
    response = (() {
      if (response is Response) {
        var data = jsonDecode(response.data);
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
          return orElse ?? string().someErrorOccured;
        }
      } else {
        return response.toString();
      }
    }());

    if (response == null) return;

    debug.print(response, boundedText: tag ?? "Error Log");

    if (logOnly) {
      return;
    } else if (showToast) {
      style.toast(response.toString(), type: type);
    } else {
      ScaffoldMessenger.of(navigator.context).showSnackBar(style.snackBarStyle(
        response.toString(),
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

  Future<Response> download(String url, savePath,
      [Function(int)? onProgress]) async {
    await _exceptionHandler((() async {
      /* await dio.Dio()
          .get(
            url,
            onReceiveProgress: (count, total) => {
              if (total != -1) onProgress?.call((count / total * 100).toInt())
            },
            options: dio.Options(
              responseType: dio.ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: 0,
            ),
          )
          .then((response) => Response(
              statusCode: response.statusCode ?? 404,
              data: jsonDecode(response.data))); */
      var cancelToken = dio.CancelToken();

      await dio.Dio().download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) =>
            {if (total != -1) onProgress?.call((count / total * 100).toInt())},
      );
    }()));
    return Response();
  }
}

class Response {
  final int statusCode;
  final dynamic data;

  Response({this.statusCode = 404, this.data});

  Response copyWith({
    int? statusCode,
    dynamic data,
  }) {
    return Response(
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
    );
  }
}
