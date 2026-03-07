import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/theme.dart';
import 'ui/dashboard_screen.dart';
import 'ui/beta_gate_screen.dart';
import 'logic/wallet_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const LanaApp(),
    ),
  );
}

class LanaApp extends StatefulWidget {
  const LanaApp({super.key});

  @override
  State<LanaApp> createState() => _LanaAppState();
}

class _LanaAppState extends State<LanaApp> {
  bool _betaAccessGranted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lana App',
      debugShowCheckedModeBanner: false,
      theme: LanaTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          LanaTheme.darkTheme.textTheme,
        ),
      ),
      home: _betaAccessGranted
          ? const DashboardScreen()
          : BetaGateScreen(
              child: const DashboardScreen(),
              onCodeValidated: (code) {
                // Update the user profile
                final provider = context.read<WalletProvider>();
                provider.user = provider.user.copyWith(
                  betaAccessGranted: true,
                  betaCodeUsed: code,
                  isFoundingMember: true,
                );
                setState(() => _betaAccessGranted = true);
              },
            ),
    );
  }
}
