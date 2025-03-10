import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final void Function(Locale) onLocaleChange;
  final Locale currentLocale;

  const LanguageSelectionScreen({
    Key? key,
    required this.onLocaleChange,
    required this.currentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLanguage),
      ),
      body: ListView(
        children: [
          ListTile(
            // Display a check icon if English is the current language.
            leading: currentLocale.languageCode == 'en'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            title: Text(localizations.english),
            onTap: () {
              onLocaleChange(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            // Display a check icon if French is the current language.
            leading: currentLocale.languageCode == 'fr'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            title: Text(localizations.french),
            onTap: () {
              onLocaleChange(const Locale('fr'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            // Display a check icon if Italian is the current language.
            leading: currentLocale.languageCode == 'it'
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            title: const Text("Italiano"), // Italian language name
            onTap: () {
              onLocaleChange(const Locale('it'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
