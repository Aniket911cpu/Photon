import 'dart:convert';

class ConnectionPayload {
  final String ssid;
  final String password;
  final String ip;
  final int port;

  ConnectionPayload({
    required this.ssid,
    required this.password,
    required this.ip,
    required this.port,
  });

  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'password': password,
        'ip': ip,
        'port': port,
      };

  factory ConnectionPayload.fromJson(Map<String, dynamic> json) {
    return ConnectionPayload(
      ssid: json['ssid'] as String,
      password: json['password'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int,
    );
  }

  String toQRString() => jsonEncode(toJson());
  
  static ConnectionPayload? fromQRString(String qr) {
    try {
      return ConnectionPayload.fromJson(jsonDecode(qr));
    } catch (_) {
      return null;
    }
  }
}
