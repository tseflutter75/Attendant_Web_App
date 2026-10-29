import 'dart:convert';
import 'dart:io';
import 'package:attendantwebapp/features/Auth/presentation/auth_controller.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart';

class NetworkCaller {
  static final Logger _logger = Logger();
  ////////////////////////////////////////.. GET Api../////////////////////////////////////////////////
  static Future<ApiResponse> getRequest({
    required String url,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      _logRequest(url);

      Response response = await get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      _logResponse(url, response);

      final int statusCode = response.statusCode;

      if (statusCode == 200) {
        // SUCCESS
        final decodedData = jsonDecode(response.body);
        return ApiResponse(
          isSuccess: true,
          responseCode: statusCode,
          responseData: decodedData,
          errorMessage: decodedData['message']?.toString() ?? " ",
        );
      } else if (statusCode == 401) {
        await AuthController.goToLogin();
        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: null,
          errorMessage: 'Session Expired – Login Again',
        );
      } else {
        // FAILED
        final decodedData = jsonDecode(response.body);

        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: decodedData,
          // errorMessage: decodedData['data'],
          errorMessage: decodedData['message']?.toString() ?? " ",
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: "No internet! Check your connection.",
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

  ////////////////////////////////////////.. POST API ../////////////////////////////////////////////////
  static Future<ApiResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      _logRequest(url, body: body);

      Response response = await post(
        uri,
        headers: {
          'Accept': 'application/json',
          'content-type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },

        body: jsonEncode(body),
      );

      _logResponse(url, response);

      final int statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 201) {
        // SUCCESS

        final decodedData = jsonDecode(response.body);

        return ApiResponse(
          isSuccess: true,
          responseCode: statusCode,
          responseData: decodedData,
          errorMessage: decodedData['message']?.toString() ?? " ",
        );
      } else if (statusCode == 401) {
        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: null,
          errorMessage: 'Session Expired – Login Again',
        );
      } else {
        // FAILED

        final decodedData = jsonDecode(response.body);

        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: decodedData,
          // ✅ This FIX prevents crash
          errorMessage: decodedData['message']?.toString() ?? " ",
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: "No internet! Check your connection.",
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

  ////////////////////////////////////////.. Delete Api../////////////////////////////////////////////////
  static Future<ApiResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      _logRequest(url, body: body);

      Response response = await delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      _logResponse(url, response);

      final int statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 204) {
        final decodedData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;

        return ApiResponse(
          isSuccess: true,
          responseCode: statusCode,
          responseData: decodedData,
          errorMessage:
              decodedData?['message']?.toString() ?? "Deleted Successfully",
        );
      } else if (statusCode == 401) {
        await AuthController.goToLogin();
        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: null,
          errorMessage: 'Session Expired – Login Again',
        );
      } else {
        final decodedData = jsonDecode(response.body);

        return ApiResponse(
          isSuccess: false,
          responseCode: statusCode,
          responseData: decodedData,
          errorMessage: decodedData['message']?.toString() ?? " ",
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: "No internet! Check your connection.",
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        responseCode: -1,
        responseData: null,
        errorMessage: e.toString(),
      );
    }
  }

  // LOGGER
  static void _logRequest(String url, {Map<String, dynamic>? body}) {
    _logger.i(
      'URL => $url\n'
      'Request Body: $body',
    );
  }

  static void _logResponse(String url, Response response) {
    _logger.i(
      'URL => $url\n'
      'Status Code: ${response.statusCode}\n'
      'Body: ${response.body}',
    );
  }
}

// RESPONSE CLASS
class ApiResponse {
  final bool isSuccess;

  final int responseCode;

  final dynamic responseData;

  final String errorMessage;

  ApiResponse({
    required this.isSuccess,
    required this.responseCode,
    required this.responseData,
    required this.errorMessage,
  });
}
