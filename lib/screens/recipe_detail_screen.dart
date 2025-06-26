import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helpers/app_localizations.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;
  const RecipeDetailScreen({super.key, required this.data, required this.documentId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.documentId.isNotEmpty) {
      FirebaseFirestore.instance
        .collection('Tambah Resep')
        .doc(widget.documentId)
        .set({'viewCount': FieldValue.increment(1)}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['Judul Resep'] ?? 'Detail Resep'),
        backgroundColor: const Color(0xFF7B3F00),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.data['imageUrl'] != null && widget.data['imageUrl'] != '')
                ? Image.network(
                    widget.data['imageUrl'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                  ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['Judul Resep'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF7B3F00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      widget.data['Deskripsi'] ?? 'Tidak ada deskripsi.',
                      style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(179),
                        height: 1.5,
                      ),
                    ),
                  ),
                  _buildDetailSection(context, AppLocalizations.of(context)?.translate('origin') ?? 'Origin', widget.data['Asal Masakan'] ?? 'Tidak diketahui'),
                  _buildDetailSection(context, AppLocalizations.of(context)?.translate('ingredients') ?? 'Ingredients', widget.data['Bahan-Bahan'] ?? 'Tidak ada bahan.'),
                  _buildDetailSection(context, AppLocalizations.of(context)?.translate('steps') ?? 'Steps', widget.data['Langkah-Langkah'] ?? 'Tidak ada langkah.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(204),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
