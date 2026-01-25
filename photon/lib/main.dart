import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/transfer/transfer_manager.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const PhotonApp());
}

class PhotonApp extends StatelessWidget {
  const PhotonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransferManager()..init()),
      ],
      child: MaterialApp(
        title: 'Photon',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.dark, // Force dark for premium feel initially
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    
    return base.copyWith(
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F7),
      primaryColor: const Color(0xFF00E5FF),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF00E5FF),
        secondary: const Color(0xFF2979FF),
        surface: isDark ? const Color(0xFF1A1D24) : Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
    );
  }
}
