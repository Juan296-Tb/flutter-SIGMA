import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminTickets extends StatefulWidget {
  final String token;
  const AdminTickets({super.key, required this.token});

  @override
  State<AdminTickets> createState() => _AdminTicketsState();
}

class _AdminTicketsState extends State<AdminTickets> {
  List tickets = [];
  List ticketsFiltrados = [];
  bool loading = true;
  String filtroEstado = "Todos";

  @override
  void initState() {
    super.initState();
    cargarTickets();
  }

  Future<void> cargarTickets() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/tickets"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          tickets = data;
          ticketsFiltrados = data;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  void filtrar(String estado) {
    setState(() {
      filtroEstado = estado;
      if (estado == "Todos") {
        ticketsFiltrados = tickets;
      } else {
        ticketsFiltrados = tickets.where((t) => t["est"] == estado).toList();
      }
    });
  }

  Color colorEstado(String? estado) {
    switch (estado) {
      case "ABIERTO": return Colors.redAccent;
      case "EN_PROGRESO": return Colors.orange;
      case "CERRADO": return Colors.green;
      default: return Colors.grey;
    }
  }

  String labelEstado(String? estado) {
    switch (estado) {
      case "ABIERTO": return "Abierto";
      case "EN_PROGRESO": return "En progreso";
      case "CERRADO": return "Cerrado";
      default: return estado ?? "—";
    }
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
        title: const Text(
          "Tickets",
          style: TextStyle(color: Color(0xFF00D892), fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D892)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["Todos", "ABIERTO", "EN_PROGRESO", "CERRADO"].map((e) {
                        final activo = filtroEstado == e;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              labelEstado(e),
                              style: TextStyle(color: activo ? Colors.black : Colors.white70),
                            ),
                            selected: activo,
                            selectedColor: const Color(0xFF00D892),
                            backgroundColor: const Color(0xFF171B1E),
                            onSelected: (_) => filtrar(e),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF00D892),
                    onRefresh: cargarTickets,
                    child: ticketsFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay tickets",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: ticketsFiltrados.length,
                            itemBuilder: (context, index) {
                              final t = ticketsFiltrados[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF171B1E),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.orangeAccent,
                                    child: Icon(Icons.confirmation_num, color: Colors.white),
                                  ),
                                  title: Text(
                                    t["tit"] ?? "Sin título",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Prioridad: ${t["priori"] ?? "—"}",
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      Text(
                                        "Activo: ${t["activoNombre"] ?? "—"}",
                                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorEstado(t["est"]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      labelEstado(t["est"]),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}