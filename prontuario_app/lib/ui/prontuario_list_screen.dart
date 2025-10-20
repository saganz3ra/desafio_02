import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prontuario_app/models/prontuario.dart';
import 'package:prontuario_app/services/firestore_service.dart';
import 'formulario_prontuario_screen.dart';

class ProntuarioListScreen extends StatefulWidget {
  const ProntuarioListScreen({super.key});

  @override
  State<ProntuarioListScreen> createState() => _ProntuarioListScreenState();
}

class _ProntuarioListScreenState extends State<ProntuarioListScreen> {
  final _service = FirestoreService();
  final _pacienteFilterController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;

  DocumentSnapshot? _lastDocument;
  bool _isLoadingPage = false;

  final List<Prontuario> _paginaAcumulada = [];

  @override
  void dispose() {
    _pacienteFilterController.dispose();
    super.dispose();
  }

  Future<void> _carregarProximaPagina() async {
    if (_isLoadingPage) return;
    setState(() => _isLoadingPage = true);

    try {
      final page = await _service.buscarProntuariosPaginados(
        pageSize: 10,
        startAfterDoc: _lastDocument,
      );

      if (page.isNotEmpty) {
        _paginaAcumulada.addAll(page);
        final snapshot = await FirebaseFirestore.instance
            .collection('prontuarios')
            .orderBy('data', descending: true)
            .limit(_paginaAcumulada.length)
            .get();

        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
        }

        setState(() {});
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum mais prontuário')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar página: $e')));
      }
    } finally {
      setState(() => _isLoadingPage = false);
    }
  }

  Future<void> _abrirFormulario({Prontuario? prontuario}) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioProntuarioScreen(prontuario: prontuario),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prontuário salvo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prontuários')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pacienteFilterController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por paciente',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final pickedStart = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedStart != null) {
                      setState(() => _dataInicio = pickedStart);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: () {
                    _dataInicio = null;
                    _dataFim = null;
                    _pacienteFilterController.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Prontuario>>(
                stream: _service.listarProntuariosComFiltro(
                  pacienteContains: _pacienteFilterController.text,
                  dataInicio: _dataInicio,
                  dataFim: _dataFim,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Nenhum prontuário cadastrado.'),
                    );
                  }

                  final prontuarios = snapshot.data!;

                  return ListView.builder(
                    itemCount: prontuarios.length,
                    itemBuilder: (context, index) {
                      final p = prontuarios[index];
                      return ListTile(
                        title: Text(p.paciente),
                        subtitle: Text(p.descricao),
                        onTap: () => _abrirFormulario(prontuario: p),
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
                                    content: const Text(
                                      'Excluir este prontuário?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && p.id != null) {
                                  try {
                                    await _service.deletarProntuario(p.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Prontuário excluído'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro ao excluir: $e'),
                                      ),
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
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingPage ? null : _carregarProximaPagina,
                child: _isLoadingPage
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Carregar mais'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
