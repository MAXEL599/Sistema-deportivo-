import 'package:flutter/material.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Favoritos",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: ListView(
          children: const [
            SizedBox(height: 16),

            // Sección Lugares
            Text(
              "Lugares",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Cancha de tenis",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Piscina",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Gimnasio",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),

            SizedBox(height: 32),

            // Sección Extras
            Text(
              "Extras",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Raquetas",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Toalla",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Cinturón de levantamiento",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
