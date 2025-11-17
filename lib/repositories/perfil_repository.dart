import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pato_delivery_final/models/perfil_usuario.dart';

class PerfilRepository {
  PerfilRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('repartidores');

  Future<void> ensurePerfilExiste({
    required String uid,
    required String email,
  }) async {
    final doc = _collection.doc(uid);
    final snapshot = await doc.get();
    if (snapshot.exists) return;

    await doc.set({
      'fullName': 'Nuevo repartidor',
      'dni': '',
      'phone': '',
      'photoUrl': '',
      'rating': 5.0,
      'totalDeliveries': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'availability': 'online',
      'email': email,
    });
  }

  Stream<PerfilUsuario> escucharPerfil(String uid) {
    return _collection.doc(uid).snapshots().map(PerfilUsuario.fromSnapshot);
  }

  Future<void> actualizarPerfil(String uid, Map<String, dynamic> data) async {
    final payload = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _collection.doc(uid).set(payload, SetOptions(merge: true));
  }

  Future<void> actualizarDisponibilidad(String uid, String disponibilidad) {
    return actualizarPerfil(uid, {'availability': disponibilidad});
  }

  Future<void> incrementarEntregas(String uid) async {
    await _collection.doc(uid).update({
      'totalDeliveries': FieldValue.increment(1),
    });
  }

  Future<String> subirFotoPerfil({
    required String uid,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final ref = _storage
        .ref()
        .child('profile_photos/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/$extension'));
    return ref.getDownloadURL();
  }
}
