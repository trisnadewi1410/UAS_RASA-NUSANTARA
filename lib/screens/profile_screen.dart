import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/app_localizations.dart';
import '../providers/app_provider.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.translate('profile') ?? 'Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFFF6B35),
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return Text(
                    appProvider.userProvider.currentUser?.username ?? 'User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.translate('welcome') ?? 'Welcome to Rasa Nusantara!',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF7B3F00)),
            title: Text(AppLocalizations.of(context)?.translate('settings') ?? 'Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF7B3F00)),
            title: Text(AppLocalizations.of(context)?.translate('help') ?? 'Help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF7B3F00)),
            title: Text(AppLocalizations.of(context)?.translate('about_app') ?? 'About App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Rasa Nusantara',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Rasa Nusantara Team',
                children: [
                  const SizedBox(height: 8),
                  const Text('Aplikasi inspirasi masakan, tanpa drama.'),
                ],
              );
            },
          ),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  AppLocalizations.of(context)?.translate('logout') ?? 'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap:
                    appProvider.userProvider.isLoading
                        ? null
                        : () async {
                          await appProvider.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
              );
            },
          ),
        ],
      ),
    );
  }
}
