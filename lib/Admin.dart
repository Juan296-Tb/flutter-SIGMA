import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AdminActivos.dart';
import 'AdminTickets.dart';
import 'AdminMantenimientos.dart';
import 'AdminPanelDeControl.dart';
import 'AdminTickets.dart';

class Admin extends StatefulWidget {
  final String userId;
  final String token;

  const Admin({super.key, required this.userId, required this.token});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String nombreUsuario = "";
  int totalUsuarios = 0;
  int totalActivos = 0;
  int totalTickets = 0;
  int totalOrdenes = 0;
  int ticketsAbiertos = 0;
  int ordenesEnCurso = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final headers = {"Authorization": "Bearer ${widget.token}"};

      final responses = await Future.wait([
        http.get(Uri.parse("http://localhost:8080/api/usuarios"), headers: headers),
        http.get(Uri.parse("http://localhost:8080/api/activos"), headers: headers),
        http.get(Uri.parse("http://localhost:8080/api/tickets"), headers: headers),
        http.get(Uri.parse("http://localhost:8080/api/ordenes"), headers: headers),
      ]);

      final usuarios = jsonDecode(responses[0].body) as List;
      final activos  = jsonDecode(responses[1].body) as List;
      final tickets  = jsonDecode(responses[2].body) as List;
      final ordenes  = jsonDecode(responses[3].body) as List;

      final usuario = usuarios.firstWhere(
        (u) => u["email"] == widget.userId,
        orElse: () => null,
      );

      setState(() {
        nombreUsuario   = usuario != null ? (usuario["nombre"] ?? "Admin") : "Admin";
        totalUsuarios   = usuarios.length;
        totalActivos    = activos.length;
        totalTickets    = tickets.length;
        totalOrdenes    = ordenes.length;
        ticketsAbiertos = tickets.where((t) => t["est"] == "ABIERTO").length;
        ordenesEnCurso  = ordenes.where((o) => o["estado"] == "EN_CURSO").length;
        loading = false;
      });

    } catch (e) {
      debugPrint("Error cargarDatos Admin: $e");
      setState(() => loading = false);
    }
  }

  Widget _cuadro(String titulo, String valor, String subtitulo, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171B1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(valor, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _botonAccion(IconData icono, String texto, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icono),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF171B1E),
          foregroundColor: const Color(0xFF00D892),
          side: const BorderSide(color: Color(0xFF00D892)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F151A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171B1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00D892)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nombreUsuario.isEmpty ? "Cargando..." : nombreUsuario,
          style: const TextStyle(color: Color(0xFF00D892), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text("Admin", style: TextStyle(color: Colors.black, fontSize: 11)),
              backgroundColor: const Color(0xFF00D892),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D892)))
          : RefreshIndicator(
              color: const Color(0xFF00D892),
              onRefresh: cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF171B1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF00D892),
                            child: Icon(Icons.admin_panel_settings, color: Colors.black, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreUsuario.isEmpty ? "Admin" : nombreUsuario,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Text("Panel de administración", style: TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text("Resumen general", style: TextStyle(color: Color(0xFF00D892), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),

                    // CUADROS
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _cuadro("Usuarios", "$totalUsuarios", "Registrados en el sistema", Icons.people, const Color(0xFF00D892)),
                        _cuadro("Activos", "$totalActivos", "Equipos registrados", Icons.computer, Colors.blueAccent),
                        _cuadro("Tickets", "$totalTickets", "$ticketsAbiertos abiertos", Icons.confirmation_num, Colors.orangeAccent),
                        _cuadro("Mantenimientos", "$totalOrdenes", "$ordenesEnCurso en curso", Icons.build, Colors.purpleAccent),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text("Acciones rápidas", style: TextStyle(color: Color(0xFF00D892), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),

                    _botonAccion(Icons.admin_panel_settings, "Panel de control", () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AdminPanelDeControl(token: widget.token)));
                    }),
                    const SizedBox(height: 10),
                    _botonAccion(Icons.computer, "Ver activos", () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AdminActivos(token: widget.token)));
                    }),
                    const SizedBox(height: 10),
                    _botonAccion(Icons.confirmation_num, "Ver tickets", () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AdminTickets(token: widget.token)));
                    }),
                    const SizedBox(height: 10),
                    _botonAccion(Icons.build, "Ver mantenimientos", () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => AdminMantenimientos(token: widget.token)));
                    }),
                  ],
                ),
              ),
            ),
    );
  }
}