import 'package:flutter/material.dart';

class LoginPageVIP extends StatelessWidget {
  const LoginPageVIP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),

            // Título superior (sin imagen)
            const Text(
              "Club privado de deportes",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF2F2F2F),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            // CORREO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Correo o usuario",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F5F7),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONTRASEÑA
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Contraseña",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F5F7),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // LINKS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Color(0xFF2860D0), fontSize: 12),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "registrarse",
                    style: TextStyle(
                      color: Color(0xFF2860D0),
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BOTÓN LOGIN
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E4650),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  "LOG IN",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: const [
                Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR"),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 30),

            // BOTONES SOCIALES
            _SocialButton(
              text: "LOGIN WITH FACEBOOK",
              color: const Color(0xFF3A3F47),
              icon: Icons.facebook,
            ),
            const SizedBox(height: 12),
            _SocialButton(
              text: "LOGIN WITH TWITTER",
              color: const Color(0xFF6F7A88),
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 12),
            _SocialButton(
              text: "LOGIN WITH GOOGLE",
              color: const Color(0xFFD1D6DE),
              textColor: Colors.black,
              icon: Icons.g_mobiledata,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;

  const _SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
