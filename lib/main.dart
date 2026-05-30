import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/connection.dart';
import 'core/socket_service.dart';

import 'features/files/file_list_widget.dart';
import 'features/connect/qr_scanner_screen.dart';
import 'features/connect/session_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YamiSend",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ipController = TextEditingController();
  final _refreshNotifier = ValueNotifier(0);
  final _socket = SocketService();

  bool connecting = false;
  String? connectionError;

  Connection? connection;

  // =========================
  // MANUAL CONNECT
  // =========================
  void connectManually() async {
    final ip = ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      connecting = true;
      connectionError = null;
    });

    try {
      final baseUrl = "http://$ip:3000";
      final api = ApiClient(baseUrl);
      final sessionService = SessionService(api);

      await api.get("/ping");

      final host = await sessionService.getHostSession();
      await sessionService.joinSession(host.sessionId);

      if (!mounted) return;

      _socket.connect(baseUrl, host.sessionId);
      _socket.onFileUploaded = (_) => _refreshNotifier.value++;

      setState(() {
        connection = Connection.createSession(baseUrl, host.sessionId);
        connecting = false;
        connectionError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        connecting = false;
        connectionError = "Tidak dapat terhubung ke server";
      });
    }
  }

  // =========================
  // DISCONNECT
  // =========================
  void disconnect() {
    _socket.disconnect();
    setState(() {
      connection = null;
      connectionError = null;
    });
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("YamiSend"),
        centerTitle: true,
        actions: [
          if (connection != null)
            IconButton(
              icon: const Icon(Icons.link_off),
              tooltip: "Disconnect",
              onPressed: disconnect,
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // CONNECTION PANEL
            // =========================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dns, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Server Connection",
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (connection != null)
                          const Chip(
                            label: Text("Connected"),
                            avatar: Icon(Icons.check_circle, size: 16),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: ipController,
                      enabled: connection == null,
                      decoration: const InputDecoration(
                        labelText: "Server IP",
                        hintText: "192.168.1.7",
                        prefixIcon: Icon(Icons.language),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (connectionError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        connectionError!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // =========================
                    // BUTTONS
                    // =========================
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: connection != null || connecting
                                  ? null
                                  : connectManually,
                              icon: connecting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.cable),
                              label: Text(
                                connecting
                                    ? "Connecting..."
                                    : connection != null
                                        ? "Connected"
                                        : "Connect",
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        SizedBox(
                          height: 44,
                          child: FilledButton.icon(
                            onPressed: connection != null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QRScannerScreen(
                                          onConnected: (url, sessionId) {
                                            if (sessionId != null) {
                                              _socket.connect(
                                                  url, sessionId);
                                              _socket.onFileUploaded = (_) =>
                                                  _refreshNotifier.value++;
                                            }

                                            setState(() {
                                              connection =
                                                  sessionId != null
                                                      ? Connection.createSession(
                                                          url, sessionId)
                                                      : Connection.create(url);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text("Scan"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // BODY
            // =========================
            Expanded(
              child: connection == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Belum terhubung ke server",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Gunakan IP atau QR Pairing",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FileListWidget(
                      service: connection!.fileService,
                      refreshNotifier: _refreshNotifier,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}