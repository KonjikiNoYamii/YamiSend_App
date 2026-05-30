import 'api_client.dart';
import '../features/files/file_service.dart';

class Connection {
  final String baseUrl;
  final String? sessionId;
  final FileService fileService;

  Connection._(
    this.baseUrl,
    this.sessionId,
    this.fileService,
  );

  /// MODE NORMAL (manual IP / QR base connect)
  static Connection create(String baseUrl) {
    final api = ApiClient(baseUrl);

    return Connection._(
      baseUrl,
      null,
      FileService(api, sessionId: ''),
    );
  }

  /// MODE SESSION (PAIRING SYSTEM)
  static Connection createSession(
    String baseUrl,
    String sessionId,
  ) {
    final api = ApiClient(baseUrl);

    return Connection._(
      baseUrl,
      sessionId,
      FileService(
        api,
        sessionId: sessionId,
      ),
    );
  }
}