import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavoriteDetails();
  }

  Future<List<Map<String, dynamic>>> _loadFavoriteDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? <String>[];
    final futures = ids.map((id) => _apiService.fetchRestaurantDetail(id).catchError((_) => <String,dynamic>{}));
    final results = await Future.wait(futures);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> _removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? <String>[];
    list.remove(id);
    await prefs.setStringList('favorites', list);
    setState(() { _favoritesFuture = _loadFavoriteDetails(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFFFFA000),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoritesFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No favorites yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = items[index];
              return ListTile(
                leading: r['imageUrl'] != null && r['imageUrl'].toString().isNotEmpty
                    ? Image.network(r['imageUrl'], width: 64, height: 48, fit: BoxFit.cover)
                    : const SizedBox(width: 64, height: 48),
                title: Text(r['name'] ?? r['title'] ?? ''),
                subtitle: Text('${r['city'] ?? r['source'] ?? ''} • ⭐ ${r['rating'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _removeFavorite(r['id'].toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
