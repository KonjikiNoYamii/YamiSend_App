class SessionQR {
  final String sessionId;
  final String url;
  final String qr;

  SessionQR({
    required this.sessionId,
    required this.url,
    required this.qr,
  });

  factory SessionQR.fromJson(Map<String, dynamic> json) {
    return SessionQR(
      sessionId: json['sessionId'],
      url: json['url'],
      qr: json['qr'],
    );
  }
}