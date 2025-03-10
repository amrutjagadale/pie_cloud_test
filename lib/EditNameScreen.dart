import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditNameScreen extends StatefulWidget {
  final String currentName;
  final Function(String) onNameUpdated;

  EditNameScreen({required this.currentName, required this.onNameUpdated});

  @override
  _EditNameScreenState createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  Future<void> _updateUserName() async {
    String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Name cannot be empty",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      User? user = _auth.currentUser;
      await user?.updateDisplayName(newName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({'displayName': newName});

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.usernameUpdated,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      widget.onNameUpdated(newName); // Send updated name back
      Navigator.pop(context, newName); // Pass back new name
    } catch (e) {
      Fluttertoast.showToast(
        msg:AppLocalizations.of(context)!.error(e),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Colors.brown[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _updateUserName,
            child: Text(
              AppLocalizations.of(context)!.done,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

