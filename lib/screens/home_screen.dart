import 'package:flutter/material.dart';
import '../data/frases_db.dart';
import '../models/frase.dart';
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
      _frasesFuture = FrasesDatabase.instance.getFrases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frases App'),
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
              return ListTile(
                title: Text(frase.texto),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (frase.id != null) {
                      await FrasesDatabase.instance.deleteFrase(frase.id!);
                      _cargarFrases();
                    }
                  },
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