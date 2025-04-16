import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'colors.dart';

class MediMatchScreen extends StatefulWidget {
  const MediMatchScreen({super.key});

  @override
  MediMatchScreenState createState() => MediMatchScreenState();
}

class MediMatchScreenState extends State<MediMatchScreen> {
  String _scannedBarcode = "";
  final List<String> _scannedHistory = [];

  bool _isScanHovered = false;
  bool _isManualHovered = false;

  Future<void> _scanBarcode() async {
    try {
      final scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
        "0xFF00FBB0",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );

      if (scannedBarcode != '-1') {
        setState(() {
          _scannedBarcode = scannedBarcode;
          _scannedHistory.add(scannedBarcode);
        });
      }
    } catch (e) {
      setState(() {
        _scannedBarcode = "Failed to scan barcode: $e";
      });
    }
  }

  void _resetScan() {
    setState(() {
      _scannedBarcode = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    const double tileHeight = 120.0;
    const double logoSize = 80.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MEDIMATCH',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mintColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan Medicine',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Action Tiles
            Row(
              children: [
                // Scan Barcode
                Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isScanHovered = true),
                    onExit: (_) => setState(() => _isScanHovered = false),
                    child: GestureDetector(
                      onTap: _scanBarcode,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: tileHeight + 40,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isScanHovered
                              ? Colors.grey.shade200
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: _isScanHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/scan.png',
                              height: logoSize,
                              width: logoSize,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Scan Barcode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Input Manually
                Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isManualHovered = true),
                    onExit: (_) => setState(() => _isManualHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Add manual input logic
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        height: tileHeight + 40,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isManualHovered
                              ? Colors.grey.shade200
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: _isManualHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/keyboard.png',
                              height: logoSize,
                              width: logoSize,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Input Manually',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_scannedBarcode.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Scanned: $_scannedBarcode',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _resetScan,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Clear',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            const Text('Recent Records',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Dummy medicine records
            _buildRecordTile('Advil', '200mg', 'Apr 09, 2025'),
            _buildRecordTile('Excedrin', '250mg', 'Apr 08, 2025'),
            _buildRecordTile('Benadryl', '50mg', 'Apr 07, 2025'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(String name, String dosage, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(name),
        subtitle: Text('Dosage: $dosage'),
        trailing: Text(
          date,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
