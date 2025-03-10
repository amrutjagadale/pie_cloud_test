import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _downloadPhotos = false;
  bool _saveToAlbum = false;
  String _cacheSize = "Calculating...";

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved toggle states
    _getCacheSize();
  }

  /// Load toggle states from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadPhotos = prefs.getBool('downloadPhotos') ?? false;
      _saveToAlbum = prefs.getBool('saveToAlbum') ?? false;
    });
  }

  /// Save toggle states to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('downloadPhotos', _downloadPhotos);
    await prefs.setBool('saveToAlbum', _saveToAlbum);
  }

  Future<void> _getCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    int size = _calculateSize(cacheDir);
    setState(() {
      _cacheSize = "${(size / 1024).toStringAsFixed(2)} KB";
    });
  }

  int _calculateSize(Directory dir) {
    int totalSize = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true).forEach((file) {
          if (file is File) {
            totalSize += file.lengthSync();
          }
        });
      }
    } catch (e) {
      print("Error getting cache size: $e");
    }
    return totalSize;
  }

  Future<void> _clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      setState(() {
        _cacheSize = "0.0 KB";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cacheCleared)),
      );
    } catch (e) {
      print("Error clearing cache: $e");
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearCacheTitle),
        content: Text(AppLocalizations.of(context)!.clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.downloadPhotos),
            value: _downloadPhotos,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                _downloadPhotos = value;
              });
              _saveSettings(); // Save toggle state
            },
          ),
          SwitchListTile(
            title: Text(localizations.saveToAlbum),
            value: _saveToAlbum,
            activeColor: Colors.green,
            onChanged: (bool value) {
              setState(() {
                _saveToAlbum = value;
              });
              _saveSettings(); // Save toggle state
            },
          ),
          ListTile(
            title: Text(localizations.imageCache),
            subtitle: Text(_cacheSize),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showClearCacheDialog,
            ),
          ),
        ],
      ),
    );
  }
}
