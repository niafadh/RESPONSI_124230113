import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';

  /// Fetches the restaurant list and maps each item to a neutral article-like
  /// structure used by the UI (keys: title, description, urlToImage, source, id).
  Future<List<dynamic>> fetchTrendingNews({String category = 'general'}) async {
    final uri = Uri.parse('$_baseUrl/list');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load restaurants: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    final List restaurants = jsonBody['restaurants'] ?? [];

    return restaurants.map((r) {
      final pictureId = r['pictureId'] ?? '';
      final imageUrl = pictureId != null && pictureId.toString().isNotEmpty
          ? '$_baseUrl/images/medium/$pictureId'
          : '';

      return {
        'id': r['id'] ?? '',
        'title': r['name'] ?? '',
        'description': r['description'] ?? '',
        'urlToImage': imageUrl,
        'source': r['city'] ?? '',
        'rating': r['rating'] ?? 0,
        // keep original raw data if needed
        'raw': r,
      };
    }).toList(growable: false);
  }

  /// Fetch detail for a specific restaurant id.
  Future<Map<String, dynamic>> fetchRestaurantDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/detail/$id');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load restaurant detail: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    final Map<String, dynamic> restaurant = Map<String, dynamic>.from(jsonBody['restaurant'] ?? {});

    final pictureId = restaurant['pictureId'] ?? '';
    restaurant['imageUrl'] = pictureId != null && pictureId.toString().isNotEmpty
        ? '$_baseUrl/images/medium/$pictureId'
        : '';

    return restaurant;
  }

  /// Search restaurants by query (returns same article-like structure as list).
  Future<List<dynamic>> searchRestaurants(String query) async {
    final uri = Uri.parse('$_baseUrl/search?q=${Uri.encodeQueryComponent(query)}');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Search failed: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonBody = json.decode(resp.body);
    final List restaurants = jsonBody['restaurants'] ?? [];

    return restaurants.map((r) {
      final pictureId = r['pictureId'] ?? '';
      final imageUrl = pictureId != null && pictureId.toString().isNotEmpty
          ? '$_baseUrl/images/medium/$pictureId'
          : '';

      return {
        'id': r['id'] ?? '',
        'title': r['name'] ?? '',
        'description': r['description'] ?? '',
        'urlToImage': imageUrl,
        'source': r['city'] ?? '',
        'raw': r,
      };
    }).toList(growable: false);
  }
}
