import 'package:flutter/material.dart';

// importa tus pantallas
import 'login.dart';
import 'register.dart';
import 'home.dart';

void main() {
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

      // Ruta inicial
      initialRoute: '/login',

      // Rutas nombradas principales
      routes: {
        '/login': (context) => const LoginPageVIP(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePageVIP(),
      },
    );
  }
}
