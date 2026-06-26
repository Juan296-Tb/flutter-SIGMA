import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sigma_flutter/login.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final telefono = TextEditingController();
  final empresa = TextEditingController();
  final documento = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool loading = false;
  bool ocultarPassword = true;
  bool ocultarConfirmPassword = true;

  String tipoDocumento = "CC";

  final List<String> tiposDocumento = [
    "CC",
    "TI",
    "CE",
    "PASAPORTE",
  ];

  Future<void> registrarFake() async {
    if (nombre.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      _msg("Error", "Completa los campos obligatorios");
      return;
    }

    if (password.text != confirmPassword.text) {
      _msg("Error", "Las contraseñas no coinciden");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:8080/api/usuarios/registrar",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "nombre": nombre.text.trim(),
          "email": email.text.trim(),
          "telefono": telefono.text.trim(),
          "empresa": empresa.text.trim(),
          "usuario": email.text.trim(),
          "password": password.text,
          "documento": {
            "tipo": tipoDocumento,
            "numero": documento.text.trim(),
          }
        }),
      );

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Registro exitoso"),
            content: const Text(
              "Usuario creado correctamente",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Login(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        print(response.body);

        _msg(
          "Error",
          "No fue posible registrar el usuario",
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      _msg(
        "Error",
        "No se pudo conectar con el servidor\n$e",
      );
    }
  }

  void _msg(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget campo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool esPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: esPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F151A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "REGISTRO",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF00D892),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              campo(
                label: "Nombre",
                controller: nombre,
                icon: Icons.person,
              ),

              campo(
                label: "Email",
                controller: email,
                icon: Icons.email,
              ),

              campo(
                label: "Teléfono",
                controller: telefono,
                icon: Icons.phone,
              ),

              campo(
                label: "Empresa",
                controller: empresa,
                icon: Icons.business,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: tipoDocumento,
                  dropdownColor: const Color(0xFF171B1E),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "Tipo de documento",
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.badge,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  items: tiposDocumento.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      tipoDocumento = value!;
                    });
                  },
                ),
              ),

              campo(
                label: "Número de documento",
                controller: documento,
                icon: Icons.credit_card,
              ),

              campo(
                label: "Contraseña",
                controller: password,
                icon: Icons.lock,
                esPassword: true,
                obscureText: ocultarPassword,
                onToggle: () {
                  setState(() {
                    ocultarPassword = !ocultarPassword;
                  });
                },
              ),

              campo(
                label: "Confirmar contraseña",
                controller: confirmPassword,
                icon: Icons.lock_outline,
                esPassword: true,
                obscureText: ocultarConfirmPassword,
                onToggle: () {
                  setState(() {
                    ocultarConfirmPassword =
                        !ocultarConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : registrarFake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF00D892),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text(
                          "CREAR CUENTA",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}