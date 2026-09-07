import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_exception.dart';
import 'navigator_key.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/screens/login_screen.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = SecureStorageService();
          final token = await storage.getToken();
          if (token != null) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          }
          
          // Debug Logging - Request
          print('--- HTTP REQUEST ---');
          print('URL: ${options.method} ${options.uri}');
          if (options.data != null) {
            final data = Map<String, dynamic>.from(options.data as Map);
            if (data.containsKey('password')) {
              data['password'] = '***HIDDEN***';
            }
            print('BODY: $data');
          }
          print('--------------------');
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Debug Logging - Response
          print('--- HTTP RESPONSE ---');
          print('URL: ${response.requestOptions.method} ${response.requestOptions.uri}');
          print('STATUS CODE: ${response.statusCode}');
          print('BODY: ${response.data}');
          print('---------------------');
          
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Debug Logging - Error
          print('--- HTTP ERROR ---');
          print('URL: ${e.requestOptions.method} ${e.requestOptions.uri}');
          print('STATUS CODE: ${e.response?.statusCode}');
          print('BODY: ${e.response?.data}');
          print('------------------');
          
          if (e.response?.statusCode == 401) {
            final storage = SecureStorageService();
            await storage.clearAll();
            if (navigatorKey.currentContext != null) {
              Navigator.pushAndRemoveUntil(
                navigatorKey.currentContext!,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
          return handler.next(_handleError(e));
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    String message = 'حدث خطأ غير متوقع';
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout || 
        error.type == DioExceptionType.sendTimeout) {
      message = 'انتهى وقت الاتصال بالخادم';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'لا يوجد اتصال بالإنترنت أو الخادم لا يستجيب';
    } else if (error.response != null) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 400) {
        message = 'طلب غير صحيح';
      } else if (statusCode == 401) {
        message = 'غير مصرح لك بالوصول (انتهت الجلسة)';
      } else if (statusCode == 403) {
        message = 'لا تملك صلاحية للوصول';
      } else if (statusCode == 404) {
        message = 'المورد غير موجود';
      } else if (statusCode == 500) {
        message = 'حدث خطأ في الخادم';
      }
      
      // Try to parse error message from API if available
      try {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'];
        }
      } catch (_) {}
    }

    return DioException(
      requestOptions: error.requestOptions,
      error: ApiException(message, statusCode: error.response?.statusCode),
      type: error.type,
    );
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
