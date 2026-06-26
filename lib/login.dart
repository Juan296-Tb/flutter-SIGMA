import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'registro.dart';
import 'responsable.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  bool ocultarPassword = true;
  bool loading = false;

  Future<void> loginFake() async {
    final usuario = usuarioController.text.trim();
    final password = passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      dialog("Campos vacíos", "Debes completar usuario y contraseña");
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "usuario": usuario,
          "password": password,
        }),
      );

      setState(() => loading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        dialog("Error", data["mensaje"] ?? "Error de login");
        return;
      }

      // 🔥 ID DEL USUARIO (CLAVE PARA TU RESPONSABLE)
      final userId = data["usuario"]; // o cambia a data["id"] si tu backend lo tiene

      // 🔥 ROLES
      final List<String> roles =
          List<String>.from(data["roles"] ?? []);

      final rolesNormalizados =
          roles.map((e) => e.toUpperCase().trim()).toList();

      print("RESPUESTA LOGIN: $data");
      print("ROLES: $roles");

      // 🔥 NAVIGACIÓN
      if (rolesNormalizados.contains("RESPONSABLE")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Responsable(
              userId: userId.toString(),
            ),
          ),
        );
      } 
      else if (rolesNormalizados.contains("ADMIN")) {
        dialog("Login exitoso", "Bienvenido Admin");
      } 
      else if (rolesNormalizados.contains("GESTOR_TICKETS")) {
        dialog("Login exitoso", "Bienvenido Gestor");
      } 
      else if (rolesNormalizados.contains("TECNI_MANTENIMIENTO")) {
        dialog("Login exitoso", "Bienvenido Técnico");
      } 
      else {
        dialog("Error", "Rol no reconocido: $roles");
      }

    } catch (e) {
      setState(() => loading = false);
      dialog("Error de conexión", e.toString());
    }
  }

  void dialog(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F151A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xff171B1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const SizedBox(height: 25),

                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Color(0xff00A86B),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/imagenes/logo.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Sistema Integral de Gestión y Monitoreo de Activos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff00D892),
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextField(
                    controller: usuarioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Usuario",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: ocultarPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          ocultarPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            ocultarPassword = !ocultarPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : loginFake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00D892),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "INGRESAR",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Registro(),
                        ),
                      );
                    },
                    child: const Text(
                      "¿No tienes cuenta? Regístrate",
                      style: TextStyle(color: Color(0xff00D892)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}