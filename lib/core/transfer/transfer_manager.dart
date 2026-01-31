import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../models/transfer_models.dart';
import 'transfer_isolate.dart';

class TransferManager extends ChangeNotifier {
  Isolate? _isolate;
  SendPort? _sendPort;
  
  TransferState _state = const TransferState();
  TransferState get state => _state;

  final StreamController<TransferState> _stateController = StreamController.broadcast();
  Stream<TransferState> get stateStream => _stateController.stream;

  Future<void> init() async {
    final receivePort = ReceivePort();
    _isolate = await Isolate.spawn(TransferIsolate.entryPoint, receivePort.sendPort);
    
    final events = receivePort.asBroadcastStream();
    _sendPort = await events.first as SendPort;

    events.listen((message) {
      if (message is TransferState) {
        _state = message;
        _stateController.add(message);
        notifyListeners();
      }
    });
  }

  void startTransfer(List<String> filePaths, String host, {int port = 4040}) {
    if (_sendPort == null) {
      _logger("Isolate not initialized");
      return;
    }
    _sendPort!.send(TransferCommand(
      type: CommandType.send,
      filePaths: filePaths,
      host: host,
      port: port,
    ));
  }

  void pause() => _sendPort?.send(const TransferCommand(type: CommandType.pause));
  void resume() => _sendPort?.send(const TransferCommand(type: CommandType.resume));
  void cancel() => _sendPort?.send(const TransferCommand(type: CommandType.cancel));

  void disposeManager() {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _stateController.close();
  }

  void _logger(String msg) {
    if (kDebugMode) print('[TransferManager] $msg');
  }
}
