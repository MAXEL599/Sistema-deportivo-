import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  bool _cargando = true;
  Map<String, int> _areaCounts = {};
  Map<String, int> _extrasCounts = {};

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _cargando = false;
      });
      return;
    }

    try {
      final snap =
          await _db.child('usuarios/${user.uid}/reservas_detalle').get();

      final Map<String, int> areaCounts = {};
      final Map<String, int> extrasCounts = {};

      if (snap.value != null) {
        final data = Map<dynamic, dynamic>.from(snap.value as Map);

        data.forEach((key, value) {
          final m = Map<dynamic, dynamic>.from(value as Map);

          // Contar áreas / canchas
          final area = (m['area'] ?? '').toString().trim();
          if (area.isNotEmpty) {
            areaCounts[area] = (areaCounts[area] ?? 0) + 1;
          }

          // Contar extras (ignorando extrasTotal)
          if (m['extras'] != null) {
            final extrasMap = Map<dynamic, dynamic>.from(m['extras'] as Map);
            extrasMap.forEach((k, v) {
              final keyStr = k.toString();
              if (keyStr == 'extrasTotal') return;

              // Si v es numérico, sumamos la cantidad; si es bool, sumamos 1
              int incremento = 1;
              if (v is num) {
                incremento = v.toInt();
              }
              final extraNombre = keyStr;
              extrasCounts[extraNombre] =
                  (extrasCounts[extraNombre] ?? 0) + incremento;
            });
          }
        });
      }

      setState(() {
        _areaCounts = areaCounts;
        _extrasCounts = extrasCounts;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error al cargar favoritos: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  /// Regresa una lista ordenada (descendente) de entries (nombre, conteo)
  List<MapEntry<String, int>> _topEntries(Map<String, int> source,
      {int maxItems = 5}) {
    final entries = source.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.length > maxItems) {
      return entries.sublist(0, maxItems);
    }
    return entries;
  }

  String _formatLabel(String raw) {
    if (raw.isEmpty) return raw;
    final pretty = raw.replaceAll('_', ' ');
    return pretty[0].toUpperCase() + pretty.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final topAreas = _topEntries(_areaCounts, maxItems: 6);
    final topExtras = _topEntries(_extrasCounts, maxItems: 6);

    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101522),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Favoritos",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF101522),
              Color(0xFF171D2F),
              Color(0xFF202640),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : (_areaCounts.isEmpty && _extrasCounts.isEmpty)
                  ? const Center(
                      child: Text(
                        "Aún no hay suficientes datos para mostrar tus favoritos.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Card de resumen
                          _buildResumenCard(topAreas, topExtras),

                          const SizedBox(height: 24),

                          // Sección Lugares
                          const Text(
                            "Lugares favoritos",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildChipsList(topAreas, icon: Icons.sports_tennis),

                          const SizedBox(height: 28),

                          // Sección Extras
                          const Text(
                            "Extras favoritos",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildChipsList(topExtras, icon: Icons.add_circle),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildResumenCard(
    List<MapEntry<String, int>> topAreas,
    List<MapEntry<String, int>> topExtras,
  ) {
    final areaTopName =
        topAreas.isNotEmpty ? _formatLabel(topAreas.first.key) : "–";
    final areaTopCount = topAreas.isNotEmpty ? topAreas.first.value : 0;

    final extraTopName =
        topExtras.isNotEmpty ? _formatLabel(topExtras.first.key) : "–";
    final extraTopCount = topExtras.isNotEmpty ? topExtras.first.value : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B3A63), Color(0xFF3C4A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen personal",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Esta vista se actualiza según tus reservas, mostrando lo que más usas.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  title: "Lugar más usado",
                  value: areaTopName,
                  count: areaTopCount,
                  icon: Icons.place_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  title: "Extra más usado",
                  value: extraTopName,
                  count: extraTopCount,
                  icon: Icons.star_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF50E3C2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (count > 0)
                  Text(
                    "$count usos",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsList(
    List<MapEntry<String, int>> items, {
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return Text(
        "Aún no hay datos suficientes.",
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((entry) {
        final label = _formatLabel(entry.key);
        final count = entry.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF50E3C2)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "x$count",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
