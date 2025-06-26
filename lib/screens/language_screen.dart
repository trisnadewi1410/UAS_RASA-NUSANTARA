import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/app_localizations.dart';
import '../providers/app_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)?.translate('app_language') ?? 'App Language'),
            backgroundColor: const Color(0xFF7B3F00),
            foregroundColor: Colors.white,
          ),
          body: ListView(
            children: [
              _SectionHeader(title: AppLocalizations.of(context)?.translate('choose_language') ?? 'Choose Language'),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context)?.translate('indonesian') ?? 'Indonesian'),
                subtitle: const Text('Indonesian'),
                value: 'id',
                groupValue: appProvider.language,
                onChanged: (value) {
                  if (value != null) {
                    appProvider.setLanguage(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)?.translate('language_changed') ?? 'Language changed')),
                    );
                  }
                },
                secondary: const Icon(Icons.flag, color: Color(0xFF7B3F00)),
              ),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context)?.translate('english') ?? 'English'),
                subtitle: const Text('English'),
                value: 'en',
                groupValue: appProvider.language,
                onChanged: (value) {
                  if (value != null) {
                    appProvider.setLanguage(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)?.translate('language_changed') ?? 'Language changed')),
                    );
                  }
                },
                secondary: const Icon(Icons.flag, color: Color(0xFF7B3F00)),
              ),
              
              const Divider(),
              
              // Language Info Section
              _SectionHeader(title: AppLocalizations.of(context)?.translate('current_language') ?? 'Current Language'),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.translate('current_language') ?? 'Current Language',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.translate('app_currently_using') ?? 'The app is currently using...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Translation Status
              _SectionHeader(title: AppLocalizations.of(context)?.translate('translation_status') ?? 'Translation Status'),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(AppLocalizations.of(context)?.translate('indonesian') ?? 'Indonesian'),
                subtitle: Text(AppLocalizations.of(context)?.translate('translation_status_id') ?? '100% translated'),
                trailing: const Text('100%', style: TextStyle(color: Colors.green)),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(AppLocalizations.of(context)?.translate('english') ?? 'English'),
                subtitle: Text(AppLocalizations.of(context)?.translate('translation_status_en') ?? '100% translated'),
                trailing: const Text('100%', style: TextStyle(color: Colors.green)),
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: Text(AppLocalizations.of(context)?.translate('javanese') ?? 'Javanese'),
                subtitle: Text(AppLocalizations.of(context)?.translate('in_development') ?? 'In development'),
                trailing: const Text('25%', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('coming_soon') ?? 'Feature coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: Text(AppLocalizations.of(context)?.translate('sundanese') ?? 'Sundanese'),
                subtitle: Text(AppLocalizations.of(context)?.translate('in_development') ?? 'In development'),
                trailing: const Text('15%', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('coming_soon') ?? 'Feature coming soon')),
                  );
                },
              ),
              
              const Divider(),
              
              // Help Section
              _SectionHeader(title: AppLocalizations.of(context)?.translate('help') ?? 'Help'),
              ListTile(
                leading: const Icon(Icons.help, color: Color(0xFF7B3F00)),
                title: Text(AppLocalizations.of(context)?.translate('how_to_change_language') ?? 'How to Change Language'),
                subtitle: Text(AppLocalizations.of(context)?.translate('usage_guide') ?? 'Usage guide'),
                onTap: () {
                  _showLanguageHelpDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback, color: Color(0xFF7B3F00)),
                title: Text(AppLocalizations.of(context)?.translate('report_translation_error') ?? 'Report Translation Error'),
                subtitle: Text(AppLocalizations.of(context)?.translate('help_us_improve') ?? 'Help us improve'),
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

  void _showLanguageHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('how_to_change_language') ?? 'How to Change Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. ${AppLocalizations.of(context)?.translate("choose_language") ?? "Choose the desired language from the list above"}'),
            SizedBox(height: 8),
            Text('2. ${"The language will change immediately"}'),
            SizedBox(height: 8),
            Text('3. ${"Settings will be saved automatically"}'),
            SizedBox(height: 8),
            Text('4. ${"Restart the application if needed"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('understand') ?? 'Got it'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('report_translation_error') ?? 'Report Translation Error'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Jika Anda menemukan kesalahan terjemahan, silakan:'),
            SizedBox(height: 8),
            Text('• Screenshot halaman yang bermasalah'),
            SizedBox(height: 8),
            Text('• Kirim ke email: support@resepkita.com'),
            SizedBox(height: 8),
            Text('• Atau gunakan fitur feedback di aplikasi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('close') ?? 'Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.translate('coming_soon') ?? 'Feature coming soon')),
              );
            },
            child: Text(AppLocalizations.of(context)?.translate('send_feedback') ?? 'Send Feedback'),
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