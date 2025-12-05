import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// Si luego quieres ir a editar la reserva:
import 'reserva_area.dart'; // <-- ya lo tienes

class ReservasConfirmadasPage extends StatefulWidget {
  const ReservasConfirmadasPage({super.key});

  @override
  State<ReservasConfirmadasPage> createState() =>
      _ReservasConfirmadasPageState();
}

class _ReservasConfirmadasPageState extends State<ReservasConfirmadasPage> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<_ReservaData> _todasLasReservas = [];
  String _filtro = "";
  bool _cargando = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _filtro = _searchController.text.toLowerCase();
      });
    });

    _cargarReservas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _todasLasReservas = [];
        _cargando = false;
      });
      return;
    }

    try {
      final snap =
          await _db.child('usuarios/${user.uid}/reservas_detalle').get();

      final List<_ReservaData> temp = [];

      if (snap.value != null) {
        // El valor es un mapa de pushId -> datos
        final data = Map<dynamic, dynamic>.from(snap.value as Map);

        data.forEach((key, value) {
          final m = Map<dynamic, dynamic>.from(value as Map);

          // extrasTotal puede venir dentro de "extras" o plano
          int extrasTotal = 0;
          if (m['extrasTotal'] != null) {
            extrasTotal = (m['extrasTotal'] as num).toInt();
          } else if (m['extras'] != null &&
              Map.from(m['extras']).containsKey('extrasTotal')) {
            extrasTotal =
                (Map.from(m['extras'])['extrasTotal'] as num).toInt();
          }

          temp.add(
            _ReservaData(
              id: key.toString(),
              fecha: m['fecha']?.toString() ?? '',
              area: m['area']?.toString() ?? '',
              hora: m['horario']?.toString() ?? '',
              estado: (m['estado'] ?? 'confirmada').toString(),
              basePrice: (m['basePrice'] ?? 0 as num).toInt(),
              extrasTotal: extrasTotal,
              totalAPagar: (m['totalAPagar'] ?? 0 as num).toInt(),
            ),
          );
        });
      }

      setState(() {
        _todasLasReservas = temp;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error al cargar reservas: $e');
      setState(() {
        _todasLasReservas = [];
        _cargando = false;
      });
    }
  }

  List<_ReservaData> get _reservasFiltradas {
    if (_filtro.isEmpty) return _todasLasReservas;
    return _todasLasReservas.where((r) {
      final texto =
          "${r.fecha} ${r.area} ${r.hora} ${r.estado}".toLowerCase();
      return texto.contains(_filtro);
    }).toList();
  }

  Future<void> _generarPdf(_ReservaData r) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Centro Deportivo VIP',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Comprobante de reservación'),
                pw.SizedBox(height: 16),
                pw.Divider(),

                pw.SizedBox(height: 12),
                pw.Text(
                  'Detalles de la reservación',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Área: ${r.area}'),
                pw.Text('Fecha: ${r.fecha}'),
                pw.Text('Horario: ${r.hora}'),
                pw.Text('Estado: ${r.estado.toUpperCase()}'),

                pw.SizedBox(height: 16),
                pw.Divider(),

                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Base (${r.area})'),
                    pw.Text('${r.basePrice} MXN'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Extras'),
                    pw.Text('${r.extrasTotal} MXN'),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL A PAGAR',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${r.totalAPagar} MXN',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Generado el ${DateTime.now()}',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _onReservaTap(_ReservaData r) {
    if (r.estado.toLowerCase() != 'pendiente') {
      // Por ahora solo los pendientes se pueden editar
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2435),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Reserva pendiente",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${r.area} · ${r.fecha} · ${r.hora}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C2435),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Aquí decides si lo mandas al calendario o a extras.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservaAreaPage(
                          areaName: r.area,
                          userName:
                              "Usuario", // si quieres puedes pasar el nombre real
                        ),
                      ),
                    );
                  },
                  child: const Text("Editar reserva"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservas = _reservasFiltradas;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AppBar custom
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        "Reservaciones confirmadas",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // para equilibrar
                  ],
                ),
                const SizedBox(height: 10),

                // Buscador
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Buscar por fecha, área o estado",
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Lista de reservaciones",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${reservas.length} reservas",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: _cargando
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : reservas.isEmpty
                          ? const Center(
                              child: Text(
                                "No hay reservaciones registradas.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 20,
                                  headingRowHeight: 42,
                                  dataRowHeight: 52,
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.06),
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "FECHA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "ÁREA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "HORA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "ESTADO",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 40,
                                        child: Icon(Icons.picture_as_pdf,
                                            size: 18,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                  rows: reservas.map((reserva) {
                                    final estadoLower =
                                        reserva.estado.toLowerCase();
                                    final Color colorEstado;
                                    if (estadoLower == 'confirmada') {
                                      colorEstado = const Color(0xFF50E3C2);
                                    } else if (estadoLower == 'pendiente') {
                                      colorEstado = const Color(0xFFFFA726);
                                    } else {
                                      colorEstado = Colors.redAccent;
                                    }

                                    return DataRow(
                                      onSelectChanged: (_) =>
                                          _onReservaTap(reserva),
                                      cells: [
                                        DataCell(
                                          Text(
                                            reserva.fecha,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            reserva.area,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            reserva.hora,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            reserva.estado.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: colorEstado,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.download_rounded,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => _generarPdf(
                                              reserva,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
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

class _ReservaData {
  final String id;
  final String fecha;
  final String area;
  final String hora;
  final String estado;
  final int basePrice;
  final int extrasTotal;
  final int totalAPagar;

  _ReservaData({
    required this.id,
    required this.fecha,
    required this.area,
    required this.hora,
    required this.estado,
    required this.basePrice,
    required this.extrasTotal,
    required this.totalAPagar,
  });
}
