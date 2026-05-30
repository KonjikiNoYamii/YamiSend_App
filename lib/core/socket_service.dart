import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  WebSocketChannel? _channel;

  void connect(String baseUrl, String sessionId) {
    final host = Uri.parse(baseUrl).host;
    final uri = Uri.parse('ws://$host:3000?sessionId=$sessionId');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        _onEvent(data);
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void _onEvent(Map<String, dynamic> data) {
    final event = data['event'] as String?;
    final payload = data['data'];

    switch (event) {
      case 'file_uploaded':
        _onFileUploaded?.call(payload);
        break;
    }
  }

  void Function(Map<String, dynamic> data)? _onFileUploaded;

  set onFileUploaded(void Function(Map<String, dynamic> data)? callback) {
    _onFileUploaded = callback;
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
