import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sigma_flutter/ActivosRespo.dart';

class Responsable extends StatefulWidget {
  final String userId;

  const Responsable({super.key, required this.userId});

  @override
  State<Responsable> createState() => _ResponsableState();
}

class _ResponsableState extends State<Responsable> {
  String nombreUsuario = "";
  List tickets = [];
  List activos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final activosRes = await http.get(
        Uri.parse("http://localhost:8080/api/activos"),
      );
      final usuariosRes = await http.get(
        Uri.parse("http://localhost:8080/api/usuarios"),
      );
      final ticketsRes = await http.get(
        Uri.parse("http://localhost:8080/api/tickets"),
      );

      if (ticketsRes.statusCode == 200 &&
          activosRes.statusCode == 200 &&
          usuariosRes.statusCode == 200) {

        final List todosTickets = jsonDecode(ticketsRes.body);
        final List todosActivos = jsonDecode(activosRes.body);
        final List todosUsuarios = jsonDecode(usuariosRes.body);

        // Buscar usuario por email
        final usuario = todosUsuarios.firstWhere(
          (u) => u["email"] == widget.userId,
          orElse: () => null,
        );

        final nombre = usuario != null ? (usuario["nombre"] ?? "") : "";
        final nombreCorto = nombre.split(" ").first.toLowerCase();
        final uuidUsuario = usuario != null ? (usuario["id"] ?? "") : "";

        // Filtrar activos: responsable puede ser nombre corto, email o uuid
        final activosDelUsuario = todosActivos.where((a) {
          final r = (a["responsable"] ?? "").toString().toLowerCase();
          return r == widget.userId.toLowerCase() ||
                 r == nombreCorto ||
                 r == uuidUsuario;
        }).toList();

        // Filtrar tickets: asignadoId puede ser email o uuid
        final ticketsDelUsuario = todosTickets.where((t) {
          final asig = (t["asignadoId"] ?? "").toString();
          return asig == widget.userId || asig == uuidUsuario;
        }).toList();

        setState(() {
          tickets = ticketsDelUsuario;
          activos = activosDelUsuario;
          nombreUsuario = nombre;
          loading = false;
        });

      } else {
        debugPrint("Error tickets: ${ticketsRes.statusCode}");
        debugPrint("Error activos: ${activosRes.statusCode}");
        debugPrint("Error usuarios: ${usuariosRes.statusCode}");
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint("Error cargarDatos: $e");
      setState(() => loading = false);
    }
  }

  Color colorEstado(String? estado) {
    switch (estado) {
      case "Abierto":
        return Colors.redAccent;
      case "En progreso":
        return Colors.orange;
      case "Cerrado":
        return Colors.green;
      default:
        return Colors.grey;
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
        title: Text(
          nombreUsuario.isEmpty ? "Cargando..." : nombreUsuario,
          style: const TextStyle(
            color: Color(0xFF00D892),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D892)),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171B1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.person, color: Color(0xFF00D892), size: 50),
                        const SizedBox(height: 10),
                        Text(
                          nombreUsuario.isEmpty ? "Sin nombre" : nombreUsuario,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${tickets.length} Tickets  |  ${activos.length} Activos",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mis Tickets",
                      style: TextStyle(
                        color: Color(0xFF00D892),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LISTA TICKETS
                  Expanded(
                    child: tickets.isEmpty
                        ? const Center(
                            child: Text(
                              "Sin tickets asignados",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tickets.length,
                            itemBuilder: (context, index) {
                              final t = tickets[index];

                              final titulo = t["tit"] ?? "Sin título";
                              final estado = (t["est"] ?? "—").toString();
                              final tipo = (t["tip"] ?? "").toString();
                              final id = (t["id"] ?? "").toString();
                              final idCorto = id.length >= 6
                                  ? id.substring(0, 6)
                                  : id;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF171B1E),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.confirmation_num,
                                    color: Color(0xFF00D892),
                                  ),
                                  title: Text(
                                    titulo,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "#$idCorto",
                                        style: const TextStyle(color: Colors.white54),
                                      ),
                                      if (tipo.isNotEmpty)
                                        Text(
                                          tipo,
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorEstado(estado),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      estado,
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

                  const SizedBox(height: 10),

                  // BOTÓN ACTIVOS
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.computer),
                      label: const Text("VER ACTIVOS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D892),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivosRespo(activos: activos),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}