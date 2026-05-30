import '../../core/api_client.dart';
import 'session_model.dart'; // SessionQR, HostSessionResponse

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

  Future<HostSessionResponse> getHostSession() async {
    final data = await api.get("/session/host");
    return HostSessionResponse.fromJson(data);
  }
}