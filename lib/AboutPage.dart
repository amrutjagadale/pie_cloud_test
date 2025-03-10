import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'AccountSecurityPage.dart';
import 'PrivacyPolicyPage.dart';
import 'TermsOfUsePage.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.about),
        backgroundColor: Colors.brown[300], // Matching color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          // App Icon & Name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black12,
                  backgroundImage: AssetImage('assets/app_icon.png'), // Replace with actual asset
                  child: Icon(Icons.cloud, size: 50, color: Colors.black54), // Placeholder icon
                ),
                SizedBox(height: 10),
                Text(
                  localizations.app_name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(localizations.version("1.8.1"), style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Menu Items
          Expanded(
            child: ListView(
              children: [
                _buildListTile(localizations.account_security, context, AccountSecurityPage()),
                _buildListTile(localizations.terms_of_use, context, TermsOfUsePage()),
                _buildListTile(localizations.privacy_policy, context, PrivacyPolicyPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, BuildContext context, Widget page) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
        ),
        Divider(height: 1, thickness: 1),
      ],
    );
  }
}
