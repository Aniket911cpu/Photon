import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/connection/connection_payload.dart';
import 'package:wifi_iot/wifi_iot.dart';


class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this, 
       duration: const Duration(seconds: 2)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
     if (_isConnecting) return;
     
     final List<Barcode> barcodes = capture.barcodes;
     for (final barcode in barcodes) {
       final raw = barcode.rawValue;
       if (raw != null) {
          final payload = ConnectionPayload.fromQRString(raw);
          if (payload != null) {
             _connect(payload);
             break;
          }
       }
     }
  }

  Future<void> _connect(ConnectionPayload payload) async {
    setState(() => _isConnecting = true);
    
    // Connect to Hotspot
    // NOTE: Android 10+ throttling might affect this.
    // Usually we need permission location/nearby.
    try {
      final connected = await WiFiForIoTPlugin.connect(
        payload.ssid,
        password: payload.password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );

      if (connected) {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("WiFi Connected! Handshaking...")),
         );
         // Handshake / Navigation
         // Provider.of<TransferManager>(context).connect(payload.ip, payload.port);
         Navigator.pop(context, payload); // Return payload for next step
      } else {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("WiFi Connection Failed. Try manual.")),
         );
         setState(() => _isConnecting = false);
      }
    } catch (e) {
       debugPrint(e.toString());
       if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
             onDetect: _onDetect,
          ),
          CustomPaint(
            painter: _ScannerOverlayPainter(_animationController),
            child: Container(),
          ),
          if (_isConnecting)
             const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   CircularProgressIndicator(),
                   SizedBox(height: 20),
                   Text("Connecting to Sender...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                 ],
               ),
             ),
           Positioned(
             top: 40,
             left: 20,
             child: IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.white),
               onPressed: () => Navigator.pop(context),
             ),
           )
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  _ScannerOverlayPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw darkened background
    // We want a clear window in the center.
    // Simplified: Just 2 rectangles top/bottom? Or proper Path.
    
    final width = size.width;
    final height = size.height;
    final scanW = width * 0.7;
    final scanH = width * 0.7;
    final left = (width - scanW) / 2;
    final top = (height - scanH) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRect(Rect.fromLTWH(left, top, scanW, scanH));
      
    // FillType.evenOdd makes the inner rect transparent
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Laser Line
    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = LinearGradient(colors: [
         Colors.cyanAccent.withValues(alpha: 0.0),
         Colors.cyanAccent,
         Colors.cyanAccent.withValues(alpha: 0.0),
      ]).createShader(Rect.fromLTWH(left, top, scanW, scanH));

    final animY = top + (scanH * animation.value);
    
    canvas.drawLine(Offset(left, animY), Offset(left + scanW, animY), linePaint);
    
    // Borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    // Draw corners logic omitted for brevity, just a rect for now
    canvas.drawRect(Rect.fromLTWH(left, top, scanW, scanH), borderPaint..color = Colors.white30);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
