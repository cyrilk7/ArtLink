import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://europe-west2-level-ward-430511-k2.cloudfunctions.net/artlink-function-1';

  Future<http.Response> _sendRequest(String method, String endpoint,
      {dynamic body,
      Map<String, String>? queryParams,
      File? file,
      bool requiresAuth = false,
      String? token // Flag to determine if authentication is needed
      }) async {
    final uri =
        Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);

    final request = http.MultipartRequest(method, uri);

    if (requiresAuth && token != null) {
      request.headers['Authorization'] =
          'Bearer $token'; // Add the token to the headers if required
    }

    if (body != null) {
      request.fields.addAll(body as Map<String, String>);
    }

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split('/').last, // Extract filename from path
      ));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Function to send a POST request with optional Authorization header
  Future<http.Response> post(String endpoint, dynamic data,
      {String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization':
            'Bearer $token', // Conditionally add Authorization header
    };

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  // Function to send a GET request with optional Authorization header
  Future<http.Response> get(String endpoint, {String? token}) async {
    final headers = <String, String>{
      if (token != null)
        'Authorization':
            'Bearer $token', // Conditionally add Authorization header
    };

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    return response;
  }

  Future<http.Response> put(String endpoint, dynamic data,
      {String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization':
            'Bearer $token', // Conditionally add Authorization header
    };

    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> postImg(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    File? file,
    bool requiresAuth = false,
    String? token,
  }) {
    return _sendRequest('POST', endpoint,
        body: body,
        queryParams: queryParams,
        file: file,
        requiresAuth: requiresAuth,
        token: token);
  }

  Future<http.Response> putImg(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    File? file,
    bool requiresAuth = false,
    String? token,
  }) {
    return _sendRequest('PUT', endpoint,
        body: body,
        queryParams: queryParams,
        file: file,
        requiresAuth: requiresAuth,
        token: token);
  }
}
