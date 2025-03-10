import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanQrCodeScreen extends StatefulWidget {
  const ScanQrCodeScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Camera Preview
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_hasScanned) return;
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() => _hasScanned = true);
                  // Example: show a snack bar & pop back with the result
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.qrCodeFound(code))),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pop(context, code);
                  });
                }
              }
            },
          ),

          // 2) Top App Bar (custom)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.brown[300], // Match the brownish bar in screenshot
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Back Arrow
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      AppLocalizations.of(context)!.scan_qr_code,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    // Flash Toggle
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

          // 3) Custom overlay with the scanning box & instructions
          const Positioned.fill(
            child: _ScannerOverlay(),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // overlay is visual-only
      child: Stack(
        children: [
          // Semi-transparent black overlay
          Container(color: Colors.black.withOpacity(0.5)),

          // Centered scanning box
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  // 1) White corners
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: _ScannerBoxPainter(),
                  ),

                  // 2) Flashlight icon (centered)
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.flashlight_on,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3) Instruction text at the bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.scanSharedCameraQr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
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

    const cornerLen = 30.0;
    final path = Path();

    // Top-left corner
    path.moveTo(0, cornerLen);
    path.lineTo(0, 0);
    path.lineTo(cornerLen, 0);

    // Top-right corner
    path.moveTo(size.width - cornerLen, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLen);

    // Bottom-left corner
    path.moveTo(0, size.height - cornerLen);
    path.lineTo(0, size.height);
    path.lineTo(cornerLen, size.height);

    // Bottom-right corner
    path.moveTo(size.width - cornerLen, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - cornerLen);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
