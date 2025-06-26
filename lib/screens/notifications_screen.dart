import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newRecipeNotification = true;
  bool _reminderNotification = true;
  bool _updateNotification = true;
  bool _promoNotification = false;
  final String _reminderTime = '18:00';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pengaturan Notifikasi'),
            backgroundColor: const Color(0xFF7B3F00),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            children: [
              // Main Notification Toggle
              const _SectionHeader(title: 'Notifikasi Umum'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications, color: Color(0xFF7B3F00)),
                title: const Text('Aktifkan Notifikasi'),
                subtitle: const Text('Mengaktifkan semua notifikasi aplikasi'),
                value: appProvider.notificationsEnabled,
                onChanged: (val) {
                  appProvider.toggleNotifications();
                },
              ),
              
              if (appProvider.notificationsEnabled) ...[
                const Divider(),
                
                // Notification Types
                const _SectionHeader(title: 'Jenis Notifikasi'),
                SwitchListTile(
                  secondary: const Icon(Icons.add_circle, color: Color(0xFF7B3F00)),
                  title: const Text('Resep Baru'),
                  subtitle: const Text('Notifikasi ketika ada resep baru dari komunitas'),
                  value: _newRecipeNotification,
                  onChanged: (val) {
                    setState(() {
                      _newRecipeNotification = val;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm, color: Color(0xFF7B3F00)),
                  title: const Text('Pengingat Memasak'),
                  subtitle: const Text('Pengingat untuk memasak sesuai jadwal'),
                  value: _reminderNotification,
                  onChanged: (val) {
                    setState(() {
                      _reminderNotification = val;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.update, color: Color(0xFF7B3F00)),
                  title: const Text('Pembaruan Aplikasi'),
                  subtitle: const Text('Notifikasi ketika ada pembaruan aplikasi'),
                  value: _updateNotification,
                  onChanged: (val) {
                    setState(() {
                      _updateNotification = val;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.local_offer, color: Color(0xFF7B3F00)),
                  title: const Text('Promo & Penawaran'),
                  subtitle: const Text('Notifikasi promo dan penawaran khusus'),
                  value: _promoNotification,
                  onChanged: (val) {
                    setState(() {
                      _promoNotification = val;
                    });
                  },
                ),
                
                const Divider(),
                
                // Reminder Settings
                const _SectionHeader(title: 'Pengaturan Pengingat'),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Color(0xFF7B3F00)),
                  title: const Text('Waktu Pengingat'),
                  subtitle: Text('Setiap hari pukul $_reminderTime'),
                  onTap: () {
                    _showTimePickerDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFF7B3F00)),
                  title: const Text('Hari Pengingat'),
                  subtitle: const Text('Senin - Jumat'),
                  onTap: () {
                    _showDayPickerDialog(context);
                  },
                ),
                
                const Divider(),
                
                // Sound Settings
                const _SectionHeader(title: 'Pengaturan Suara'),
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Color(0xFF7B3F00)),
                  title: const Text('Suara Notifikasi'),
                  subtitle: const Text('Default'),
                  onTap: () {
                    _showSoundPickerDialog(context);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration, color: Color(0xFF7B3F00)),
                  title: const Text('Getaran'),
                  subtitle: const Text('Aktifkan getaran saat notifikasi'),
                  value: true,
                  onChanged: (val) {
                    // TODO: Implement vibration setting
                  },
                ),
                
                const Divider(),
                
                // Quiet Hours
                const _SectionHeader(title: 'Jam Tenang'),
                SwitchListTile(
                  secondary: const Icon(Icons.bedtime, color: Color(0xFF7B3F00)),
                  title: const Text('Aktifkan Jam Tenang'),
                  subtitle: const Text('Tidak ada notifikasi dari 22:00 - 07:00'),
                  value: false,
                  onChanged: (val) {
                    // TODO: Implement quiet hours
                  },
                ),
              ],
              
              const Divider(),
              
              // Help Section
              const _SectionHeader(title: 'Bantuan'),
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF7B3F00)),
                title: const Text('Cara Mengatur Notifikasi'),
                subtitle: const Text('Panduan penggunaan'),
                onTap: () {
                  _showNotificationHelpDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Color(0xFF7B3F00)),
                title: const Text('Laporkan Masalah'),
                subtitle: const Text('Jika notifikasi tidak berfungsi'),
                onTap: () {
                  _showReportDialog(context);
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showTimePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Waktu Pengingat'),
        content: const Text('Fitur akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDayPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Hari Pengingat'),
        content: const Text('Fitur akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSoundPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Suara Notifikasi'),
        content: const Text('Fitur akan segera hadir'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showNotificationHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cara Mengatur Notifikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Aktifkan notifikasi umum terlebih dahulu'),
            SizedBox(height: 8),
            Text('2. Pilih jenis notifikasi yang diinginkan'),
            SizedBox(height: 8),
            Text('3. Atur waktu dan hari pengingat'),
            SizedBox(height: 8),
            Text('4. Pilih suara dan getaran'),
            SizedBox(height: 8),
            Text('5. Atur jam tenang jika diperlukan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Masalah Notifikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jika notifikasi tidak berfungsi:'),
            SizedBox(height: 8),
            Text('• Pastikan notifikasi diaktifkan di pengaturan sistem'),
            SizedBox(height: 8),
            Text('• Restart aplikasi'),
            SizedBox(height: 8),
            Text('• Periksa koneksi internet'),
            SizedBox(height: 8),
            Text('• Hubungi support jika masalah berlanjut'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur support akan segera hadir')),
              );
            },
            child: const Text('Hubungi Support'),
          ),
        ],
      ),
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