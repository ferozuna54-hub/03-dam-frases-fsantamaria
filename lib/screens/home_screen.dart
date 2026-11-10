import 'package:flutter/material.dart';
import 'package:frases_app/data/frases_db.dart';
import 'package:frases_app/models/frase.dart';
import 'formulario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Frase>> _frasesFuture;

  @override
  void initState() {
    super.initState();
    _cargarFrases();
  }

  void _cargarFrases() {
    setState(() {
      _frasesFuture = FrasesDb.instancia.obtenerTodas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Frases'),
      ),
      body: FutureBuilder<List<Frase>>(
        future: _frasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay frases guardadas. ¡Agrega una!'),
            );
          }

          final frases = snapshot.data!;
          return ListView.builder(
            itemCount: frases.length,
            itemBuilder: (context, index) {
              final frase = frases[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '"${frase.frase}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('- ${frase.autor}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormularioScreen(frase: frase),
                            ),
                          );
                          if (resultado == true) {
                            _cargarFrases();
                          }
                        },
                      ),
                      // Botón Eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (frase.id != null) {
                            await FrasesDb.instancia.eliminar(frase.id!);
                            _cargarFrases();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioScreen()),
          );
          if (resultado == true) {
            _cargarFrases();
          }
        },
      ),
    );
  }
}