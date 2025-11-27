import 'package:flutter/material.dart';
import 'api_service.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> article;
  final bool isPremium;

  const DetailPage({super.key, required this.article, this.isPremium = false});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final id = widget.article['id'] ?? widget.article['raw']?['id'];
      if (id == null) throw Exception('Missing id');
      final d = await _apiService.fetchRestaurantDetail(id.toString());
      if (mounted) setState(() { _detail = d; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article['title'] ?? 'Detail'),
        backgroundColor: const Color(0xFFFFA000),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: ${_error}'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _detail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((d['imageUrl'] ?? '').toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(d['imageUrl'], fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(d['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(d['city'] ?? '', style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 6),
            Text((d['rating'] ?? '').toString()),
          ]),
          const SizedBox(height: 12),
          Text(d['description'] ?? ''),
          const SizedBox(height: 12),
          if (d['menus'] != null) ...[
            const Text('Menus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...((d['menus']['foods'] ?? []) as List).map((f) => Chip(label: Text(f['name'] ?? ''))),
                ...((d['menus']['drinks'] ?? []) as List).map((f) => Chip(label: Text(f['name'] ?? ''))),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (d['customerReviews'] != null) ...[
            const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((d['customerReviews'] as List).reversed).map((r) => ListTile(
                  title: Text(r['name'] ?? ''),
                  subtitle: Text(r['review'] ?? ''),
                  trailing: Text(r['date'] ?? ''),
                )),
          ],
        ],
      ),
    );
  }
}
