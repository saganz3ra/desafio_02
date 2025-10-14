import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prontuario_app/models/prontuario.dart';

class FirestoreService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'prontuarios',
  );

  // 🟢 Adicionar novo prontuário
  Future<void> adicionarProntuario(Prontuario prontuario) async {
    try {
      await _collection.add(prontuario.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar prontuário: $e');
    }
  }

  // 🔴 Deletar prontuário por ID
  Future<void> deletarProntuario(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar prontuário: $e');
    }
  }

  // 🟣 Listar prontuários em tempo real (Stream)
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
}
