import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


import 'file_picker_screen.dart';
import 'qr_scanner_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photon"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionCard(
              title: "Send",
              icon: Icons.upload_rounded,
              color: const Color(0xFF00E5FF),
              onTap: () {
                // SEND FLOW: Home -> File Picker -> QR Generator -> Transfer
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const FilePickerScreen(),
                ));
              },
            ),
            const SizedBox(height: 20),
            _ActionCard(
              title: "Receive",
              icon: Icons.download_rounded,
              color: const Color(0xFF2979FF),
              onTap: () async {
                 // RECEIVE FLOW: Home -> QR Scanner -> Transfer
                 final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const QrScannerScreen(),
                ));

                if (result != null && context.mounted) {
                   Navigator.of(context).push(MaterialPageRoute(
                     builder: (_) => const TransferScreen(isSender: false),
                   ));
                }
              },
            ),
          ],
        ).animate().fade(duration: 500.ms).slideY(begin: 0.1),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
