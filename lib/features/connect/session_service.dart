import '../../core/api_client.dart';
import 'session_model.dart';

class SessionService {
  final ApiClient api;

  SessionService(this.api);

  Future<SessionQR> createSession() async {
    final data = await api.get("/session/create");
    return SessionQR.fromJson(data);
  }

  Future<void> joinSession(String sessionId) async {
    await api.get("/session/$sessionId/join");
  }
}