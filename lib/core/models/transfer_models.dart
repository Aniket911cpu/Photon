// Models don't strictly need isolate unless we pass ports, but if needed:
// import 'dart:isolate';
// actually we don't need dart:isolate imports for pure models unless we pass ports.

enum TransferStatus {
  idle,
  connecting,
  transferring,
  paused,
  completed,
  error,
}

enum CommandType {
  send,
  cancel,
  pause,
  resume,
}

class TransferCommand {
  final CommandType type;
  final List<String> filePaths;
  final String? host;
  final int port;

  const TransferCommand({
    required this.type,
    this.filePaths = const [],
    this.host,
    this.port = 4040,
  });
}

class TransferState {
  final TransferStatus status;
  final double progress; // 0.0 to 1.0
  final double speedInBytesPerSec;
  final String currentFileName;
  final int totalBytesSent;
  final int totalBytesExpected;
  final String? errorMessage;

  const TransferState({
    this.status = TransferStatus.idle,
    this.progress = 0.0,
    this.speedInBytesPerSec = 0.0,
    this.currentFileName = '',
    this.totalBytesSent = 0,
    this.totalBytesExpected = 0,
    this.errorMessage,
  });

  TransferState copyWith({
    TransferStatus? status,
    double? progress,
    double? speedInBytesPerSec,
    String? currentFileName,
    int? totalBytesSent,
    int? totalBytesExpected,
    String? errorMessage,
  }) {
    return TransferState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speedInBytesPerSec: speedInBytesPerSec ?? this.speedInBytesPerSec,
      currentFileName: currentFileName ?? this.currentFileName,
      totalBytesSent: totalBytesSent ?? this.totalBytesSent,
      totalBytesExpected: totalBytesExpected ?? this.totalBytesExpected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
