import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/api_client.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String baseUrl, String? sessionId) onConnected;

  const QRScannerScreen({super.key, required this.onConnected});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final controller = MobileScannerController();
  String? scannedUrl;
  bool connecting = false;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

Future<void> connectToUrl(String url) async {
  setState(() {
    connecting = true;
    error = null;
  });

  try {
    final uri = Uri.parse(url);
    final baseUrl = "${uri.scheme}://${uri.host}:${uri.port}";
    String? sessionId;

    if (uri.pathSegments.isNotEmpty) {
      sessionId = uri.pathSegments.last;
      final api = ApiClient(baseUrl);
      await api.get("/session/$sessionId/join");
    }

    if (!mounted) return;

    widget.onConnected(baseUrl, sessionId);
    Navigator.pop(context);

  } catch (e) {
    setState(() {
      connecting = false;
      error = "Gagal join session";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Server"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: "Flash",
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final code = capture.barcodes.firstOrNull?.rawValue;
              if (code == null || scannedUrl != null || connecting) return;

              scannedUrl = code;
              connectToUrl(code);
            },
          ),

          if (scannedUrl != null || connecting || error != null)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (connecting) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text("Menghubungkan..."),
                        ] else if (error != null) ...[
                          Icon(Icons.error, color: theme.colorScheme.error, size: 48),
                          const SizedBox(height: 12),
                          Text(error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                scannedUrl = null;
                                connecting = false;
                                error = null;
                              });
                            },
                            child: const Text("Scan Lagi"),
                          ),
                        ] else ...[
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 12),
                          const Text("QR Terdeteksi!"),
                          const SizedBox(height: 4),
                          Text(
                            scannedUrl ?? "",
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Arahkan kamera ke QR Code server",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
