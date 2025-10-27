import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prontuario_app/models/prontuario.dart';
import 'package:prontuario_app/services/firestore_service.dart';

class FormularioProntuarioScreen extends StatefulWidget {
  final Prontuario? prontuario;

  const FormularioProntuarioScreen({super.key, this.prontuario});

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
  bool _isSaving = false;

  bool get isEdit => widget.prontuario != null;

  @override
  void dispose() {
    _pacienteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _pacienteController.text = widget.prontuario!.paciente;
      _descricaoController.text = widget.prontuario!.descricao;
    }
  }

  Future<void> _salvarProntuario() async {
    if (!_formKey.currentState!.validate()) return;

    final prontuario = Prontuario(
      id: widget.prontuario?.id,
      paciente: _pacienteController.text.trim(),
      descricao: _descricaoController.text.trim(),
      data: widget.prontuario?.data ?? DateTime.now(),
    );

    setState(() => _isSaving = true);

    try {
      if (isEdit) {
        await _service
            .atualizarProntuario(prontuario)
            .timeout(const Duration(seconds: 12));
      } else {
        await _service
            .adicionarProntuario(prontuario)
            .timeout(const Duration(seconds: 12));
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (e is TimeoutException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tempo excedido ao salvar. Tente novamente.'),
            ),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                  label: _isSaving
                      ? const Text('Salvando...')
                      : const Text('Salvar'),
                  onPressed: _isSaving ? null : _salvarProntuario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
