import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helpers/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

const String imgurClientId = 'ca61cb7506ddc25'; // Pastikan Client ID benar

class AddEditRecipeScreen extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const AddEditRecipeScreen({super.key, this.documentId, this.initialData});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Controllers untuk setiap field
  final TextEditingController _asalMasakanController = TextEditingController();
  final TextEditingController _judulResepController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _bahanBahanController = TextEditingController();
  final TextEditingController _langkahLangkahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _judulResepController.text = widget.initialData!['Judul Resep'] ?? '';
      _deskripsiController.text = widget.initialData!['Deskripsi'] ?? '';
      _bahanBahanController.text = widget.initialData!['Bahan-Bahan'] ?? '';
      _langkahLangkahController.text = widget.initialData!['Langkah-Langkah'] ?? '';
      _asalMasakanController.text = widget.initialData!['Asal Masakan'] ?? '';
      _existingImageUrl = widget.initialData!['imageUrl'];
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (builderContext) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galeri'),
                    onTap: () {
                      _getImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () {
                    _getImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToImgur(File imageFile) async {
    setState(() => _isLoading = true);
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {'Authorization': 'Client-ID $imgurClientId'},
        body: {'image': base64Image, 'type': 'base64'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['link'];
      } else {
        debugPrint('Upload Imgur gagal: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error upload ke Imgur: $e');
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRecipeToFirestore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImageToImgur(_imageFile!);
      if (imageUrl == null && _imageFile != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunggah gambar. Silakan coba lagi.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    // Siapkan data untuk disimpan
    final Map<String, dynamic> recipeData = {
      'Asal Masakan': _asalMasakanController.text,
      'Judul Resep': _judulResepController.text,
      'judul_lowercase': _judulResepController.text.toLowerCase(),
      'Deskripsi': _deskripsiController.text,
      'Bahan-Bahan': _bahanBahanController.text,
      'Langkah-Langkah': _langkahLangkahController.text,
      // Jika ada gambar baru, gunakan URL baru. Jika tidak, gunakan URL lama.
      'imageUrl': imageUrl ?? _existingImageUrl,
    };

    try {
      if (widget.documentId != null) {
        // Mode Edit: Update dokumen yang ada
        await FirebaseFirestore.instance.collection('Tambah Resep').doc(widget.documentId).update(recipeData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      } else {
        // Mode Tambah: Buat dokumen baru
        await FirebaseFirestore.instance.collection('Tambah Resep').add(recipeData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil disimpan!'), backgroundColor: Colors.green),
        );
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    } catch (e) {
      debugPrint('Error menyimpan ke Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan resep: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null 
            ? AppLocalizations.of(context)?.translate('add_recipe') ?? 'Add Recipe' 
            : AppLocalizations.of(context)?.translate('edit_recipe') ?? 'Edit Recipe'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : (_existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context)?.translate('tap_to_select_image') ?? 'Tap to select image',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(_judulResepController, AppLocalizations.of(context)?.translate('recipe_title') ?? 'Recipe Title'),
                    _buildTextFormField(_asalMasakanController, AppLocalizations.of(context)?.translate('origin') ?? 'Origin'),
                    _buildTextFormField(_deskripsiController, AppLocalizations.of(context)?.translate('description') ?? 'Description', maxLines: 3),
                    _buildTextFormField(_bahanBahanController, AppLocalizations.of(context)?.translate('ingredients') ?? 'Ingredients', maxLines: 5),
                    _buildTextFormField(_langkahLangkahController, AppLocalizations.of(context)?.translate('steps') ?? 'Steps', maxLines: 7),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          backgroundColor: const Color(0xFF7B3F00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveRecipeToFirestore,
                        child: Text(AppLocalizations.of(context)?.translate('save_recipe') ?? 'Save Recipe'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label ${AppLocalizations.of(context)?.translate('cannot_be_empty') ?? 'cannot be empty'}';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan semua controller di-dispose
    _asalMasakanController.dispose();
    _judulResepController.dispose();
    _deskripsiController.dispose();
    _bahanBahanController.dispose();
    _langkahLangkahController.dispose();
    super.dispose();
  }
}
