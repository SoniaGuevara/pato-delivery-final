import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PerfilUsuario extends Equatable {
  const PerfilUsuario({
    required this.id,
    required this.nombreCompleto,
    required this.dni,
    required this.telefono,
    required this.fotoUrl,
    required this.rating,
    required this.totalEntregas,
    required this.fechaRegistro,
    required this.disponibilidad,
    required this.email,
  });

  final String id;
  final String nombreCompleto;
  final String dni;
  final String telefono;
  final String fotoUrl;
  final double rating;
  final int totalEntregas;
  final DateTime fechaRegistro;
  final String disponibilidad;
  final String email;

  factory PerfilUsuario.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    DateTime? fecha;
    if (timestamp is Timestamp) {
      fecha = timestamp.toDate();
    } else if (timestamp is DateTime) {
      fecha = timestamp;
    }
    return PerfilUsuario(
      id: doc.id,
      nombreCompleto: (data['fullName'] as String?)?.trim().isNotEmpty == true
          ? data['fullName'] as String
          : 'Repartidor Pato',
      dni: data['dni'] as String? ?? '',
      telefono: data['phone'] as String? ?? '',
      fotoUrl: data['photoUrl'] as String? ?? '',
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] as num?)?.toDouble() ?? 5.0,
      totalEntregas: (data['totalDeliveries'] as num?)?.toInt() ?? 0,
      fechaRegistro: fecha ?? DateTime.now(),
      disponibilidad: data['availability'] as String? ?? 'online',
      email: data['email'] as String? ?? '',
    );
  }

  PerfilUsuario copyWith({
    String? nombreCompleto,
    String? dni,
    String? telefono,
    String? fotoUrl,
    double? rating,
    int? totalEntregas,
    DateTime? fechaRegistro,
    String? disponibilidad,
    String? email,
  }) {
    return PerfilUsuario(
      id: id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      rating: rating ?? this.rating,
      totalEntregas: totalEntregas ?? this.totalEntregas,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      disponibilidad: disponibilidad ?? this.disponibilidad,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': nombreCompleto,
      'dni': dni,
      'phone': telefono,
      'photoUrl': fotoUrl,
      'rating': rating,
      'totalDeliveries': totalEntregas,
      'createdAt': fechaRegistro,
      'availability': disponibilidad,
      'email': email,
    };
  }

  bool get tieneFoto => fotoUrl.isNotEmpty;

  String get disponibilidadLegible {
    switch (disponibilidad) {
      case 'online':
        return 'Disponible';
      case 'busy':
        return 'Ocupado';
      case 'offline':
        return 'Fuera de servicio';
      default:
        return disponibilidad;
    }
  }

  @override
  List<Object?> get props => [
        id,
        nombreCompleto,
        dni,
        telefono,
        fotoUrl,
        rating,
        totalEntregas,
        fechaRegistro,
        disponibilidad,
        email,
      ];
}
