import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'AccountScreen.dart';
import 'CamerasAndSharingGroupScreen.dart';
import 'CloudPage.dart';
import 'MapPage.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const HomeScreen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // For example, default to "Cloud" tab

  List<Widget> get _pages => <Widget>[
    const MapPage(),
    const Camerasandsharinggroupscreen(),
    const CloudPage(),
    // Pass the callback to AccountScreen
    AccountScreen(onLocaleChange: widget.onLocaleChange),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: localizations.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: localizations.navCameras,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud),
            label: localizations.navCloud,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizations.navAccount,
          ),
        ],
      ),
    );
  }
}
