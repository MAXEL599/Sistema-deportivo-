import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(2),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // gris muy claro
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Registro.",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Un buen día para registrarse",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Nombre
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Nombre",
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Correo
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Correo electrónico",
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirmar contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirmar contraseña",
                      filled: true,
                      fillColor: const Color(0xFFF4F5F7),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E4650),
                      ),
                      onPressed: () {
                        // aquí luego meteremos la lógica de registro
                      },
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "No te preocupes, no enviaremos spam.",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Términos y Condiciones",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2860D0),
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
