import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'jwt.dart';


class TokenService {
  static const String baseUrl = 'http://192.168.1.13:5006/api';

  static Future<String?> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await prefs.setString('token', data['token']);
      return data['token'];
    } else {
      return null;
    }
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      return null;
    }

    // Refresh the token if it's close to expiry
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    if (expiryDate.isBefore(DateTime.now().add(Duration(minutes: 10)))) {
      token = await refreshToken();
    }

    return token;
  }

  static Future<String?> refreshDriverToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/drivers/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await prefs.setString('token', data['token']);
      return data['token'];
    } else {
      return null;
    }
  }

  static Future<String?> getDriverToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      return null;
    }

    // Refresh the token if it's close to expiry
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    if (expiryDate.isBefore(DateTime.now().add(Duration(minutes: 10)))) {
      token = await refreshDriverToken();
    }

    return token;
  }
}
