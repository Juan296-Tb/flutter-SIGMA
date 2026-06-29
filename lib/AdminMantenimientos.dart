import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminMantenimientos extends StatefulWidget {
  final String token;
  const AdminMantenimientos({super.key, required this.token});

  @override
  State<AdminMantenimientos> createState() => _AdminMantenimientosState();
}

class _AdminMantenimientosState extends State<AdminMantenimientos> {
  List ordenes = [];
  List ordenesFiltradas = [];
  bool loading = true;
  String filtroEstado = "Todos";

  @override
  void initState() {
    super.initState();
    cargarOrdenes();
  }

  Future<void> cargarOrdenes() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/ordenes"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          ordenes = data;
          ordenesFiltradas = data;
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
        ordenesFiltradas = ordenes;
      } else {
        ordenesFiltradas = ordenes.where((o) => o["estado"] == estado).toList();
      }
    });
  }

  Color colorEstado(String? estado) {
    switch (estado) {
      case "EN_CURSO": return Colors.orange;
      case "PENDIENTE": return Colors.blueAccent;
      case "CERRADA": return Colors.green;
      default: return Colors.grey;
    }
  }

  String labelEstado(String? estado) {
    switch (estado) {
      case "EN_CURSO": return "En curso";
      case "PENDIENTE": return "Pendiente";
      case "CERRADA": return "Cerrada";
      default: return estado ?? "—";
    }
  }

  String labelTipo(String? tipo) {
    switch (tipo) {
      case "CORRECTIVO": return "Correctivo";
      case "PREVENTIVO": return "Preventivo";
      case "INSPECCION": return "Inspección";
      default: return tipo ?? "—";
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
        title: const Text("Mantenimientos", style: TextStyle(color: Color(0xFF00D892), fontWeight: FontWeight.bold)),
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
                      children: ["Todos", "PENDIENTE", "EN_CURSO", "CERRADA"].map((e) {
                        final activo = filtroEstado == e;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(labelEstado(e), style: TextStyle(color: activo ? Colors.black : Colors.white70)),
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
                    onRefresh: cargarOrdenes,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ordenesFiltradas.length,
                      itemBuilder: (context, index) {
                        final o = ordenesFiltradas[index];
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
                              backgroundColor: Colors.purpleAccent,
                              child: Icon(Icons.build, color: Colors.white),
                            ),
                            title: Text(o["ordenId"] ?? o["id"] ?? "Sin ID", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Activo: ${o["activoNombre"] ?? "—"}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                Text("Tipo: ${labelTipo(o["tipo"])}  |  Técnico: ${o["tecnicoNombre"] ?? "—"}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorEstado(o["estado"]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(labelEstado(o["estado"]), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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