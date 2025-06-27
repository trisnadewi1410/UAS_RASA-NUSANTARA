import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helpers/app_localizations.dart';
import 'package:rasa_nusantara/screens/add_edit_recipe_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditRecipeScreen(
                    documentId: widget.documentId,
                    initialData: widget.data,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
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
                    child: Icon(Icons.restaurant_menu, size: 80, color: Theme.of(context).colorScheme.primary),
                  ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['Judul Resep'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(204),
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('confirm_delete') ?? 'Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)?.translate('confirm_delete_message') ?? 'Are you sure you want to delete this recipe?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
              onPressed: () async {
                FocusScope.of(context).unfocus(); // Lepaskan fokus keyboard
                try {
                  await FirebaseFirestore.instance
                      .collection('Tambah Resep')
                      .doc(widget.documentId)
                      .delete();
                  
                  if (!mounted) return;
                  
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  appProvider.showSnackBarMessage('Resep berhasil dihapus!');
                  appProvider.setTabIndex(1); // Pindah ke Semua Resep

                  Navigator.of(dialogContext).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali dari detail screen
                } catch (e) {
                  // Handle error
                  Navigator.of(dialogContext).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus resep: $e'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
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
