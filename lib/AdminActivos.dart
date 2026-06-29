import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminActivos extends StatefulWidget {
  final String token;
  const AdminActivos({super.key, required this.token});

  @override
  State<AdminActivos> createState() => _AdminActivosState();
}

class _AdminActivosState extends State<AdminActivos> {
  List activos = [];
  List activosFiltrados = [];
  bool loading = true;
  String busqueda = "";

  @override
  void initState() {
    super.initState();
    cargarActivos();
  }

  Future<void> cargarActivos() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/activos"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          activos = data;
          activosFiltrados = data;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  void filtrar(String texto) {
    setState(() {
      busqueda = texto;
      activosFiltrados = activos.where((a) {
        final titulo = (a["titulo"] ?? "").toLowerCase();
        final serie = (a["serie"] ?? "").toLowerCase();
        return titulo.contains(texto.toLowerCase()) || serie.contains(texto.toLowerCase());
      }).toList();
    });
  }

  Color colorEstado(String? estado) {
    switch (estado) {
      case "Disponible": return Colors.green;
      case "Asignado": return Colors.blueAccent;
      case "En reparación": return Colors.orange;
      case "De baja": return Colors.redAccent;
      default: return Colors.grey;
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
        title: const Text("Activos", style: TextStyle(color: Color(0xFF00D892), fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D892)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Buscar por nombre o serie...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00D892)),
                      filled: true,
                      fillColor: const Color(0xFF171B1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: filtrar,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF00D892),
                    onRefresh: cargarActivos,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activosFiltrados.length,
                      itemBuilder: (context, index) {
                        final a = activosFiltrados[index];
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
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.computer, color: Colors.white),
                            ),
                            title: Text(a["titulo"] ?? "Sin nombre", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Serie: ${a["serie"] ?? "—"}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                Text("Responsable: ${a["responsable"] ?? "—"}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorEstado(a["estado"]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(a["estado"] ?? "—", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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