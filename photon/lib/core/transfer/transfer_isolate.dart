import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import '../models/transfer_models.dart';

class TransferIsolate {
  static const int chunkSize = 64 * 1024; // 64KB

  static void entryPoint(SendPort mainSendPort) async {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    Socket? socket;
    bool isPaused = false;
    
    // Listen for commands
    await for (final message in workerReceivePort) {
      if (message is TransferCommand) {
        switch (message.type) {
          case CommandType.send:
             if (message.host != null && message.filePaths.isNotEmpty) {
               try {
                 mainSendPort.send(const TransferState(status: TransferStatus.connecting));
                 socket = await Socket.connect(message.host, message.port);
                 // Configure socket
                 socket.setOption(SocketOption.tcpNoDelay, true); // Low latency

                 mainSendPort.send(const TransferState(status: TransferStatus.transferring));
                 await _sendFiles(message.filePaths, socket, mainSendPort, () => isPaused);
                 
                 await socket.close();
                 mainSendPort.send(const TransferState(status: TransferStatus.completed, progress: 1.0));
               } catch (e) {
                 mainSendPort.send(TransferState(status: TransferStatus.error, errorMessage: e.toString()));
               }
             }
             break;
          case CommandType.pause:
             isPaused = true;
             mainSendPort.send(const TransferState(status: TransferStatus.paused));
             break;
          case CommandType.resume:
             isPaused = false;
             mainSendPort.send(const TransferState(status: TransferStatus.transferring));
             break;
          case CommandType.cancel:
             socket?.destroy();
             mainSendPort.send(const TransferState(status: TransferStatus.idle));
             break;
        }
      }
    }
  }

  static Future<void> _sendFiles(
    List<String> paths, 
    Socket socket, 
    SendPort updatePort,
    bool Function() isPaused,
  ) async {
    int totalBytesSent = 0;
    int totalBytesExpected = 0;
    
    // Calculate total size
    final files = <File>[];
    for (var path in paths) {
      final f = File(path);
      if (await f.exists()) {
        files.add(f);
        totalBytesExpected += await f.length();
      }
    }

    // Protocol: Send File Count (4 bytes)
    final countBytes = ByteData(4)..setInt32(0, files.length);
    socket.add(countBytes.buffer.asUint8List());

    final buffer = Uint8List(chunkSize);
    DateTime lastUpdate = DateTime.now();

    for (var file in files) {
      final fileName = file.uri.pathSegments.last;
      final fileSize = await file.length();

      // Protocol: Name Length (4 bytes) -> Name (N bytes) -> Size (8 bytes)
      final nameBytes = utf8.encode(fileName);
      final metaHeader = ByteData(4 + nameBytes.length + 8);
      metaHeader.setInt32(0, nameBytes.length);
      for (int i = 0; i < nameBytes.length; i++) {
        metaHeader.setUint8(4 + i, nameBytes[i]);
      }
      metaHeader.setInt64(4 + nameBytes.length, fileSize);
      socket.add(metaHeader.buffer.asUint8List());

      // Send Content
      final raf = await file.open();
      int bytesRead = 0;
      
      while ((bytesRead = await raf.readInto(buffer)) > 0) {
        // Pausing logic
        while (isPaused()) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        socket.add(buffer.sublist(0, bytesRead));
        totalBytesSent += bytesRead;

        // Backpressure
        // If we write too fast, socket buffer fills. 
        // socket.drain is one way, but for TCP in Dart, just checking (socket as dynamic).done is minimal.
        // Better: periodic flush if needed, but Dart's Socket handles a lot.
        // We can await socket.flush() at the end or if we suspect buffering.
        // For max speed, we don't flush every chunk.
        
        // Throttled Progress Updates (30Hz approx)
        final now = DateTime.now();
        if (now.difference(lastUpdate).inMilliseconds > 32) {
           final progress = totalBytesExpected > 0 ? totalBytesSent / totalBytesExpected : 0.0;
           // Estimate speed? (Simple implementation needed)
           updatePort.send(TransferState(
             status: TransferStatus.transferring,
             progress: progress,
             totalBytesSent: totalBytesSent,
             totalBytesExpected: totalBytesExpected,
             currentFileName: fileName,
           ));
           lastUpdate = now;
        }
      }
      await raf.close();
    }
  }
}
