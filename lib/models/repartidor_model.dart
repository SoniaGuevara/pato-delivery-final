import 'package:equatable/equatable.dart';

class Repartidor extends Equatable {
  final int rank;
  final String nombre;
  final int entregas;
  final double rating;
  final int tiempoPromedio;
  final String avatarUrl;

  const Repartidor({
    required this.rank,
    required this.nombre,
    required this.entregas,
    required this.rating,
    required this.tiempoPromedio,
    required this.avatarUrl,
  });

  Repartidor copyWith({
    int? rank,
    String? nombre,
    int? entregas,
    double? rating,
    int? tiempoPromedio,
    String? avatarUrl,
  }) {
    return Repartidor(
      rank: rank ?? this.rank,
      nombre: nombre ?? this.nombre,
      entregas: entregas ?? this.entregas,
      rating: rating ?? this.rating,
      tiempoPromedio: tiempoPromedio ?? this.tiempoPromedio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [rank, nombre, entregas, rating, tiempoPromedio, avatarUrl];
}
