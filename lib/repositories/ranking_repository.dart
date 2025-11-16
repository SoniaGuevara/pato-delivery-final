import 'dart:async';

import 'package:pato_delivery_final/models/ranking_resumen.dart';
import 'package:pato_delivery_final/models/repartidor_model.dart';

class RankingRepository {
  RankingResumen? _resumenActual;

  Future<RankingResumen> obtenerRanking() async {
    if (_resumenActual != null) {
      return _resumenActual!;
    }

    await Future.delayed(const Duration(milliseconds: 600));

    const repartidores = [
      Repartidor(rank: 1, nombre: 'Pato Veloz', entregas: 342, rating: 4.9, tiempoPromedio: 12, avatarUrl: ''),
      Repartidor(rank: 2, nombre: 'Pato Rápido', entregas: 298, rating: 4.8, tiempoPromedio: 14, avatarUrl: ''),
      Repartidor(rank: 3, nombre: 'Pato Express', entregas: 276, rating: 4.7, tiempoPromedio: 15, avatarUrl: ''),
      Repartidor(rank: 4, nombre: 'Pato Turbo', entregas: 245, rating: 4.6, tiempoPromedio: 16, avatarUrl: ''),
      Repartidor(rank: 5, nombre: 'Pato Flash', entregas: 221, rating: 4.5, tiempoPromedio: 18, avatarUrl: ''),
      Repartidor(rank: 6, nombre: 'Pato Correcaminos', entregas: 198, rating: 4.4, tiempoPromedio: 19, avatarUrl: ''),
      Repartidor(rank: 7, nombre: 'Pato Sónico', entregas: 175, rating: 4.8, tiempoPromedio: 15, avatarUrl: ''),
      Repartidor(rank: 8, nombre: 'Pato Usuario', entregas: 156, rating: 4.8, tiempoPromedio: 14, avatarUrl: ''),
    ];

    const usuarioActual = Repartidor(
      rank: 8,
      nombre: 'Pato Usuario',
      entregas: 156,
      rating: 4.8,
      tiempoPromedio: 14,
      avatarUrl: '',
    );

    _resumenActual = const RankingResumen(
      repartidores: repartidores,
      usuarioActual: usuarioActual,
    );

    return _resumenActual!;
  }

  RankingResumen registrarEntregaUsuarioActual() {
    final resumen = _resumenActual;
    if (resumen == null) {
      throw StateError('El ranking aún no ha sido cargado');
    }

    final usuarioActualActualizado =
        resumen.usuarioActual.copyWith(entregas: resumen.usuarioActual.entregas + 1);

    final repartidoresActualizados = resumen.repartidores
        .map((repartidor) => repartidor.nombre == usuarioActualActualizado.nombre
            ? repartidor.copyWith(entregas: usuarioActualActualizado.entregas)
            : repartidor)
        .toList();

    _resumenActual = RankingResumen(
      repartidores: repartidoresActualizados,
      usuarioActual: usuarioActualActualizado,
    );

    return _resumenActual!;
  }
}
