import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';
import 'package:pato_delivery_final/repositories/pedidos_repository.dart';

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  PedidosBloc(this._pedidosRepository) : super(const PedidosState()) {
    on<SuscribirsePedidos>(_onSuscribirsePedidos);
    on<PedidoRecibido>(_onPedidoRecibido);
    on<AceptarPedido>(_onAceptarPedido);
    on<RechazarPedido>(_onRechazarPedido);
    on<PedidosStreamError>(_onErrorStream);
  }

  final PedidosRepository _pedidosRepository;
  StreamSubscription<Pedido>? _pedidosSubscription;

  Future<void> _onSuscribirsePedidos(
      SuscribirsePedidos event, Emitter<PedidosState> emit) async {
    emit(state.copyWith(cargando: true, limpiarError: true));
    await _pedidosSubscription?.cancel();
    _pedidosSubscription = _pedidosRepository.escucharPedidosEntrantes().listen(
      (pedido) => add(PedidoRecibido(pedido)),
      onError: (_) => add(const PedidosStreamError()),
    );
    emit(state.copyWith(cargando: false));
  }

  void _onPedidoRecibido(
      PedidoRecibido event, Emitter<PedidosState> emit) {
    final updatedPendientes = List<Pedido>.from(state.pendientes)
      ..add(event.pedido);
    emit(state.copyWith(pendientes: updatedPendientes));
  }

  void _onAceptarPedido(AceptarPedido event, Emitter<PedidosState> emit) {
    _gestionarPedido(event.pedido, 'Aceptado', emit);
  }

  void _onRechazarPedido(RechazarPedido event, Emitter<PedidosState> emit) {
    _gestionarPedido(event.pedido, 'Rechazado', emit);
  }


    try {
      final pedidos = await _pedidosRepository.obtenerPedidos();
      emit(PedidosCargados(pedidos));
    } catch (e) {
      emit(PedidosError('Error al cargar los pedidos'));
    }
    emit(state.copyWith(pendientes: pendientes, gestionados: gestionados));
  }

  void _onErrorStream(PedidosStreamError event, Emitter<PedidosState> emit) {
    emit(state.copyWith(
      cargando: false,
      mensajeError: 'Error al escuchar pedidos entrantes',
    ));
  }

  @override
  Future<void> close() {
    _pedidosSubscription?.cancel();
    return super.close();
  }

}
