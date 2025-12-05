import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home.dart';

class ConfirmReservaPage extends StatefulWidget {
  final String areaName;    // Ej: "Piscina"
  final String userName;    // Ej: "Carlos"
  final DateTime date;      // Día elegido
  final String timeSlot;    // Ej: "7:00 am a 8:00 am"
  final int basePrice;      // Precio base
  final int extrasTotal;    // Total extras

  /// ID del nodo en Realtime Database (pushId).
  /// Ruta esperada: usuarios/{uid}/reservas/reservas_detalle/{reservaId}
  final String? reservaId;

  const ConfirmReservaPage({
    super.key,
    required this.areaName,
    required this.userName,
    required this.date,
    required this.timeSlot,
    required this.basePrice,
    required this.extrasTotal,
    this.reservaId, // 👈 pásalo desde ExtrasReservaPage cuando guardes en Firebase
  });

  @override
  State<ConfirmReservaPage> createState() => _ConfirmReservaPageState();
}

class _ConfirmReservaPageState extends State<ConfirmReservaPage> {
  bool _processing = false;

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

  DatabaseReference? _reservaRefForCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.reservaId == null) return null;

    return FirebaseDatabase.instance
        .ref()
        .child('usuarios')
        .child(user.uid)
        .child('reservas')
        .child('reservas_detalle')
        .child(widget.reservaId!);
  }

  Future<void> _setEstado(String nuevoEstado) async {
    final ref = _reservaRefForCurrentUser();
    if (ref == null) {
      // Si no tenemos id o user, solo volvemos al home.
      _goHome();
      return;
    }

    setState(() => _processing = true);
    try {
      await ref.update({'estado': nuevoEstado});
    } finally {
      if (!mounted) return;
      setState(() => _processing = false);
      _goHome();
    }
  }

  Future<void> _eliminarReserva() async {
    final ref = _reservaRefForCurrentUser();
    if (ref == null) {
      _goHome();
      return;
    }

    setState(() => _processing = true);
    try {
      await ref.remove();
    } finally {
      if (!mounted) return;
      setState(() => _processing = false);
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePageVIP()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String descripcionReserva =
        '${widget.areaName} de ${widget.timeSlot}';
    final String textoFecha = 'El día ${_fechaEnEspanol(widget.date)}';
    final int total = widget.basePrice + widget.extrasTotal;

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
                            "Confirmación de la reservación",
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

                const SizedBox(height: 20),

                // Card central
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
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
                      children: [
                        const SizedBox(height: 12),
                        const Icon(
                          Icons.shield_rounded,
                          size: 40,
                          color: Color(0xFF50E3C2),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Revisar reserva",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Usted está a punto de elegir el estado de esta reservación:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          '"$descripcionReserva"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          textoFecha,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.25),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Base (${widget.areaName})",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "${widget.basePrice} MXN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Extras",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "${widget.extrasTotal} MXN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(color: Colors.white24, height: 10),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "TOTAL A PAGAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "$total MXN",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        Text(
                          "Puedes marcar la reserva como confirmada, dejarla pendiente o eliminarla.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3 Botones: ELIMINAR / PENDIENTE / CONFIRMAR
                Row(
                  children: [
                    // ELIMINAR
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.18),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              _processing ? null : () => _eliminarReserva(),
                          child: _processing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("ELIMINAR"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // PENDIENTE
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.withOpacity(0.22),
                            foregroundColor: Colors.amberAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _processing
                              ? null
                              : () => _setEstado("pendiente"),
                          child: _processing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("PENDIENTE"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // CONFIRMAR
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _processing
                                ? null
                                : () => _setEstado("confirmada"),
                            child: _processing
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "CONFIRMAR",
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
}
