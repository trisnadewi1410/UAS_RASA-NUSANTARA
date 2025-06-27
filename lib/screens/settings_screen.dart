import 'package:flutter/material.dart';
import '../helpers/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'theme_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('settings') ?? 'Settings'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            children: [
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('profile') ?? 'Profile'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(AppLocalizations.of(context)?.translate('edit_profile') ?? 'Edit Profile'),
                subtitle: Text(appProvider.userProvider.currentUser?.username ?? 'User'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('display') ?? 'Display'),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: Text(AppLocalizations.of(context)?.translate('app_theme') ?? 'App Theme'),
                subtitle: Text(appProvider.isDarkMode 
                  ? AppLocalizations.of(context)?.translate('dark_mode') ?? 'Dark Mode' 
                  : AppLocalizations.of(context)?.translate('light_mode') ?? 'Light Mode'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeScreen(),
                    ),
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_6_outlined),
                title: Text(AppLocalizations.of(context)?.translate('dark_mode') ?? 'Dark Mode'),
                subtitle: Text(AppLocalizations.of(context)?.translate('activate_dark_theme') ?? 'Activate dark theme'),
                value: appProvider.isDarkMode,
                onChanged: (value) async {
                  await appProvider.toggleDarkMode();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('language') ?? 'Language'),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(AppLocalizations.of(context)?.translate('app_language') ?? 'App Language'),
                subtitle: Text(appProvider.language == 'id' ? 'Bahasa Indonesia' : 'English'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('notifications') ?? 'Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(AppLocalizations.of(context)?.translate('notifications') ?? 'Notifications'),
                subtitle: Text(AppLocalizations.of(context)?.translate('enable_app_notifications') ?? 'Enable app notifications'),
                value: appProvider.notificationsEnabled,
                onChanged: (value) {
                  appProvider.toggleNotifications();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: Text(AppLocalizations.of(context)?.translate('notification_settings') ?? 'Notification Settings'),
                subtitle: Text(AppLocalizations.of(context)?.translate('manage_notification_types') ?? 'Manage notification types'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('data') ?? 'Data'),
              ListTile(
                leading: const Icon(Icons.sync_outlined),
                title: Text(AppLocalizations.of(context)?.translate('data_sync') ?? 'Data Sync'),
                subtitle: Text(AppLocalizations.of(context)?.translate('sync_data_from_server') ?? 'Sync data from server'),
                onTap: () async {
                  await appProvider.refreshData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil diperbarui')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.clear_all, color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)?.translate('clear_cache') ?? 'Bersihkan Cache'),
                subtitle: Text(AppLocalizations.of(context)?.translate('clear_cache_subtitle') ?? 'Hapus data sementara'),
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
              _buildSectionHeader(context, AppLocalizations.of(context)?.translate('account') ?? 'Account'),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(AppLocalizations.of(context)?.translate('logout') ?? 'Keluar', style: const TextStyle(color: Colors.red)),
                onTap: () {
                  _showLogoutDialog(context, appProvider);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('clear_cache') ?? 'Bersihkan Cache'),
        content: Text(AppLocalizations.of(context)?.translate('clear_cache_confirm') ?? 'Apakah Anda yakin ingin membersihkan cache aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('clear_cache_cancel') ?? 'Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Hapus cache: SharedPreferences kecuali data login
              final prefs = await SharedPreferences.getInstance();
              // Simpan data login
              final userId = prefs.getInt('userId');
              final username = prefs.getString('username');
              await prefs.clear();
              // Restore data login
              if (userId != null) await prefs.setInt('userId', userId);
              if (username != null) await prefs.setString('username', username);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)?.translate('clear_cache_success') ?? 'Cache berhasil dibersihkan')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.translate('clear_cache') ?? 'Bersihkan', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('logout') ?? 'Keluar'),
        content: Text(AppLocalizations.of(context)?.translate('logout_confirm') ?? 'Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('logout_cancel') ?? 'Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)?.translate('logout') ?? 'Keluar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
