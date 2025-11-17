import 'package:equatable/equatable.dart';

class Pedido extends Equatable {
  final String id;
  final String restaurante;
  final List<String> items;
  final String estado;
  final String direccion;
  final String repartidor;
  final double calificacion;
  final double total;

  const Pedido({
    required this.id,
    required this.restaurante,
    required this.items,
    required this.estado,
    required this.direccion,
    required this.repartidor,
    required this.calificacion,
    required this.total,
  });

  Pedido copyWith({
    String? id,
    String? restaurante,
    List<String>? items,
    String? estado,
    String? direccion,
    String? repartidor,
    double? calificacion,
    double? total,
  }) {
    return Pedido(
      id: id ?? this.id,
      restaurante: restaurante ?? this.restaurante,
      items: items ?? this.items,
      estado: estado ?? this.estado,
      direccion: direccion ?? this.direccion,
      repartidor: repartidor ?? this.repartidor,
      calificacion: calificacion ?? this.calificacion,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [id, restaurante, estado, direccion, repartidor, total];
}
