import 'package:flutter/material.dart';
import 'reserva_area.dart';

class HomePageVIP extends StatelessWidget {
  const HomePageVIP({super.key});

  @override
  Widget build(BuildContext context) {
    const userName = "Carlos"; // por ahora fijo; luego lo podemos leer del login

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3E4650),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          // luego conectamos cada opción
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Avatar + nombre
              const CircleAvatar(
                radius: 38,
                backgroundColor: Color(0xFFE0E4EA),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF3E4650),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Carlos",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Texto central
              const Text(
                "Hola Carlos, ¿qué deseas\nreservar hoy?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 40),

              // Botones 2x2
              Row(
                children: [
                  Expanded(
                    child: _ReservaButton(
                      text: "PISCINA",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservaAreaPage(
                              areaName: "Piscina",
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ReservaButton(
                      text: "CANCHA DE TENIS",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservaAreaPage(
                              areaName: "Cancha de tenis",
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ReservaButton(
                      text: "GIMNASIO",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservaAreaPage(
                              areaName: "Gimnasio",
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ReservaButton(
                      text: "FRONTON",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReservaAreaPage(
                              areaName: "Fronton",
                              userName: userName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReservaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ReservaButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E4650),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
