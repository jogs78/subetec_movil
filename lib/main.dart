import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MiAppSubeTec());
}

class MiAppSubeTec extends StatelessWidget {
  const MiAppSubeTec({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubeTec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          primary: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const VistaLoginReal(),
    );
  }
}