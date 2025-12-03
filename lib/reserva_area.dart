import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'extras_reserva.dart'; // 👈 IMPORTA la pantalla de extras, no la de confirmación

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

  final List<String> _horariosDisponibles = [
    "7:00 am a 8:00 am",
    "9:30 am a 11:30 am",
  ];

  final List<String> _horariosNoDisponibles = [
    "NO DISPONIBLE",
    "NO DISPONIBLE",
  ];

  // 👇 Precio base según el área
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

  void _onTimeSelected(String time) {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero selecciona una fecha.")),
      );
      return;
    }

    // 👇 AHORA VAMOS A LA PANTALLA DE EXTRAS, NO A CONFIRMAR DIRECTO
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // 👈 scroll para que no haga overflow
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Avatar + nombre
              Center(
                child: Column(
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
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Texto “Usted eligió…”
              Center(
                child: Text(
                  "Usted eligió ${widget.areaName},\nahora elija un horario",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Seleccione la fecha",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 12),

              // Calendario
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      shape: BoxShape.rectangle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF3E4650),
                      shape: BoxShape.rectangle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Horarios disponibles
              Row(
                children: [
                  Expanded(
                    child: _HorarioButton(
                      text: _horariosDisponibles[0],
                      onTap: () => _onTimeSelected(_horariosDisponibles[0]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HorarioButton(
                      text: _horariosDisponibles[1],
                      onTap: () => _onTimeSelected(_horariosDisponibles[1]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Horarios NO disponibles
              Row(
                children: [
                  Expanded(
                    child: _HorarioButton(
                      text: _horariosNoDisponibles[0],
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HorarioButton(
                      text: _horariosNoDisponibles[1],
                      enabled: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorarioButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback? onTap;

  const _HorarioButton({
    super.key,
    required this.text,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? const Color(0xFF3E4650) : Colors.grey.shade400,
        ),
        onPressed: enabled ? onTap : null,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
