import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';

class DispatchQrScannerScreen extends StatefulWidget {
  final void Function(Map<String, dynamic>?) onQrScanned;

  const DispatchQrScannerScreen({super.key, required this.onQrScanned});

  @override
  State<DispatchQrScannerScreen> createState() =>
      _DispatchQrScannerScreenState();
}

class _DispatchQrScannerScreenState extends State<DispatchQrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      appBar: AppBars(
        title: const TitleText(title: 'Scan QR Code'),
        leading: CustomBackButton(
          onPressed: () => context.go(RouteNames.dispatchAdd),
        ),
      ),
      body: Consumer<DispatchProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // ===== Main Column for positioning =====
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // center horizontally
                children: [
                  const Spacer(flex: 2), // top spacer
                  // ===== QR Scanner Container =====
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white70, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: _scannerController,
                          onDetect: (barcodeCapture) {
                            _handleBarcode(barcodeCapture, provider);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== Instruction Text =====
                  const Text(
                    'Align the QR inside the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white38,
                    size: 28,
                  ),

                  const Spacer(flex: 3), // bottom spacer
                ],
              ),

              // ===== Overlay: Scanning loader =====
              if (provider.isScanning)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                ),

              // ===== Overlay: Error Message =====
              if (provider.qrScanError != null && !provider.isScanning)
                Positioned(
                  bottom: 50,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.qrScanError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleBarcode(
    BarcodeCapture barcodeCapture,
    DispatchProvider provider,
  ) async {
    if (_hasScanned) return;

    final code = barcodeCapture.barcodes.isNotEmpty
        ? barcodeCapture.barcodes.first.rawValue
        : null;

    if (code == null || code.isEmpty) return;

    setState(() => _hasScanned = true);
    log("🔍 QR Detected: $code");

    try {
      await provider.fetchQrDetails(code);

      if (provider.qrScanError == null) {
        // ✅ Successfully fetched QR data
        widget.onQrScanned(provider.qrScan);
        if (mounted) Navigator.pop(context);
      } else {
        // ❌ Error from provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.qrScanError ?? 'Invalid QR Code'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _hasScanned = false);
        _scannerController.start();
      }
    } catch (e) {
      log('❌ Error fetching QR details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch QR details'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _hasScanned = false);
      _scannerController.start();
    }
  }
}
