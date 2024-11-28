import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String _scannedBarcode = "";
  bool _isScanned = false;

  /// Function to initiate barcode scanning
  Future<void> scanBarcode() async {
    try {
      // Start scanning
      final scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        "#00FF00", // Line color (green)
        "Cancel", // Cancel button text
        true, // Show the flash option
        ScanMode.BARCODE, // Scan mode
      );

      // Check if a valid barcode was scanned
      if (scannedBarcode != '-1') {
        setState(() {
          _scannedBarcode = scannedBarcode;
          _isScanned = true; // Mark the scan as successful
        });

        // Automatically reset the state after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _isScanned = false; // Reset the success checkmark
          });
        });
      }
    } catch (e) {
      setState(() {
        _scannedBarcode = "Failed to scan barcode: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Camera or scanning area
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isScanned ? Colors.green : Colors.grey, // Green border on success
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isScanned)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 100,
                    )
                  else
                    const Center(
                      child: Text(
                        'Point the camera at a barcode',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Results area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_scannedBarcode.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Scanned Result: $_scannedBarcode',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: scanBarcode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan Barcode',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scannedBarcode = ""; // Clear the barcode result
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
