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
        primaryColor: const Color(0xFFE25213),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE25213),
          primary: const Color(0xFFE25213),
        ),
        useMaterial3: true,
      ),
      home: const VistaLoginReal(),
    );
  }
}