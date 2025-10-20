import 'package:cloud_firestore/cloud_firestore.dart';

class Prontuario {
  final String? id;
  final String paciente;
  final String descricao;
  final DateTime data;

  Prontuario({
    this.id,
    required this.paciente,
    required this.descricao,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'paciente': paciente,
      'descricao': descricao,
      'data': Timestamp.fromDate(data),
    };
  }

  factory Prontuario.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    final raw = map['data'];

    if (raw is Timestamp) {
      parsedDate = raw.toDate();
    } else if (raw is String) {
      parsedDate = DateTime.parse(raw);
    } else {
      parsedDate = DateTime.now();
    }

    return Prontuario(
      id: id,
      paciente: map['paciente'] ?? '',
      descricao: map['descricao'] ?? '',
      data: parsedDate,
    );
  }
}
