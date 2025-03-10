import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditNameScreen.dart';
import 'LoginPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivateInformationScreen extends StatefulWidget {
  @override
  _PrivateInformationScreenState createState() => _PrivateInformationScreenState();
}

class _PrivateInformationScreenState extends State<PrivateInformationScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String displayName = "User Name";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      displayName = user?.displayName ?? AppLocalizations.of(context)!.userName;
    });
  }

  void updateUserName(String newName) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'displayName': newName,
      });

      // Reload user to get updated name
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      // Update UI
      setState(() {
        displayName = user?.displayName ?? newName;
      });

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.usernameUpdated,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privateInformation),
        backgroundColor: Colors.brown[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? Icon(Icons.person, size: 50, color: Colors.black54) : null,
            ),
            SizedBox(height: 10),
            Text(
              displayName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            ListTile(
              title: Text(AppLocalizations.of(context)!.name),
              subtitle: Text(displayName),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                final newName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNameScreen(
                      currentName: displayName,
                      onNameUpdated: updateUserName,
                    ),
                  ),
                );

                if (newName != null && newName is String) {
                  updateUserName(newName);
                }
              },
            ),
            SizedBox(height: 20),

            // Sign Out Button
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.loggedOut,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(prefilledEmail: '', onLocaleChange: (Locale locale) {}),
                    ),
                        (route) => false,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.loginFailed,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(AppLocalizations.of(context)!.signOut, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
