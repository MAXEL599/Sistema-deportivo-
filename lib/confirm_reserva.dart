import 'package:flutter/material.dart';
import 'home.dart';

class ConfirmReservaPage extends StatelessWidget {
  final String areaName;    // Ej: "Piscina"
  final String userName;    // Ej: "Carlos"
  final DateTime date;      // Día elegido
  final String timeSlot;    // Ej: "7:00 am a 8:00 am"
  final int basePrice;      // Precio base
  final int extrasTotal;    // Total extras

  const ConfirmReservaPage({
    super.key,
    required this.areaName,
    required this.userName,
    required this.date,
    required this.timeSlot,
    required this.basePrice,
    required this.extrasTotal,
  });

  String _fechaEnEspanol(DateTime d) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final mes = meses[d.month - 1];
    return '${d.day} de $mes';
  }

  @override
  Widget build(BuildContext context) {
    final String descripcionReserva = '$areaName de $timeSlot';
    final String textoFecha = 'El día ${_fechaEnEspanol(date)}';
    final int total = basePrice + extrasTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Avatar + nombre
              Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFE0E4EA),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF3E4650),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "Confirmación de la\nreservación",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Usted está a punto\nde aceptar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '"$descripcionReserva"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                textoFecha,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Total a pagar: $total MXN',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E4650),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // regresa a extras
                        },
                        child: const Text(
                          "CANCELAR",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E4650),
                        ),
                        onPressed: () {
                          // Ir al Home y limpiar el historial de pantallas
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePageVIP(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "CONFIRMAR",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
