import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';

import 'reservas_confirmadas.dart';
import 'favoritos.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _avatarBase64;
  String? _userName = "Usuario VIP";
  String? _userLocation = "Sin ubicación";
  bool _loading = true;

  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final snap = await _db.child("usuarios/${user.uid}/perfil").get();

    if (snap.exists && snap.value is Map) {
      final data = snap.value as Map;

      setState(() {
        _avatarBase64 = data["avatarBase64"];
        _userName = data["nombre"] ?? "Usuario VIP";
        _userLocation = data["ubicacion"] ?? "Sin ubicación";
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  // Cambiar foto: file_picker (web, PC, móvil)
  Future<void> _changeAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;

    final picked = result.files.single;
    if (picked.bytes == null) return;

    final bytes = picked.bytes!; // Uint8List
    final base64Image = "data:image/png;base64,${base64Encode(bytes)}";

    final user = _auth.currentUser;
    if (user == null) return;

    await _db.child("usuarios/${user.uid}/perfil").update({
      "avatarBase64": base64Image,
    });

    setState(() {
      _avatarBase64 = base64Image;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Foto de perfil actualizada.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? avatarBytes;

    if (_avatarBase64 != null && _avatarBase64!.contains(",")) {
      try {
        avatarBytes = base64Decode(_avatarBase64!.split(",")[1]);
      } catch (_) {
        avatarBytes = null;
      }
    }

    final user = _auth.currentUser;
    final email = user?.email ?? "Sin correo";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF15192B),
              Color(0xFF1F2335),
              Color(0xFF232A3F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Column(
              children: [
                // HEADER
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Información personal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF50E3C2),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // AVATAR + NOMBRE
                          GestureDetector(
                            onTap: _changeAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF50E3C2),
                                    Color(0xFF5DA9F6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: const Color(0xFF15192B),
                                backgroundImage: avatarBytes != null
                                    ? MemoryImage(avatarBytes)
                                    : null,
                                child: avatarBytes == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 48,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Toca la imagen para cambiarla",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _userName ?? "Usuario VIP",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _userLocation ?? "Sin ubicación",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // CARD DE DATOS
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Datos del usuario",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alternate_email_rounded,
                                      size: 18,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.badge_rounded,
                                      size: 18,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _userName ?? "",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.place_rounded,
                                      size: 18,
                                      color: Colors.white54,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _userLocation ?? "",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          // OPCIONES / ACCIONES
                          _PerfilTile(
                            icon: Icons.event_available_rounded,
                            title: "Reservaciones confirmadas",
                            subtitle: "Consulta tus próximas visitas al club",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ReservasConfirmadasPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _PerfilTile(
                            icon: Icons.favorite_border_rounded,
                            title: "Favoritos",
                            subtitle:
                                "Accede rápido a tus áreas y servicios preferidos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FavoritosPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _PerfilTile(
                            icon: Icons.settings_rounded,
                            title: "Ajustes",
                            subtitle:
                                "Próximamente: edición de datos y preferencias",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Pantalla de ajustes pendiente.",
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PerfilTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
