import 'package:flutter/material.dart';
import 'confirm_reserva.dart';

class ExtrasReservaPage extends StatefulWidget {
  final String areaName;   // ej: Piscina
  final String userName;   // ej: Carlos
  final DateTime date;
  final String timeSlot;
  final int basePrice;     // precio de la reserva base en MXN

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
  final List<_ExtraItem> _extras = [
    _ExtraItem("FLOTADOR +15", 15),
    _ExtraItem("PELOTA +15", 15),
    _ExtraItem("CHALECO\nSALVAVIDAS +25", 25),
    _ExtraItem("TOALLA +20", 20),
  ];

  int _extrasTotal = 0;

  void _toggleExtra(int index) {
    setState(() {
      _extras[index].selected = !_extras[index].selected;
      _extrasTotal =
          _extras.where((e) => e.selected).fold(0, (s, e) => s + e.price);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalAPagar = widget.basePrice + _extrasTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

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
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Título
              const Center(
                child: Text(
                  "Extras a la reservación",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "¿Desea agregar un extra a la reservación?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              const SizedBox(height: 20),

              // Botones de extras 2x2
              Row(
                children: [
                  Expanded(
                    child: _ExtraButton(
                      item: _extras[0],
                      onTap: () => _toggleExtra(0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ExtraButton(
                      item: _extras[1],
                      onTap: () => _toggleExtra(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ExtraButton(
                      item: _extras[2],
                      onTap: () => _toggleExtra(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ExtraButton(
                      item: _extras[3],
                      onTap: () => _toggleExtra(3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Totales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Piscina",
                      style: TextStyle(fontSize: 15, color: Colors.black)),
                  Text("${widget.basePrice} MXN",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("EXTRAS",
                      style: TextStyle(fontSize: 15, color: Colors.black)),
                  Text("$_extrasTotal MXN",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL A PAGAR",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("$totalAPagar MXN",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),

              const Spacer(),

              // Botones ATRAS / TERMINAR
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
                          Navigator.pop(context); // regresa al calendario
                        },
                        child: const Text(
                          "ATRAS",
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
                        },
                        child: const Text(
                          "TERMINAR",
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

class _ExtraItem {
  final String label;
  final int price;
  bool selected;

  _ExtraItem(this.label, this.price, {this.selected = false});
}

class _ExtraButton extends StatelessWidget {
  final _ExtraItem item;
  final VoidCallback onTap;

  const _ExtraButton({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        item.selected ? const Color(0xFF4CAF50) : const Color(0xFF3E4650);

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        onPressed: onTap,
        child: Text(
          item.label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
