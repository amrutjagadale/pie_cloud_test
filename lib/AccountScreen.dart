import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'AboutPage.dart';
import 'FeedbackScreen.dart';
import 'PrivateInformationScreen.dart';
import 'SettingsScreen.dart';
import 'LanguageSelectionScreen.dart'; // Import the language selection screen
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'HDPackagePage.dart';
import 'RazorpayPaymentDemo.dart';

class AccountScreen extends StatelessWidget {
  final void Function(Locale) onLocaleChange; // Receive the callback

  const AccountScreen({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.account), // Localized "Account"
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section - Navigate to Private Information on Tap
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivateInformationScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black12,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 40, color: Colors.black54)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? localizations.userName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? localizations.userEmail,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              localizations.mySharingGroup,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Remaining Time & Streaming Options
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '0',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      localizations.remainingTime,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: const [
                            Icon(Icons.video_camera_front, size: 20, color: Colors.grey),
                            Text('0'),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: const [
                            Icon(Icons.photo, size: 20, color: Colors.grey),
                            Text('0'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.live_tv, size: 18),
                          label: Text(localizations.liveStreaming),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HDPackagesPage(
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.hd, size: 18),
                          label: Text(localizations.hdPackage),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(localizations.notifications),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: Text(localizations.plan),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RazorpayPaymentDemo (
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(localizations.orderHistory),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations.settings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text(localizations.feedback),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.language),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectionScreen(
                      onLocaleChange: onLocaleChange,
                      currentLocale: Localizations.localeOf(context),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.about),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
