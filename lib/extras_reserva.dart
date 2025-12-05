import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'confirm_reserva.dart';

class ExtrasReservaPage extends StatefulWidget {
  final String areaName;   // ej: Piscina
  final String userName;   // ej: Carlos
  final DateTime date;
  final String timeSlot;
  final int basePrice;

  const ExtrasReservaPage({
    super.key,
    required this.areaName,
    required this.userName,
    required this.date,
    required this.timeSlot,
    required this.basePrice,
  });

  @override
  State<ExtrasReservaPage> createState() => _ExtrasReservaPageState();
}

class _ExtrasReservaPageState extends State<ExtrasReservaPage> {
  late List<_ExtraItem> _extras;
  int _extrasTotal = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _extras = _extrasForArea(widget.areaName);
  }

  List<_ExtraItem> _extrasForArea(String area) {
    final up = area.toUpperCase();

    if (up.contains('PISCINA')) {
      return [
        _ExtraItem("Flotador", 15, Icons.water_rounded),
        _ExtraItem("Pelota acuática", 15, Icons.sports_volleyball_rounded),
        _ExtraItem("Chaleco salvavidas", 25, Icons.safety_check_rounded),
        _ExtraItem("Toalla extra", 20, Icons.emoji_people_rounded),
      ];
    } else if (up.contains('TENIS')) {
      return [
        _ExtraItem("Renta de raqueta", 40, Icons.sports_tennis_rounded),
        _ExtraItem("Caja de pelotas", 25, Icons.sports_rounded),
        _ExtraItem("Entrenador 30 min", 80, Icons.school_rounded),
        _ExtraItem("Iluminación nocturna", 30, Icons.light_mode_rounded),
      ];
    } else if (up.contains('GIMNASIO')) {
      return [
        _ExtraItem("Entrenador 30 min", 90, Icons.fitness_center_rounded),
        _ExtraItem("Toalla premium", 20, Icons.emoji_people_rounded),
        _ExtraItem("Locker privado", 25, Icons.lock_rounded),
        _ExtraItem("Shake de proteína", 35, Icons.local_drink_rounded),
      ];
    } else if (up.contains('FRONTON') || up.contains('FRONTÓN')) {
      return [
        _ExtraItem("Guantes de protección", 30, Icons.sports_handball_rounded),
        _ExtraItem("Pelotas extra", 25, Icons.sports_baseball_rounded),
        _ExtraItem("Lentes de seguridad", 20, Icons.visibility_rounded),
        _ExtraItem("Marcador electrónico", 30, Icons.scoreboard_rounded),
      ];
    }

    return [
      _ExtraItem("Toalla extra", 20, Icons.emoji_people_rounded),
      _ExtraItem("Locker privado", 25, Icons.lock_rounded),
      _ExtraItem("Botella de agua", 15, Icons.local_drink_rounded),
      _ExtraItem("Snack saludable", 20, Icons.fastfood_rounded),
    ];
  }

  void _toggleExtra(int index) {
    setState(() {
      _extras[index].selected = !_extras[index].selected;
      _extrasTotal =
          _extras.where((e) => e.selected).fold(0, (s, e) => s + e.price);
    });
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _finishReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: usuario no autenticado.")),
      );
      return;
    }

    final int totalAPagar = widget.basePrice + _extrasTotal;
    final String dateKey = _dateKey(widget.date);

    final selectedExtras = _extras
        .where((e) => e.selected)
        .map((e) => {
              'label': e.label,
              'price': e.price,
              'icon': e.icon.codePoint,
            })
        .toList();

    setState(() => _saving = true);

    try {
      final DatabaseReference ref = FirebaseDatabase.instance
          .ref('usuarios/${user.uid}/reservas_detalle')
          .push();

      await ref.set({
        'area': widget.areaName,
        'fecha': dateKey,
        'horario': widget.timeSlot,
        'basePrice': widget.basePrice,
        'extrasTotal': _extrasTotal,
        'totalAPagar': totalAPagar,
        'extras': selectedExtras,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Extras guardados correctamente.")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmReservaPage(
            areaName: widget.areaName,
            userName: widget.userName,
            date: widget.date,
            timeSlot: widget.timeSlot,
            basePrice: widget.basePrice,
            extrasTotal: _extrasTotal,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalAPagar = widget.basePrice + _extrasTotal;

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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF15192B),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Extras para ${widget.areaName}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card de extras
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Extras a la reservación",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Selecciona uno o varios extras opcionales.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Grid 2x2 de extras
                        Expanded(
                          child: GridView.builder(
                            itemCount: _extras.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.4,
                            ),
                            itemBuilder: (context, index) {
                              return _ExtraCard(
                                item: _extras[index],
                                onTap: () => _toggleExtra(index),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Totales
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black.withOpacity(0.25),
                          ),
                          child: Column(
                            children: [
                              _totalRow(
                                  "Base (${widget.areaName})",
                                  "${widget.basePrice} MXN"),
                              const SizedBox(height: 4),
                              _totalRow("Extras", "$_extrasTotal MXN"),
                              const SizedBox(height: 6),
                              const Divider(
                                color: Colors.white24,
                                height: 10,
                              ),
                              const SizedBox(height: 4),
                              _totalRow(
                                "TOTAL A PAGAR",
                                "$totalAPagar MXN",
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _saving ? null : () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "ATRÁS",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _saving ? null : _finishReservation,
                            child: _saving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "TERMINAR",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ExtraItem {
  final String label;
  final int price;
  final IconData icon;
  bool selected;

  _ExtraItem(this.label, this.price, this.icon, {this.selected = false});
}

class _ExtraCard extends StatelessWidget {
  final _ExtraItem item;
  final VoidCallback onTap;

  const _ExtraCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = item.selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withOpacity(0.12),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: selected ? Colors.white : const Color(0xFF50E3C2),
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "+${item.price} MXN",
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
