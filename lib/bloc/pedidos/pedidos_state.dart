import 'package:equatable/equatable.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';

class PedidosState extends Equatable {
  final List<Pedido> pendientes;
  final List<Pedido> gestionados;
  final bool cargando;
  final String? mensajeError;

  const PedidosState({
    this.pendientes = const [],
    this.gestionados = const [],
    this.cargando = true,
    this.mensajeError,
  });

  PedidosState copyWith({
    List<Pedido>? pendientes,
    List<Pedido>? gestionados,
    bool? cargando,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return PedidosState(
      pendientes: pendientes ?? this.pendientes,
      gestionados: gestionados ?? this.gestionados,
      cargando: cargando ?? this.cargando,
      mensajeError: limpiarError ? null : (mensajeError ?? this.mensajeError),
    );
  }

  @override
  List<Object?> get props => [pendientes, gestionados, cargando, mensajeError];
}
