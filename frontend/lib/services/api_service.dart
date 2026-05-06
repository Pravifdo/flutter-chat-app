import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // REGISTER
  static Future register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(res.body);
  }

  // LOGIN
  static Future login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(res.body);
  }

  // SEND MESSAGE
  static Future sendMessage(
    String senderId,
    String receiverId,
    String message,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/messages/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "senderId": senderId,
        "receiverId": receiverId,
        "message": message,
      }),
    );

    return jsonDecode(res.body);
  }

  // GET MESSAGES
  static Future getMessages(String user1, String user2) async {
    final res = await http.get(Uri.parse("$baseUrl/messages/$user1/$user2"));

    return jsonDecode(res.body);
  }
}
