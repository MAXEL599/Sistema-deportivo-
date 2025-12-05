import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase options generado por FlutterFire CLI
import 'firebase_options.dart';

// Pantallas principales
import 'login.dart';
import 'register.dart';
import 'home.dart';
import 'perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Centro Deportivo VIP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPageVIP(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePageVIP(),
        // 👇 ahora PerfilPage ya no lleva parámetros
        '/perfil': (context) => const PerfilPage(),
      },
    );
  }
}
