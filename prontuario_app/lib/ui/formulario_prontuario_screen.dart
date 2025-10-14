import 'package:flutter/material.dart';
import 'package:prontuario_app/models/prontuario.dart';
import 'package:prontuario_app/services/firestore_service.dart';
import 'prontuario_list_screen.dart';

class FormularioProntuarioScreen extends StatefulWidget {
  const FormularioProntuarioScreen({super.key});

  @override
  State<FormularioProntuarioScreen> createState() =>
      _FormularioProntuarioScreenState();
}

class _FormularioProntuarioScreenState
    extends State<FormularioProntuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pacienteController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _service = FirestoreService();

  @override
  void dispose() {
    _pacienteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarProntuario() async {
    if (_formKey.currentState!.validate()) {
      final prontuario = Prontuario(
        paciente: _pacienteController.text.trim(),
        descricao: _descricaoController.text.trim(),
        data: DateTime.now(),
      );

      try {
        await _service.adicionarProntuario(prontuario);

        if (!mounted) return;

        // Redireciona para a tela principal (ProntuarioListScreen) e limpa a pilha
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProntuarioListScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Prontuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _pacienteController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Paciente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  onPressed: _salvarProntuario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
