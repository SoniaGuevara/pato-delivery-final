import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pato_delivery_final/bloc/pedidos/pedidos_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_event.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_state.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';
import 'package:pato_delivery_final/models/repartidor_model.dart';
import 'package:pato_delivery_final/pedidos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pato Delivery'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OrderTrackingCard(),
            const SizedBox(height: 16),
            const DeliveryRankingCard(),
            const SizedBox(height: 16),
            const SuperVelothModeCard(),
            const SizedBox(height: 16),
            const EmergencyButtonCard(),
          ],
        ),
      ),
    );
  }
}

// Componente: OrderTrackingCard
class OrderTrackingCard extends StatelessWidget {
  const OrderTrackingCard({super.key});

  void _marcarComoEntregado(BuildContext context, Pedido pedido) {
    context.read<PedidosBloc>().add(MarcarPedidoEntregado(pedido.id));
    context.read<RankingBloc>().add(const RegistrarEntregaUsuarioActual());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido marcado como entregado')),
    );
  }

  void _abrirDetalle(BuildContext context, Pedido pedido) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PedidoDetalleScreen(pedido: pedido)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidosBloc, PedidosState>(
      buildWhen: (previous, current) =>
          previous.gestionados != current.gestionados,
      builder: (context, state) {
        Pedido? pedidoEnCurso;
        for (final pedido in state.gestionados) {
          if (pedido.estado == 'En curso') {
            pedidoEnCurso = pedido;
            break;
          }
        }

        return Card(
          elevation: 2,
          color: Colors.amber,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Seguimiento de Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (pedidoEnCurso == null) ...[
                  const Text(
                    'No tienes pedidos en camino',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Acepta un pedido desde la pestaña Pedidos para ver el seguimiento aquí.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ] else ...[
                  Text(
                    pedidoEnCurso.restaurante,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedidoEnCurso.direccion,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.black,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tiempo estimado: 15 minutos',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _abrirDetalle(context, pedidoEnCurso!),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ver detalles'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.amber,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _marcarComoEntregado(context, pedidoEnCurso!),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Marcar entregado'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Componente: DeliveryRankingCard
class DeliveryRankingCard extends StatelessWidget {
  const DeliveryRankingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                const Text('Ranking de Repartidores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<RankingBloc, RankingState>(
              builder: (context, state) {
                if (state is RankingCargando || state is RankingInicial) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is RankingCargado) {
                  final topTres = state.resumen.topTres;

                  if (topTres.length < 3) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Aún no hay suficientes datos para mostrar el ranking.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  const medals = ['🥇', '🥈', '🥉'];

                  return Column(
                    children: List.generate(
                      3,
                      (index) => _buildRankItem(medals[index], topTres[index]),
                    ),
                  );
                } else if (state is RankingError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      state.mensaje,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(String medal, Repartidor repartidor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              repartidor.nombre,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          Text(
            '${repartidor.rating.toStringAsFixed(1)} ⭐',
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// Componente: SuperVelothModeCard
class SuperVelothModeCard extends StatelessWidget {
  const SuperVelothModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.flash_on, color: Colors.black, size: 48),
            const SizedBox(height: 12),
            const Text(
              'MODO SUPER VELOZ',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Entregas en tiempo récord!',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.amber,
              ),
              child: const Text('Activar Modo'),
            ),
          ],
        ),
      ),
    );
  }
}

// Componente: EmergencyButtonCard
class EmergencyButtonCard extends StatelessWidget {
  const EmergencyButtonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.black, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Botón de Emergencia',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Presiona en caso de emergencia',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
