import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple API client for talking to the Python/FastAPI backend.
///
/// For now we assume the backend runs locally on port 8000:
///   python -m uvicorn app.main:app --reload --port 8000
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // Configure at build/run time:
  // flutter run -d edge --dart-define=API_BASE_URL=http://127.0.0.1:8000
  // For production, set via environment variable or build flag
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  Future<List<Map<String, dynamic>>> search(String query,
      {int topK = 10}) async {
    final uri = Uri.parse('$_baseUrl/search');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'top_k': topK,
        'filters': {},
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Search failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final uri = Uri.parse('$_baseUrl/history');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load history');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchDocuments() async {
    final uri = Uri.parse('$_baseUrl/documents');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load documents');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> createDocument(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/documents');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create document');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete document');
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final uri = Uri.parse('$_baseUrl/profile');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load profile');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/profile');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}
