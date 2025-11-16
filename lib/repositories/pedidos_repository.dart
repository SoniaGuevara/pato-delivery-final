import 'dart:async';
import 'dart:math';

import 'package:pato_delivery_final/models/pedido_model.dart';

/// Repositorio responsable de obtener la información de los pedidos.
///
/// Mientras llega la integración con un backend real exponemos un stream que
/// va generando pedidos simulados para ejercitar la lógica de aceptación o
/// rechazo dentro de la app.
class PedidosRepository {
  PedidosRepository();

  final _random = Random();

  Stream<Pedido> escucharPedidosEntrantes() async* {
    var index = 0;
    // Se emite un primer pedido rápidamente para que la pantalla no quede vacía
    // al iniciar.
    await Future.delayed(const Duration(seconds: 2));
    while (true) {
      final base = _pedidosSimulados[index % _pedidosSimulados.length];
      final totalAleatorio = base.total + _random.nextDouble() * 5;
      yield base.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        estado: 'Pendiente',
        repartidor: 'Por asignar',
        total: double.parse(totalAleatorio.toStringAsFixed(2)),
      );
      index++;
      final waitTime = 5 + _random.nextInt(6); // Entre 5 y 10 segundos
      await Future.delayed(Duration(seconds: waitTime));
    }
  }

  static const List<Pedido> _pedidosSimulados = [
    Pedido(
      id: '001',
      restaurante: 'Restaurante El Pato Feliz',
      items: ['Hamburguesa', 'Papas Fritas', 'Gaseosa'],
      estado: 'Entregado',
      direccion: 'Calle 123 #45-67',
      repartidor: 'Carlos Pérez',
      calificacion: 4.8,
      total: 25.0,
    ),
    Pedido(
      id: '002',
      restaurante: 'Sushi Zen',
      items: ['Roll California', 'Miso Soup'],
      estado: 'En camino',
      direccion: 'Av. Central 45',
      repartidor: 'Laura Gómez',
      calificacion: 4.5,
      total: 32.0,
    ),
    Pedido(
      id: '003',
      restaurante: 'Pizza Capital',
      items: ['Pepperoni', 'Bebida'],
      estado: 'Listo',
      direccion: 'Cra 10 #54-20',
      repartidor: 'Luis Martínez',
      calificacion: 4.7,
      total: 28.0,
    ),
  ];
}
