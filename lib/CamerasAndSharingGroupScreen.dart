import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AddCameraScreen.dart';
import 'JoinSharingGroupScannerScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


enum CamerasSubScreen {
  camerasMain,
  sharingGroupMain,
  joinSharingGroup,
}

/// CamerasScreen: toggles between Cameras main, Sharing Group main, and Join screen.
class Camerasandsharinggroupscreen extends StatefulWidget {
  const Camerasandsharinggroupscreen({Key? key}) : super(key: key);

  @override
  State<Camerasandsharinggroupscreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends State<Camerasandsharinggroupscreen> {
  // Start in Cameras main view.
  CamerasSubScreen _currentSubScreen = CamerasSubScreen.camerasMain;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Decide which top label is "active" based on the current sub-screen.
    bool isCamerasActive = (_currentSubScreen == CamerasSubScreen.camerasMain);
    bool isSharingGroupActive = (_currentSubScreen == CamerasSubScreen.sharingGroupMain ||
        _currentSubScreen == CamerasSubScreen.joinSharingGroup);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _currentSubScreen = CamerasSubScreen.camerasMain);
                    },
                    child: Text(
                      localizations.cameras,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCamerasActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      setState(() => _currentSubScreen = CamerasSubScreen.sharingGroupMain);
                    },
                    child: Text(
                      localizations.join_sharing_group,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSharingGroupActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildSubScreenContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Decide which sub-screen content to show.
  Widget _buildSubScreenContent() {
    switch (_currentSubScreen) {
      case CamerasSubScreen.camerasMain:
        return _buildCamerasMain();
      case CamerasSubScreen.sharingGroupMain:
        return _buildSharingGroupMain();
      case CamerasSubScreen.joinSharingGroup:
        return _buildJoinSharingGroup();
    }
  }

  /// 1) Cameras main: "Add a camera" & "Join Sharing Group" buttons
  Widget _buildCamerasMain() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStyledButton(
              text: localizations.add_camera,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCameraScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildStyledButton(
              text: localizations.join_sharing_group,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinSharingGroupScannerScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 2) Sharing Group main: single button
  Widget _buildSharingGroupMain() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: _buildStyledButton(
        text: localizations.join_sharing_group,
        onPressed: () {
          setState(() => _currentSubScreen = CamerasSubScreen.joinSharingGroup);
        },
      ),
    );
  }

  /// 3) "Join Sharing Group" deeper sub-screen
  Widget _buildJoinSharingGroup() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: _buildStyledButton(
          text: localizations.join_sharing_group,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JoinSharingGroupScannerScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Helper method to build styled buttons
  Widget _buildStyledButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
