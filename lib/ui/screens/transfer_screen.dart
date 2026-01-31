import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/models/transfer_models.dart';
import '../../core/transfer/transfer_manager.dart';
import '../widgets/ripple_animation.dart';

class TransferScreen extends StatefulWidget {
  final bool isSender;
  const TransferScreen({super.key, required this.isSender});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<TransferManager>(context);
    final status = manager.state.status;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark, // Deep background
      appBar: AppBar(
        title: Text(widget.isSender ? "Sending..." : "Receiving..."),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _buildBody(status, manager),
      ),
      floatingActionButton: (widget.isSender && status == TransferStatus.idle) 
        ? FloatingActionButton(
            onPressed: () => _pickAndSend(context),
            child: const Icon(Icons.add),
          )
        : null,
    );
  }

  Widget _buildBody(TransferStatus status, TransferManager manager) {
    switch (status) {
      case TransferStatus.idle:
      case TransferStatus.connecting:
        return RippleAnimation(
          color: Theme.of(context).primaryColor,
          size: 300,
          child: const Icon(Icons.wifi_tethering, size: 48, color: Colors.white),
        );
      case TransferStatus.transferring:
      case TransferStatus.paused:
        return _buildProgress(manager.state);
      case TransferStatus.completed:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.greenAccent),
            SizedBox(height: 16),
            Text("Transfer Complete", style: TextStyle(color: Colors.white, fontSize: 24)),
          ],
        );
      case TransferStatus.error:
        return Text("Error: ${manager.state.errorMessage}", style: const TextStyle(color: Colors.red));
    }
  }

  Widget _buildProgress(TransferState state) {
    return RepaintBoundary(
      child: CircularPercentIndicator(
        radius: 120.0,
        lineWidth: 12.0,
        percent: state.progress.clamp(0.0, 1.0),
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              "${(state.progress * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
             ),
             const SizedBox(height: 8),
             Text(
               state.currentFileName,
               overflow: TextOverflow.ellipsis,
               maxLines: 1,
               style: const TextStyle(color: Colors.white70),
             )
          ],
        ),
        progressColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white10,
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animateFromLastPercent: true, 
      ),
    );
  }

  Future<void> _pickAndSend(BuildContext context) async {
    if (await _requestPermissions()) {
      if (!context.mounted) return;
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null && context.mounted) {
        final paths = result.paths.whereType<String>().toList();
        Provider.of<TransferManager>(context, listen: false)
             .startTransfer(paths, '127.0.0.1');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permissions required to share files.")),
        );
      }
    }
  }

  Future<bool> _requestPermissions() async {
    // Basic storage for MVP
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}
