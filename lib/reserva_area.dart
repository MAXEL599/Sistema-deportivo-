import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'extras_reserva.dart';

class ReservaAreaPage extends StatefulWidget {
  final String areaName;   // Ej: "Piscina"
  final String userName;   // Ej: "Carlos"

  const ReservaAreaPage({
    super.key,
    required this.areaName,
    required this.userName,
  });

  @override
  State<ReservaAreaPage> createState() => _ReservaAreaPageState();
}

class _ReservaAreaPageState extends State<ReservaAreaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 4 horarios
  final List<String> _horariosDisponibles = [
    "7:00 am a 8:00 am",
    "9:30 am a 11:30 am",
    "1:00 pm a 2:00 pm",
    "5:00 pm a 7:00 pm",
  ];

  static const int _maxCupo = 6;

  // clave de área para DB (piscina, cancha_de_tenis, etc)
  String get _areaKey =>
      widget.areaName.toLowerCase().replaceAll(' ', '_');

  int _basePrice() {
    switch (widget.areaName.toUpperCase()) {
      case 'PISCINA':
        return 100;
      case 'CANCHA DE TENIS':
        return 120;
      case 'GIMNASIO':
        return 80;
      case 'FRONTON':
        return 90;
      default:
        return 100;
    }
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _timeKey(String timeLabel) {
    return timeLabel
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll(':', '_')
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll('a', '_');
  }

  Future<void> _onTimeSelected(String time) async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero selecciona una fecha.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: usuario no autenticado.")),
      );
      return;
    }

    final String dateKey = _dateKey(_selectedDay!);
    final String timeKey = _timeKey(time);

    final DatabaseReference slotRef = FirebaseDatabase.instance.ref(
      'reservas_areas/$_areaKey/$dateKey/$timeKey',
    );

    final DataSnapshot snapshot = await slotRef.get();

    int ocupados = 0;
    if (snapshot.exists && snapshot.value is Map) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      ocupados = (data['ocupados'] ?? 0) as int;
    }

    if (ocupados >= _maxCupo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este horario ya no tiene espacios disponibles."),
        ),
      );
      return;
    }

    final int nuevosOcupados = ocupados + 1;

    // guarda el estado del horario para esa área+fecha
    await slotRef.set({
      'area': widget.areaName,
      'fecha': dateKey,
      'horario': time,
      'ocupados': nuevosOcupados,
    });

    // guarda la reserva del usuario
    final DatabaseReference userReservaRef = FirebaseDatabase.instance
        .ref('usuarios/${user.uid}/reservas')
        .push();

    await userReservaRef.set({
      'area': widget.areaName,
      'fecha': dateKey,
      'horario': time,
    });

    final int restantes = _maxCupo - nuevosOcupados;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Reserva hecha para $time. Quedan $restantes espacios.",
        ),
      ),
    );

    // ir a pantalla de extras
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExtrasReservaPage(
          areaName: widget.areaName,
          userName: widget.userName,
          date: _selectedDay!,
          timeSlot: time,
          basePrice: _basePrice(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Header con avatar y área
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
                              "Reserva de ${widget.areaName}",
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

                  // Card de instrucciones + calendario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A314A), Color(0xFF323A57)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Elige una fecha",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Selecciona primero el día y después el horario disponible.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay:
                                DateTime.now().add(const Duration(days: 365)),
                            focusedDay: _focusedDay,
                            calendarFormat: CalendarFormat.month,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              leftChevronIcon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white70,
                              ),
                              rightChevronIcon: const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle:
                                  TextStyle(color: Colors.white70),
                              weekendStyle:
                                  TextStyle(color: Colors.white70),
                            ),
                            // 🔥 Arreglo del bug: TODAS las decoraciones rectangulares
                            calendarStyle: CalendarStyle(
                              defaultDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              weekendDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              outsideDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              disabledDecoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              todayDecoration: BoxDecoration(
                                color: const Color(0xFF50E3C2)
                                    .withOpacity(0.3),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              selectedDecoration: BoxDecoration(
                                color: const Color(0xFF50E3C2),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              defaultTextStyle:
                                  const TextStyle(color: Colors.white),
                              weekendTextStyle:
                                  const TextStyle(color: Colors.white),
                              disabledTextStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              outsideDaysVisible: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Título horarios
                  Row(
                    children: const [
                      Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF50E3C2),
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Selecciona un horario",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Botones horarios (2x2)
                  Row(
                    children: [
                      Expanded(
                        child: _GradientHorarioButton(
                          icon: Icons.wb_sunny_rounded,
                          text: _horariosDisponibles[0],
                          onPressed: () =>
                              _onTimeSelected(_horariosDisponibles[0]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientHorarioButton(
                          icon: Icons.wb_sunny_outlined,
                          text: _horariosDisponibles[1],
                          onPressed: () =>
                              _onTimeSelected(_horariosDisponibles[1]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientHorarioButton(
                          icon: Icons.wb_cloudy_rounded,
                          text: _horariosDisponibles[2],
                          onPressed: () =>
                              _onTimeSelected(_horariosDisponibles[2]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientHorarioButton(
                          icon: Icons.nights_stay_rounded,
                          text: _horariosDisponibles[3],
                          onPressed: () =>
                              _onTimeSelected(_horariosDisponibles[3]),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientHorarioButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _GradientHorarioButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
