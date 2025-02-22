import 'package:flutter/material.dart';
import 'package:qrscanner/qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      home: QRScanner(),
    );
  }
}
