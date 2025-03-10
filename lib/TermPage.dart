import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ActivationHelpExactPage();
  }
}

class ActivationHelpExactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return Scaffold(
        body: Center(child: Text("Localization not available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- Section 1.0 -----------------
            Text(
              localizations.email_exists,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCase(localizations.case_1, localizations.email_registered_activated),
            _buildCase(localizations.case_2, localizations.email_registered_not_activated),

            const SizedBox(height: 20),

            Text(
              localizations.activate_account,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCase(localizations.case_1, localizations.account_not_activated),
            _buildCase(localizations.case_2, localizations.activation_email_not_found),
            _buildCase(localizations.case_3, localizations.account_activated_but_issue),

            const SizedBox(height: 20),

            // ----------------- Section 1.2 -----------------
            Text(
              localizations.activate_account,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCase(localizations.case_1, localizations.reset_password_email),
          ],
        ),
      ),
    );
  }

  /// Reusable method to build each case in a bordered container
  Widget _buildCase(String caseTitle, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caseTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
