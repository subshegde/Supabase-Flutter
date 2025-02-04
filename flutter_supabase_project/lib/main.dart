import 'package:flutter/material.dart';
import 'package:flutter_supabase_project/pages/auth/services/auth_gate.dart';
import 'package:flutter_supabase_project/utils/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: projectUrl, anonKey: apiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase',

      home: AuthGate(),
    );
  }
}
