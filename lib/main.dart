import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase is already initialized or encountered an error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  /// Load the saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeCode = prefs.getString('selected_locale');
    if (localeCode != null) {
      setState(() {
        _locale = Locale(localeCode);
      });
    }
  }

  /// Update locale and save it in SharedPreferences
  void onLocaleChange(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', newLocale.languageCode);

    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('it'), // Italian (NEW)
      ],
      home: HomeScreen(onLocaleChange: onLocaleChange),
    );
  }
}
