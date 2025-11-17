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
            const GamificationBanner(),
            const SizedBox(height: 16),
            const DeliveryRankingCard(),
            const SizedBox(height: 16),
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

class GamificationBanner extends StatelessWidget {
  const GamificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingBloc, RankingState>(
      builder: (context, state) {
        if (state is! RankingCargado) {
          return const _GamificationSkeleton();
        }

        final usuario = state.resumen.usuarioActual;
        const metaSemanal = 20;
        final entregasSemana = usuario.entregas % metaSemanal;
        final faltan = entregasSemana == 0 && usuario.entregas < metaSemanal
            ? metaSemanal
            : (metaSemanal - entregasSemana) % metaSemanal;
        final streakDias = (usuario.entregas ~/ 3).clamp(1, 7);
        final logroRapido = usuario.tiempoPromedio <= 25;
        final logroTitulo = logroRapido ? 'Repartidor Rápido' : 'Ritmo Constante';
        final logroDescripcion = logroRapido
            ? 'Promedio de ${usuario.tiempoPromedio} min por entrega'
            : 'Objetivo: bajar de ${usuario.tiempoPromedio} min';

        final tiles = [
          _MotivationTile(
            icon: Icons.flag_rounded,
            accent: Colors.amber,
            background: const Color(0xFF111111),
            title: 'Tu meta semanal',
            highlight: '$metaSemanal entregas',
            subtitle: faltan == 0
                ? '¡Meta alcanzada, crack!'
                : faltan == 1
                    ? '¡Solo 1 entrega más!'
                    : '¡Faltan $faltan para lograrlo!',
          ),
          _MotivationTile(
            icon: Icons.flash_on_rounded,
            accent: const Color(0xFF00E5FF),
            background: const Color(0xFF0D0D0D),
            title: 'Racha activa',
            highlight: '$streakDias días seguidos',
            subtitle: 'Seguí así para sumar bonos',
          ),
          _MotivationTile(
            icon: Icons.star_rounded,
            accent: const Color(0xFFFFF176),
            background: const Color(0xFF141414),
            title: 'Nuevo logro',
            highlight: logroTitulo,
            subtitle: logroDescripcion,
          ),
        ];

        return _GamificationFrame(children: tiles);
      },
    );
  }
}

class _GamificationSkeleton extends StatelessWidget {
  const _GamificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return _GamificationFrame(
      children: const [
        _MotivationTile.skeleton(),
        _MotivationTile.skeleton(),
        _MotivationTile.skeleton(),
      ],
    );
  }
}

class _GamificationFrame extends StatelessWidget {
  final List<_MotivationTile> children;

  const _GamificationFrame({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Tu semana en modo pro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      for (int i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i != children.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Row(
                  children: children
                      .map(
                        (tile) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: tile,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String highlight;
  final String subtitle;
  final Color background;
  final Color accent;
  final bool showContent;

  const _MotivationTile({
    super.key,
    this.icon = Icons.shield_moon,
    this.title = '',
    this.highlight = '',
    this.subtitle = '',
    this.background = const Color(0xFF1A1A1A),
    this.accent = Colors.amber,
  }) : showContent = true;

  const _MotivationTile.skeleton({super.key})
      : icon = Icons.hourglass_bottom,
        title = '',
        highlight = '',
        subtitle = '',
        background = const Color(0xFF1A1A1A),
        accent = Colors.amber,
        showContent = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        color: background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: showContent
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.black, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        highlight,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                )
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                _SkeletonCircle(),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(widthFactor: 0.35),
                      SizedBox(height: 6),
                      _SkeletonLine(widthFactor: 0.75),
                      SizedBox(height: 4),
                      _SkeletonLine(widthFactor: 0.55),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double widthFactor;

  const _SkeletonLine({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white10,
        ),
      ),
    );
  }
}
