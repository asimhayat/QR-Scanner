import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:flutter/services.dart'; // For clipboard functionality

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isScanCompleted = false;
  String scannedCode = "";
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool qrDetected = false;

  @override
  void initState() {
    super.initState();
    cameraController.start(); // Start the camera when the widget is initialized
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: scannedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void resetScanner() {
    setState(() {
      isScanCompleted = false;
      qrDetected = false;
      scannedCode = "";
    });
    cameraController.start(); // Restart the camera to allow for a new scan
  }

  void toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void displayScannedCode() {
    setState(() {
      isScanCompleted = true;
    });
    cameraController.stop(); // Stop the camera after scanning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcode, args) {
              if (!qrDetected) {
                setState(() {
                  qrDetected = true;
                  scannedCode = barcode.rawValue ?? "No code found";
                });
              }
            },
          ),
          QRScannerOverlay(
            borderColor: Colors.black,
            borderRadius: 20,
            borderStrokeWidth: 10,
            scanAreaWidth: 250,
            scanAreaHeight: 250,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                icon: Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: toggleFlash,
              ),
            ),
          ),
          if (qrDetected && !isScanCompleted)
            Center(
              child: GestureDetector(
                onTap: displayScannedCode,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white.withOpacity(0.7),
                  child: Text(
                    "QR Code detected. Tap to view.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          if (isScanCompleted)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Scanned QR Code:",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      scannedCode,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: copyToClipboard,
                          child: Text("Copy"),
                        ),
                        ElevatedButton(
                          onPressed: resetScanner,
                          child: Text("Scan Again"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}
