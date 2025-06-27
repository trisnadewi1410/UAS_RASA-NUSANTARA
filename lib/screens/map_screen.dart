import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final String _selectedProvince = '';
  List<Map<String, dynamic>> _recipes = [];

  // Koordinat provinsi-provinsi di Indonesia
  final Map<String, LatLng> provinceCoordinates = {
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
    'diy': const LatLng(-7.875384, 110.426208),
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

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Tambah Resep')
          .get();

      final List<Map<String, dynamic>> recipes = [];
      final Set<Marker> markers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final asalMasakan = (data['Asal Masakan'] ?? '').toString().toLowerCase();
        
        recipes.add({
          'id': doc.id,
          'title': data['Judul Resep'] ?? '',
          'origin': data['Asal Masakan'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          ...data,
        });

        // Buat marker untuk setiap provinsi yang memiliki resep
        if (provinceCoordinates.containsKey(asalMasakan)) {
          final position = provinceCoordinates[asalMasakan]!;
          markers.add(
            Marker(
              markerId: MarkerId(asalMasakan),
              position: position,
              infoWindow: InfoWindow(
                title: data['Asal Masakan'] ?? '',
                snippet: 'Tap untuk lihat resep',
                onTap: () => _showRecipesForProvince(asalMasakan, recipes),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }
      }

      setState(() {
        _recipes = recipes;
        _markers = markers;
      });
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  void _showRecipesForProvince(String province, List<Map<String, dynamic>> allRecipes) {
    final provinceRecipes = allRecipes.where((recipe) =>
        (recipe['origin'] ?? '').toString().toLowerCase() == province).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)?.translate('map_recipe_from') ?? 'Resep dari'} ${province.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provinceRecipes.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)?.translate('map_no_recipe') ?? 'Belum ada resep untuk provinsi ini'),
                    )
                  : ListView.builder(
                      itemCount: provinceRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = provinceRecipes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: recipe['imageUrl'] != null && recipe['imageUrl'] != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recipe['imageUrl'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.restaurant_menu),
                            title: Text(recipe['title'] ?? ''),
                            subtitle: Text(recipe['origin'] ?? ''),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to recipe detail
                              Navigator.pushNamed(
                                context,
                                '/recipe-detail',
                                arguments: {
                                  'data': recipe,
                                  'documentId': recipe['id'],
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('map') ?? 'Peta Kuliner Indonesia'),
        backgroundColor: const Color(0xFF7B3F00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)?.translate('map_instruction') ?? 'Tap marker untuk melihat resep dari provinsi tersebut',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(-2.0, 118.0), // Indonesia tengah
                zoom: 5.0,
              ),
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(-2.0, 118.0),
                zoom: 5.0,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF7B3F00),
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
      ),
    );
  }
} 