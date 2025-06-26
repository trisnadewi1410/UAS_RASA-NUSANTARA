import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'FAQ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.question_answer, color: Color(0xFF7B3F00)),
            title: Text('Bagaimana cara menambah resep?'),
            subtitle: Text(
              'Tekan tombol + di halaman utama, lalu isi formulir dan simpan.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.question_answer, color: Color(0xFF7B3F00)),
            title: Text('Bagaimana cara mengedit profil?'),
            subtitle: Text(
              'Fitur edit profil akan tersedia di update berikutnya.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.question_answer, color: Color(0xFF7B3F00)),
            title: Text('Bagaimana jika lupa password?'),
            subtitle: Text('Hubungi admin melalui menu bantuan.'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Kembali ke Profil'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
