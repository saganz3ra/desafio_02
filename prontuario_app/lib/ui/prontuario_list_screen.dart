import 'package:flutter/material.dart';
import 'package:prontuario_app/models/prontuario.dart';
import 'package:prontuario_app/services/firestore_service.dart';
import 'formulario_prontuario_screen.dart';

class ProntuarioListScreen extends StatelessWidget {
  const ProntuarioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Prontuários')),
      body: StreamBuilder<List<Prontuario>>(
        stream: service.listarProntuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum prontuário cadastrado.'));
          }

          final prontuarios = snapshot.data!;

          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final p = prontuarios[index];
              return ListTile(
                title: Text(p.paciente),
                subtitle: Text(p.descricao),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${p.data.day}/${p.data.month}/${p.data.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('Excluir este prontuário?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && p.id != null) {
                          try {
                            await service.deletarProntuario(p.id!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prontuário excluído'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao excluir: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool?>(
            context,
            MaterialPageRoute(
              builder: (_) => const FormularioProntuarioScreen(),
            ),
          );

          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prontuário salvo com sucesso!')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
