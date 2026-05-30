import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final res = await http.get(url).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('GET $endpoint failed (${res.statusCode})');
    }

    return jsonDecode(res.body);
  }
}
