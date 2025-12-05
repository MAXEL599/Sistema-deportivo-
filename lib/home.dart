import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reserva_area.dart';

class HomePageVIP extends StatefulWidget {
  const HomePageVIP({super.key});

  @override
  State<HomePageVIP> createState() => _HomePageVIPState();
}

class _HomePageVIPState extends State<HomePageVIP> {
  String userName = "Usuario";

  // --- Servicios del club ---
  final List<ClubService> _services = [
    // Deportes
    ClubService("Cancha de pádel", "Deporte"),
    ClubService("Cancha de squash", "Deporte"),
    ClubService("Cancha de tenis techada", "Deporte"),
    ClubService("Fútbol rápido", "Deporte"),
    ClubService("Gimnasio de fuerza", "Deporte"),
    ClubService("Piscina semiolímpica", "Deporte"),
    ClubService("Sala de spinning", "Deporte"),

    // Wellness
    ClubService("Estudio de yoga", "Wellness"),
    ClubService("Jacuzzi panorámico", "Wellness"),
    ClubService("Masaje de recuperación", "Wellness"),
    ClubService("Spa deportivo", "Wellness"),
    ClubService("Sauna y vapor", "Wellness"),

    // Restaurantes
    ClubService("Restaurante gourmet", "Restaurante"),
    ClubService("Snack bar en piscina", "Restaurante"),
    ClubService("Bar saludable (smoothies)", "Restaurante"),

    // Entretenimiento
    ClubService("Terraza lounge", "Entretenimiento"),
    ClubService("Sala de juegos (billar, ping-pong)", "Entretenimiento"),
    ClubService("Cine al aire libre", "Entretenimiento"),
    ClubService("Salón de eventos sociales", "Entretenimiento"),
  ];

  String _searchQuery = "";
  String _filterArea = "Todos";

  List<ClubService> get _filteredServices {
    return _services
        .where((s) {
          final matchesSearch =
              s.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesFilter =
              _filterArea == "Todos" || s.area == _filterArea;
          return matchesSearch && matchesFilter;
        })
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userName = user.displayName ?? "Usuario";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // dejamos transparente para usar nuestro gradient
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _buildBottomNavBar(),
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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickReserveCard(context),
                  const SizedBox(height: 24),
                  _buildServicesSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15192B), Color(0xFF1C2234)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF50E3C2),
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/perfil');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Reservas',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/perfil'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF50E3C2), Color(0xFF5DA9F6)],
              ),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF15192B),
              child: Icon(
                Icons.person_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenido,",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade300,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReserveCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            "¿Qué deseas reservar hoy?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Elige un área para comenzar tu experiencia en el club.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _GradientReservaButton(
                  icon: Icons.pool_rounded,
                  text: "Piscina",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservaAreaPage(
                          areaName: "Piscina",
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientReservaButton(
                  icon: Icons.sports_tennis_rounded,
                  text: "Tenis",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservaAreaPage(
                          areaName: "Cancha de tenis",
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GradientReservaButton(
                  icon: Icons.fitness_center_rounded,
                  text: "Gimnasio",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservaAreaPage(
                          areaName: "Gimnasio",
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientReservaButton(
                  icon: Icons.sports_handball_rounded,
                  text: "Frontón",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservaAreaPage(
                          areaName: "Fronton",
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.star_rounded,
              color: Color(0xFF50E3C2),
              size: 22,
            ),
            SizedBox(width: 6),
            Text(
              "Servicios del club",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Restaurantes, zona wellness, entretenimiento y deportes adicionales.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 14),

        // Tarjeta "glass" para buscador + tabla
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
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
            children: [
              // Buscador
              TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF50E3C2),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white70,
                  ),
                  hintText: "Buscar servicio por nombre...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF50E3C2),
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Filtro chips por área
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AreaChip(
                      label: "Todos",
                      selected: _filterArea == "Todos",
                      onTap: () => setState(() => _filterArea = "Todos"),
                    ),
                    const SizedBox(width: 8),
                    _AreaChip(
                      label: "Deporte",
                      icon: Icons.sports_soccer_rounded,
                      selected: _filterArea == "Deporte",
                      onTap: () => setState(() => _filterArea = "Deporte"),
                    ),
                    const SizedBox(width: 8),
                    _AreaChip(
                      label: "Wellness",
                      icon: Icons.spa_rounded,
                      selected: _filterArea == "Wellness",
                      onTap: () => setState(() => _filterArea = "Wellness"),
                    ),
                    const SizedBox(width: 8),
                    _AreaChip(
                      label: "Restaurante",
                      icon: Icons.restaurant_rounded,
                      selected: _filterArea == "Restaurante",
                      onTap: () =>
                          setState(() => _filterArea = "Restaurante"),
                    ),
                    const SizedBox(width: 8),
                    _AreaChip(
                      label: "Entretenimiento",
                      icon: Icons.celebration_rounded,
                      selected: _filterArea == "Entretenimiento",
                      onTap: () =>
                          setState(() => _filterArea = "Entretenimiento"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tabla
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 18,
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.white.withOpacity(0.06),
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  border: TableBorder.symmetric(
                    inside: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  columns: const [
                    DataColumn(label: Text("Servicio")),
                    DataColumn(label: Text("Área")),
                  ],
                  rows: _filteredServices
                      .map(
                        (s) => DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  Icon(
                                    _iconForArea(s.area),
                                    size: 18,
                                    color: const Color(0xFF50E3C2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s.name),
                                ],
                              ),
                            ),
                            DataCell(Text(s.area)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GradientReservaButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _GradientReservaButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
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
              blurRadius: 14,
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
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _AreaChip({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? const Color(0xFF50E3C2).withOpacity(0.18)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: selected
                ? const Color(0xFF50E3C2)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? const Color(0xFF50E3C2)
                    : Colors.white70,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? const Color(0xFF50E3C2)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubService {
  final String name;
  final String area; // Deporte, Wellness, Restaurante, Entretenimiento

  ClubService(this.name, this.area);
}

// Icono sugerido por área
IconData _iconForArea(String area) {
  switch (area) {
    case "Deporte":
      return Icons.sports_soccer_rounded;
    case "Wellness":
      return Icons.spa_rounded;
    case "Restaurante":
      return Icons.restaurant_rounded;
    case "Entretenimiento":
      return Icons.celebration_rounded;
    default:
      return Icons.star_rounded;
  }
}
