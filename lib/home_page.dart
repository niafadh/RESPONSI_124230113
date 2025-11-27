import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'api_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _restaurantsFuture;
  Set<String> _favoriteIds = {};
  String _selectedLocation = 'Semua';

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'hi, ';
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    _restaurantsFuture = _apiService.fetchTrendingNews();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? <String>[];
    setState(() => _favoriteIds = list.toSet());
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('favorites') ?? <String>[];
    final set = list.toSet();
    if (set.contains(id)) set.remove(id); else set.add(id);
    await prefs.setStringList('favorites', set.toList());
    setState(() => _favoriteIds = set);
  }

  Future<void> _refreshRestaurants() async {
    setState(() {
      _restaurantsFuture = _apiService.fetchTrendingNews();
    });
    await _restaurantsFuture;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  Widget menuCard(String label, IconData icon, String apiPath) {
    return GestureDetector(
      
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
              BoxShadow(
              color: const Color.fromARGB(255, 255, 230, 226).withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: Colors.brown.shade900),
            ),

            const SizedBox(width: 18),

            // teks utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.brown),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username.isNotEmpty ? username : 'Restaurant App'),
        backgroundColor: const Color(0xFFFFA000),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // RESTAURANT LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshRestaurants,
                    child: FutureBuilder<List<dynamic>>(
                      future: _restaurantsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            final err = snapshot.error;
                            final bool isNetworkError = err is SocketException || (err?.toString().toLowerCase().contains('failed host lookup') ?? false);
                            return ListView(
                              padding: const EdgeInsets.all(24),
                              children: [
                                Center(
                                  child: Text(
                                    isNetworkError
                                        ? 'Gagal terhubung: periksa koneksi internet Anda.'
                                        : 'Error loading restaurants:\n${err}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _refreshRestaurants,
                                    child: const Text('Retry'),
                                  ),
                                ),
                              ],
                            );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              const Center(child: Text('No restaurants found')),
                              const SizedBox(height: 12),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _refreshRestaurants,
                                  child: const Text('Refresh'),
                                ),
                              ),
                            ],
                          );
                        }

                        final items = snapshot.data!;
                        // build list of unique locations (cities)
                        final locations = <String>{};
                        for (var e in items) {
                          final city = (e['source'] ?? e['raw']?['city'] ?? '').toString();
                          if (city.isNotEmpty) locations.add(city);
                        }
                        final locationList = ['Semua', ...locations.toList()..sort()];

                        // apply selected location filter
                        final filtered = _selectedLocation == 'Semua'
                            ? items
                            : items.where((e) => ((e['source'] ?? e['raw']?['city'] ?? '')?.toString() ?? '') == _selectedLocation).toList();

                        return Column(
                          children: [
                            SizedBox(
                              height: 56,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                itemCount: locationList.length,
                                itemBuilder: (context, i) {
                                  final loc = locationList[i];
                                  final selected = loc == _selectedLocation;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(loc),
                                      selected: selected,
                                      selectedColor: const Color(0xFFFFA000),
                                      onSelected: (_) {
                                        setState(() => _selectedLocation = loc);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final r = filtered[index] as Map<String, dynamic>;
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DetailPage(article: r)),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8F2),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown.shade900.withAlpha(30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        r['urlToImage'] ?? '',
                                        width: 84,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(color: Colors.grey[300], width: 84, height: 64);
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], width: 84, height: 64, child: const Icon(Icons.image_not_supported)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(r['source'] ?? '', style: const TextStyle(color: Colors.grey))),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.star, size: 14, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text((r['rating'] ?? '').toString(), style: const TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                         ],
                                       ),
                                     ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(_favoriteIds.contains(r['id']) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                                      onPressed: () => _toggleFavorite(r['id'].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                            ],
                          );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
