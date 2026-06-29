import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPanelDeControl extends StatefulWidget {
  final String token;
  const AdminPanelDeControl({super.key, required this.token});

  @override
  State<AdminPanelDeControl> createState() => _AdminPanelDeControlState();
}

class _AdminPanelDeControlState extends State<AdminPanelDeControl> {
  List usuarios = [];
  bool loading = true;
  String filtro = "Todos";

  final roles = ["Admin", "Responsable", "Gestor_Tickets", "Tecni_Mantenimiento"];
  final filtros = ["Todos", "Administradores", "Responsables", "Gestor de Tickets", "Técnicos de mantenimiento"];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/usuarios"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      if (res.statusCode == 200) {
        setState(() {
          usuarios = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> cambiarRol(String id, String nuevoRol) async {
    try {
      final res = await http.put(
        Uri.parse("http://localhost:8080/api/usuarios/$id/rol"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"rol": nuevoRol}),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rol actualizado correctamente"),
            backgroundColor: Color(0xFF00D892),
          ),
        );
        cargarUsuarios();
      }
    } catch (e) {
      debugPrint("Error cambiando rol: $e");
    }
  }

  List get usuariosFiltrados {
    if (filtro == "Todos") return usuarios;
    if (filtro == "Administradores") return usuarios.where((u) => (u["roles"] as List?)?.contains("Admin") == true).toList();
    if (filtro == "Responsables") return usuarios.where((u) => (u["roles"] as List?)?.contains("Responsable") == true).toList();
    if (filtro == "Gestor de Tickets") return usuarios.where((u) => (u["roles"] as List?)?.contains("Gestor_Tickets") == true).toList();
    if (filtro == "Técnicos de mantenimiento") return usuarios.where((u) => (u["roles"] as List?)?.contains("Tecni_Mantenimiento") == true).toList();
    return usuarios;
  }

  int contarPorRol(String rol) => usuarios.where((u) => (u["roles"] as List?)?.contains(rol) == true).length;

  void mostrarDialogRol(Map usuario) {
    String rolSeleccionado = (usuario["roles"] as List?)?.first?.toString() ?? roles[0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171B1E),
        title: Text(
          usuario["nombre"] ?? "Usuario",
          style: const TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selecciona el nuevo rol:", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: roles.contains(rolSeleccionado) ? rolSeleccionado : roles[0],
                dropdownColor: const Color(0xFF171B1E),
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setStateDialog(() => rolSeleccionado = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D892)),
            onPressed: () {
              Navigator.pop(context);
              cambiarRol(usuario["id"], rolSeleccionado);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _cuadro(String titulo, int valor, String subtitulo, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171B1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text("$valor", style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
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
        title: const Text(
          "Usuarios, roles y permisos",
          style: TextStyle(color: Color(0xFF00D892), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D892)))
          : RefreshIndicator(
              color: const Color(0xFF00D892),
              onRefresh: cargarUsuarios,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // CUADROS RESUMEN
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      children: [
                        _cuadro("Total Usuarios", usuarios.length, "Registrados en el sistema", const Color(0xFF00D892)),
                        _cuadro("Administradores", contarPorRol("Admin"), "Control del sistema", Colors.blueAccent),
                        _cuadro("Responsables", contarPorRol("Responsable"), "Responsables de activos", Colors.orangeAccent),
                        _cuadro("Operativos", contarPorRol("Gestor_Tickets") + contarPorRol("Tecni_Mantenimiento"), "Gestores y técnicos", Colors.purpleAccent),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // FILTROS
                    const Text("Filtrar por rol", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filtros.map((f) {
                          final activo = filtro == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f, style: TextStyle(color: activo ? Colors.black : Colors.white70, fontSize: 12)),
                              selected: activo,
                              selectedColor: const Color(0xFF00D892),
                              backgroundColor: const Color(0xFF171B1E),
                              onSelected: (_) => setState(() => filtro = f),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TÍTULO DIRECTORIO
                    const Text(
                      "Directorio de Usuarios",
                      style: TextStyle(color: Color(0xFF00D892), fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    // LISTA USUARIOS
                    ...usuariosFiltrados.map((u) {
                      final rol = (u["roles"] as List?)?.first?.toString() ?? "Sin rol";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171B1E),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFF00D892),
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u["nombre"] ?? "Sin nombre", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  Text(u["email"] ?? "", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D892).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(rol, style: const TextStyle(color: Color(0xFF00D892), fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF00D892)),
                              onPressed: () => mostrarDialogRol(u),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}