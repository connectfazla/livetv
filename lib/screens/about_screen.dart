import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Tv',
              style: GoogleFonts.russoOne(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app is for FIFA World Cup streaming.\n\nCreated by darkk.',
              style: TextStyle(color: Color(0xFFB8CCD6), fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'Note: For geo-locked channels, use a VPN to access streams from restricted regions.',
              style: TextStyle(color: Color(0xFF8FA6B2), fontSize: 14, height: 1.5),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
