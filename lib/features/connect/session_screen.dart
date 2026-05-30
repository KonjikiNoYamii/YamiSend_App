import 'dart:convert';
import 'package:flutter/material.dart';

import 'session_service.dart';
import 'session_model.dart';
import '../../core/api_client.dart';
import '../files/file_service.dart';

class SessionScreen extends StatefulWidget {
  final String baseUrl;
  final Function(FileService service) onConnected;

  const SessionScreen({
    super.key,
    required this.baseUrl,
    required this.onConnected,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late SessionService service;
  SessionQR? session;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    service = SessionService(ApiClient(widget.baseUrl));
    create();
  }

  Future<void> create() async {
    try {
      session = await service.createSession();
    } catch (e) {
      session = null;
    }

    setState(() => loading = false);
  }

  void connectSession() {
    if (session == null) return;

    final api = ApiClient(widget.baseUrl);

    widget.onConnected(
      FileService(
        api,
        sessionId: session!.sessionId,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Pair Device")),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : session == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error, color: theme.colorScheme.error),
                      const SizedBox(height: 8),
                      const Text("Gagal membuat session"),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            create();
                          });
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Scan QR untuk connect",
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(height: 20),

                      // QR IMAGE
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Image.memory(
                          base64Decode(session!.qr.split(',').last),
                          width: 220,
                          height: 220,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Session ID: ${session!.sessionId}",
                        style: theme.textTheme.bodySmall,
                      ),

                      const SizedBox(height: 20),

                      FilledButton.icon(
                        icon: const Icon(Icons.link),
                        label: const Text("Continue"),
                        onPressed: connectSession,
                      ),
                    ],
                  ),
      ),
    );
  }
}