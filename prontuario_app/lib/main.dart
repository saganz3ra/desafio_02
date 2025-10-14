import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prontuario_app/ui/prontuario_list_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProntuarioApp());
}

class ProntuarioApp extends StatelessWidget {
  const ProntuarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prontuário App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const ProntuarioListScreen(),
    );
  }
}
