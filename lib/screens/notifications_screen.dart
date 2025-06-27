import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import './settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rasa_nusantara/helpers/app_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('default_channel', 'Default',
          channelDescription: 'Default channel for app notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

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
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _newRecipeNotification = prefs.getBool('notif_new_recipe') ?? true;
      _reminderNotification = prefs.getBool('notif_reminder') ?? true;
      _updateNotification = prefs.getBool('notif_update') ?? true;
      _promoNotification = prefs.getBool('notif_promo') ?? false;
    });
  }

  Future<void> _saveNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_new_recipe', _newRecipeNotification);
    await prefs.setBool('notif_reminder', _reminderNotification);
    await prefs.setBool('notif_update', _updateNotification);
    await prefs.setBool('notif_promo', _promoNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pengaturan Notifikasi'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            children: [
              // Main Notification Toggle
              const _SectionHeader(title: 'Notifikasi Umum'),
              SwitchListTile(
                secondary: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                title: const Text('Aktifkan Notifikasi'),
                subtitle: const Text('Mengaktifkan semua notifikasi aplikasi'),
                value: appProvider.notificationsEnabled,
                onChanged: (value) async {
                  await appProvider.toggleNotifications();
                  // Navigasi ke SettingsScreen (replace agar tidak stack)
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }
                },
              ),
              
              if (appProvider.notificationsEnabled) ...[
                const Divider(),
                
                // Notification Types
                const _SectionHeader(title: 'Jenis Notifikasi'),
                SwitchListTile(
                  secondary: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Resep Baru'),
                  subtitle: const Text('Notifikasi ketika ada resep baru dari komunitas'),
                  value: _newRecipeNotification,
                  onChanged: (val) {
                    setState(() {
                      _newRecipeNotification = val;
                    });
                    _saveNotificationPrefs();
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Pengingat Memasak'),
                  subtitle: const Text('Pengingat untuk memasak sesuai jadwal'),
                  value: _reminderNotification,
                  onChanged: (val) {
                    setState(() {
                      _reminderNotification = val;
                    });
                    _saveNotificationPrefs();
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.update, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Pembaruan Aplikasi'),
                  subtitle: const Text('Notifikasi ketika ada pembaruan aplikasi'),
                  value: _updateNotification,
                  onChanged: (val) {
                    setState(() {
                      _updateNotification = val;
                    });
                    _saveNotificationPrefs();
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.local_offer, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Promo & Penawaran'),
                  subtitle: const Text('Notifikasi promo dan penawaran khusus'),
                  value: _promoNotification,
                  onChanged: (val) {
                    setState(() {
                      _promoNotification = val;
                    });
                    _saveNotificationPrefs();
                  },
                ),
                
                const Divider(),
                
                // Reminder Settings
                const _SectionHeader(title: 'Pengaturan Pengingat'),
                ListTile(
                  leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Waktu Pengingat'),
                  subtitle: Text('Setiap hari pukul $_reminderTime'),
                  onTap: () {
                    _showTimePickerDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
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
                  leading: Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Suara Notifikasi'),
                  subtitle: const Text('Default'),
                  onTap: () {
                    _showSoundPickerDialog(context);
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.vibration, color: Theme.of(context).colorScheme.primary),
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
                  secondary: Icon(Icons.bedtime, color: Theme.of(context).colorScheme.primary),
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
                leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
                title: const Text('Cara Mengatur Notifikasi'),
                subtitle: const Text('Panduan penggunaan'),
                onTap: () {
                  _showNotificationHelpDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.bug_report, color: Theme.of(context).colorScheme.primary),
                title: const Text('Laporkan Masalah'),
                subtitle: const Text('Jika notifikasi tidak berfungsi'),
                onTap: () {
                  _showReportDialog(context);
                },
              ),
              
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (prefs.getBool('notif_promo') ?? false) {
                      await showLocalNotification('Promo!', 'Ada promo baru untukmu!');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifikasi promo dinonaktifkan!')),
                      );
                    }
                  },
                  child: const Text('Test Notifikasi Promo'),
                ),
              ),
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(204),
        ),
      ),
    );
  }
} 