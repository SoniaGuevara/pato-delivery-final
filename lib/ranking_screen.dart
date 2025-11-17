import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_state.dart';
import 'package:pato_delivery_final/models/ranking_resumen.dart';
import 'package:pato_delivery_final/models/repartidor_model.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFD700);
    final backgroundColor = Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<RankingBloc, RankingState>(
          builder: (context, state) {
            if (state is RankingCargando || state is RankingInicial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RankingCargado) {
              return RankingContent(goldColor: goldColor, resumen: state.resumen);
            } else if (state is RankingError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class RankingContent extends StatelessWidget {
  const RankingContent({
    super.key,
    required this.goldColor,
    required this.resumen,
  });

  final Color goldColor;
  final RankingResumen resumen;

  @override
  Widget build(BuildContext context) {
    final repartidores = resumen.repartidores;
    final topTres = resumen.topTres;
    final resto = resumen.resto;

    if (repartidores.isEmpty) {
      return const Center(
        child: Text(
          'Aún no hay datos de ranking disponibles',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: [
        const _RankingHeader(),
        if (topTres.length == 3)
          _PodiumWidget(repartidores: topTres)
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Necesitamos al menos tres repartidores para mostrar el podio.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: resto.length,
            itemBuilder: (context, index) {
              final repartidor = resto[index];
              return _RankingListItem(repartidor: repartidor);
            },
          ),
        ),
        _YourPositionBar(usuarioActual: resumen.usuarioActual, goldColor: goldColor),
      ],
    );
  }
}

class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
        );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Ranking Fabuloso',
        textAlign: TextAlign.center,
        style: titleStyle,
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  const _PodiumWidget({required this.repartidores});

  final List<Repartidor> repartidores;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PodiumPlaceWidget(
            repartidor: repartidores[1],
            borderColor: const Color(0xFFC0C0C0),
            podiumHeight: 80,
            avatarRadius: 30,
          ),
          const SizedBox(width: 10),
          _PodiumPlaceWidget(
            repartidor: repartidores[0],
            borderColor: const Color(0xFFFFD700),
            podiumHeight: 110,
            avatarRadius: 38,
            isFirstPlace: true,
          ),
          const SizedBox(width: 10),
          _PodiumPlaceWidget(
            repartidor: repartidores[2],
            borderColor: const Color(0xFFCD7F32),
            podiumHeight: 60,
            avatarRadius: 30,
          ),
        ],
      ),
    );
  }
}

class _PodiumPlaceWidget extends StatelessWidget {
  const _PodiumPlaceWidget({
    required this.repartidor,
    required this.borderColor,
    required this.podiumHeight,
    required this.avatarRadius,
    this.isFirstPlace = false,
  });

  final Repartidor repartidor;
  final Color borderColor;
  final double podiumHeight;
  final double avatarRadius;
  final bool isFirstPlace;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirstPlace)
          Transform.rotate(
            angle: -math.pi / 20,
            child: const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
          )
        else
          const SizedBox(height: 32),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: avatarRadius + 3,
          backgroundColor: borderColor,
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey[800],
            child: Text(
              repartidor.nombre.substring(0, 2).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: avatarRadius * 0.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          repartidor.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${repartidor.entregas} Entregas',
          style: TextStyle(
            color: isFirstPlace ? const Color(0xFFFFD700) : Colors.grey[400],
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: podiumHeight,
          width: 85,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              '#${repartidor.rank}',
              style: TextStyle(
                color: borderColor,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingListItem extends StatelessWidget {
  const _RankingListItem({required this.repartidor});

  final Repartidor repartidor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        children: [
          Text(
            '#${repartidor.rank}',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
            child: Text(
              repartidor.nombre.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repartidor.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${repartidor.entregas} Entregas',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${repartidor.rating} ★',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${repartidor.tiempoPromedio} min',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YourPositionBar extends StatelessWidget {
  const _YourPositionBar({required this.usuarioActual, required this.goldColor});

  final Repartidor usuarioActual;
  final Color goldColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: goldColor.withOpacity(0.5), width: 2),
        ),
      ),
      child: Row(
        children: [
          Text(
            '#${usuarioActual.rank}',
            style: TextStyle(
              color: goldColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: goldColor,
            child: Text(
              usuarioActual.nombre.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu Puesto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${usuarioActual.entregas} Entregas',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${usuarioActual.rating} ★',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${usuarioActual.tiempoPromedio} min',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

