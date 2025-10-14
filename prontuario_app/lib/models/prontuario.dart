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
      'data': data.toIso8601String(),
    };
  }

  factory Prontuario.fromMap(Map<String, dynamic> map, String id) {
    return Prontuario(
      id: id,
      paciente: map['paciente'] ?? '',
      descricao: map['descricao'] ?? '',
      data: DateTime.parse(map['data']),
    );
  }
}