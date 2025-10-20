import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prontuario_app/models/prontuario.dart';

class FirestoreService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'prontuarios',
  );

  Future<void> adicionarProntuario(Prontuario prontuario) async {
    try {
      await _collection.add(prontuario.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar prontuário: $e');
    }
  }

  Future<void> deletarProntuario(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar prontuário: $e');
    }
  }

  Future<void> atualizarProntuario(Prontuario prontuario) async {
    if (prontuario.id == null) {
      throw Exception('Prontuário sem id para atualizar');
    }

    try {
      await _collection.doc(prontuario.id).update(prontuario.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar prontuário: $e');
    }
  }

  Stream<List<Prontuario>> listarProntuarios() {
    return _collection
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Prontuario.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList(),
        );
  }

  Stream<List<Prontuario>> listarProntuariosComFiltro({
    String? pacienteContains,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    Query query = _collection;

    if (dataInicio != null) {
      query = query.where(
        'data',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dataInicio),
      );
    }

    if (dataFim != null) {
      query = query.where(
        'data',
        isLessThanOrEqualTo: Timestamp.fromDate(dataFim),
      );
    }

    query = query.orderBy('data', descending: true);

    return query.snapshots().map((snapshot) {
      var list = snapshot.docs
          .map(
            (doc) =>
                Prontuario.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      if (pacienteContains != null && pacienteContains.trim().isNotEmpty) {
        final q = pacienteContains.toLowerCase();
        list = list.where((p) => p.paciente.toLowerCase().contains(q)).toList();
      }

      return list;
    });
  }

  Future<List<Prontuario>> buscarProntuariosPaginados({
    int pageSize = 10,
    DocumentSnapshot? startAfterDoc,
  }) async {
    try {
      Query query = _collection
          .orderBy('data', descending: true)
          .limit(pageSize);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                Prontuario.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar prontuários paginados: $e');
    }
  }
}
