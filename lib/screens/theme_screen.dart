import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tema Aplikasi'),
            backgroundColor: const Color(0xFF7B3F00),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            children: [
              // Theme Mode Section
              const _SectionHeader(title: 'Mode Tema'),
              RadioListTile<String>(
                title: const Text('Mode Terang'),
                subtitle: const Text('Tema terang dengan latar belakang putih'),
                value: 'light',
                groupValue: appProvider.isDarkMode ? 'dark' : 'light',
                onChanged: (value) {
                  if (value == 'light' && appProvider.isDarkMode) {
                    appProvider.toggleDarkMode();
                  }
                },
                secondary: const Icon(Icons.light_mode, color: Color(0xFF7B3F00)),
              ),
              RadioListTile<String>(
                title: const Text('Mode Gelap'),
                subtitle: const Text('Tema gelap dengan latar belakang hitam'),
                value: 'dark',
                groupValue: appProvider.isDarkMode ? 'dark' : 'light',
                onChanged: (value) {
                  if (value == 'dark' && !appProvider.isDarkMode) {
                    appProvider.toggleDarkMode();
                  }
                },
                secondary: const Icon(Icons.dark_mode, color: Color(0xFF7B3F00)),
              ),
              RadioListTile<String>(
                title: const Text('Mengikuti Sistem'),
                subtitle: const Text('Otomatis mengikuti pengaturan sistem'),
                value: 'system',
                groupValue: 'system', // Always selected for now
                onChanged: (value) {
                  // TODO: Implement system theme detection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur akan segera hadir')),
                  );
                },
                secondary: const Icon(Icons.settings_system_daydream, color: Color(0xFF7B3F00)),
              ),
              
              const Divider(),
              
              // Color Theme Section
              const _SectionHeader(title: 'Warna Tema'),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3F00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: const Text('Coklat (Default)'),
                subtitle: const Text('Warna tema utama aplikasi'),
                trailing: const Icon(Icons.check, color: Color(0xFF7B3F00)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Warna tema berhasil diubah')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: const Text('Hijau'),
                subtitle: const Text('Tema hijau segar'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur akan segera hadir')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: const Text('Biru'),
                subtitle: const Text('Tema biru tenang'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur akan segera hadir')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: const Text('Ungu'),
                subtitle: const Text('Tema ungu elegan'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur akan segera hadir')),
                  );
                },
              ),
              
              const Divider(),
              
              // Preview Section
              const _SectionHeader(title: 'Preview'),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contoh Tampilan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ini adalah contoh bagaimana aplikasi akan terlihat dengan tema yang dipilih.',
                      style: TextStyle(
                        fontSize: 14,
                        color: appProvider.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B3F00),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tombol Contoh'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7B3F00),
        ),
      ),
    );
  }
} 