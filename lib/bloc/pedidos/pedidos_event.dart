import 'package:equatable/equatable.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';

abstract class PedidosEvent extends Equatable {
  const PedidosEvent();

  @override
  List<Object?> get props => [];
}

class SuscribirsePedidos extends PedidosEvent {
  const SuscribirsePedidos();
}

class PedidoRecibido extends PedidosEvent {
  final Pedido pedido;

  const PedidoRecibido(this.pedido);

  @override
  List<Object?> get props => [pedido];
}

class AceptarPedido extends PedidosEvent {
  final Pedido pedido;

  const AceptarPedido(this.pedido);

  @override
  List<Object?> get props => [pedido];
}

class RechazarPedido extends PedidosEvent {
  final Pedido pedido;

  const RechazarPedido(this.pedido);

  @override
  List<Object?> get props => [pedido];
}

class PedidosStreamError extends PedidosEvent {
  const PedidosStreamError();
}
