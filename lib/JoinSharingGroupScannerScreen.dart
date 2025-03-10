import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class JoinSharingGroupScannerScreen extends StatefulWidget {
  const JoinSharingGroupScannerScreen({Key? key}) : super(key: key);

  @override
  State<JoinSharingGroupScannerScreen> createState() =>
      _JoinSharingGroupScannerScreenState();
}

class _JoinSharingGroupScannerScreenState
    extends State<JoinSharingGroupScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  bool _hasScanned = false; // Prevent multiple scans

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1) Live camera preview using MobileScanner.
          MobileScanner(
            controller: _cameraController,
            onDetect: (BarcodeCapture capture) {
              if (_hasScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _hasScanned = true;
                  });
                  // Stop scanning to prevent further detections.
                  _cameraController.stop();
                  // Optionally, show a Snackbar with the result.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.qrCodeFound(code))),
                  );
                  // After a short delay, pop this screen and return the result.
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pop(context, code);
                  });
                }
              }
            },
          ),

          Positioned.fill(child: const _ScannerOverlay()),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.brown[300],
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      'Join Sharing Group',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () {
                        _cameraController.toggleTorch();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4) Floating button to pick an image from the gallery.
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.image, color: Colors.black),
              onPressed: _scanFromGallery,
            ),
          ),
        ],
      ),
    );
  }

  /// Picks an image from the gallery, analyzes it for QR codes,
  /// and returns the scanned result.
  Future<void> _scanFromGallery() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      final Uint8List imageData = await pickedFile.readAsBytes();
      final List<Barcode>? barcodes =
      (await _cameraController.analyzeImage(imageData as String)) as List<Barcode>?;
      if (barcodes != null && barcodes.isNotEmpty) {
        final String? code = barcodes.first.rawValue;
        if (code != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.scanSharedCameraQr),
          )
          );
          Navigator.pop(context, code);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.noQrCodeFound),
        )
        )
        ;
      }
    } catch (e) {
      debugPrint('Error scanning image: $e');
    }
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return IgnorePointer(
      // Prevents this overlay from blocking interactions.
      ignoring: true,
      child: Stack(
        children: [
          // Dim the entire screen.
          Container(color: Colors.black.withOpacity(0.5)),
          // Center the scanning box.
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // Draw white corners.
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: _ScannerBoxPainter(),
                  ),
                  // Draw a horizontal scanning line.
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                  // Flashlight icon (optional, for visual reference).
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Icon(Icons.flashlight_on,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  // Instruction text.
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        localizations.scanSharedCameraQr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const double cornerLength = 30.0;
    final path = Path();

    // Top-left corner.
    path.moveTo(0, cornerLength);
    path.lineTo(0, 0);
    path.lineTo(cornerLength, 0);

    // Top-right corner.
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLength);

    // Bottom-left corner.
    path.moveTo(0, size.height - cornerLength);
    path.lineTo(0, size.height);
    path.lineTo(cornerLength, size.height);

    // Bottom-right corner.
    path.moveTo(size.width - cornerLength, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
