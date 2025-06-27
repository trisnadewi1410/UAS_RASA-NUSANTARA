import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/app_localizations.dart';
import 'package:rasa_nusantara/screens/recipe_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'all_recipes_screen.dart';
import '../models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'add_edit_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo/logo_resepkita.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Rasa Nusantara',
              style: TextStyle(
                color: Color(0xFFF5E9DA),
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Color(0xFFF5E9DA)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppLocalizations.of(context)?.translate('discover_recipes') ?? "Discover Recipes",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.translate('search_recipes') ?? 'Search for recipes...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: const Icon(Icons.map, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)?.translate('culinary_map') ?? 'Peta Kuliner',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_searchQuery.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)?.translate('popular_recipes') ?? "Popular Recipes",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Tambah Resep')
                  .orderBy('viewCount', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)?.translate('no_popular_recipes') ?? 'No popular recipes yet.'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final documentId = docs[i].id;
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(data: data, documentId: documentId),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 6,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: (data['imageUrl'] != null && data['imageUrl'] != '')
                                    ? Image.network(
                                        data['imageUrl'],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.restaurant_menu, size: 80, color: Theme.of(context).colorScheme.primary),
                                      ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['Judul Resep'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Asal: ${data['Asal Masakan'] ?? ''}',
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    } else {
      print('Query: ${_searchQuery.trim().toLowerCase()}');
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Tambah Resep')
            .where('search_keywords', arrayContains: _searchQuery.trim().toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)?.translate('no_recipes_found') ?? 'No recipes found.'));
          }
          final docs = snapshot.data!.docs;
          final hasil = docs.where((recipe) =>
            ((recipe.data() as Map<String, dynamic>)['Judul Resep'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ((recipe.data() as Map<String, dynamic>)['Asal Masakan'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ((recipe.data() as Map<String, dynamic>)['Bahan-Bahan'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
          return ListView.builder(
            itemCount: hasil.length,
            itemBuilder: (context, i) {
              final data = hasil[i].data() as Map<String, dynamic>;
              final documentId = hasil[i].id;
              return ListTile(
                leading: data['imageUrl'] != null && data['imageUrl'] != ''
                    ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(data['Judul Resep'] ?? ''),
                subtitle: Text(data['Asal Masakan'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(data: data, documentId: documentId),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }
}

final Map<String, LatLng> originCoordinates = {
  'aceh': const LatLng(4.695135, 96.749397),
  'sumatera utara': const LatLng(2.115354, 99.545097),
  'sumatera barat': const LatLng(-0.739939, 100.800003),
  'riau': const LatLng(0.293347, 101.706829),
  'kepulauan riau': const LatLng(3.945651, 108.142867),
  'jambi': const LatLng(-1.485183, 102.438057),
  'bengkulu': const LatLng(-3.792845, 102.260764),
  'sumatera selatan': const LatLng(-3.319437, 103.914399),
  'bangka belitung': const LatLng(-2.741051, 106.440587),
  'lampung': const LatLng(-4.558584, 105.406807),
  'banten': const LatLng(-6.405817, 106.064018),
  'dki jakarta': const LatLng(-6.208763, 106.845599),
  'jawa barat': const LatLng(-6.90389, 107.61861),
  'jawa tengah': const LatLng(-7.150975, 110.140259),
  'diy': const LatLng(-7.875384, 110.426208), // Daerah Istimewa Yogyakarta
  'jawa timur': const LatLng(-7.536064, 112.238401),
  'bali': const LatLng(-8.409518, 115.188919),
  'nusa tenggara barat': const LatLng(-8.652933, 117.361647),
  'nusa tenggara timur': const LatLng(-8.657381, 121.079371),
  'kalimantan barat': const LatLng(-0.278778, 111.475285),
  'kalimantan tengah': const LatLng(-1.681487, 113.382354),
  'kalimantan selatan': const LatLng(-3.092641, 115.283758),
  'kalimantan timur': const LatLng(0.538658, 116.419389),
  'kalimantan utara': const LatLng(3.073092, 116.041388),
  'sulawesi utara': const LatLng(1.493049, 124.841253),
  'sulawesi tengah': const LatLng(-1.430025, 121.445617),
  'sulawesi selatan': const LatLng(-3.668799, 119.974053),
  'sulawesi tenggara': const LatLng(-4.14491, 122.174605),
  'gorontalo': const LatLng(0.699937, 122.446723),
  'sulawesi barat': const LatLng(-2.844137, 119.232078),
  'maluku': const LatLng(-3.238462, 130.145273),
  'maluku utara': const LatLng(1.570999, 127.808769),
  'papua': const LatLng(-4.269928, 138.080353),
  'papua barat': const LatLng(-1.336115, 133.174716),
  'papua selatan': const LatLng(-7.6674, 139.7020),
  'papua tengah': const LatLng(-3.9167, 137.5833),
  'papua pegunungan': const LatLng(-4.0833, 138.8333),
  'papua barat daya': const LatLng(-1.0, 132.0),
}; 