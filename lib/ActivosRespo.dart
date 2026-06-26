import 'package:flutter/material.dart';

class ActivosRespo extends StatelessWidget {
  final List activos;

  const ActivosRespo({super.key, required this.activos});

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
          "Mis Activos",
          style: TextStyle(color: Color(0xFF00D892)),
        ),
      ),

      body: activos.isEmpty
          ? const Center(
              child: Text(
                "Sin activos asignados",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: activos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final a = activos[index];

                // ✅ campos reales del modelo Activo.java
                final titulo = a["titulo"] ?? "Sin título";
                final tipo = a["tipo"] ?? "";
                final estado = a["estado"] ?? "";
                final imagen = a["img"] ?? "";

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF171B1E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: imagen.isNotEmpty
                              ? Image.network(
                                  imagen,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.computer,
                                    color: Color(0xFF00D892),
                                    size: 60,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.computer,
                                    color: Color(0xFF00D892),
                                    size: 60,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                        child: Text(
                          titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        tipo,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      if (estado.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, top: 2),
                          child: Text(
                            estado,
                            style: const TextStyle(
                              color: Color(0xFF00D892),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                    ],
                  ),
                );
              },
            ),
    );
  }
}