import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_event.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_state.dart';
import 'package:pato_delivery_final/models/ranking_resumen.dart';
import 'package:pato_delivery_final/repositories/ranking_repository.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  RankingBloc(this._rankingRepository) : super(const RankingInicial()) {
    on<CargarRanking>(_onCargarRanking);
    on<RegistrarEntregaUsuarioActual>(_onRegistrarEntrega);
    on<ActualizarDatosUsuarioActual>(_onActualizarDatosUsuarioActual);
  }

  final RankingRepository _rankingRepository;
  ActualizarDatosUsuarioActual? _actualizacionPendiente;

  Future<void> _onCargarRanking(
    CargarRanking event,
    Emitter<RankingState> emit,
  ) async {
    emit(const RankingCargando());

    try {
      final resumen = await _rankingRepository.obtenerRanking();
      RankingResumen resumenFinal = resumen;
      final pendiente = _actualizacionPendiente;
      if (pendiente != null) {
        try {
          resumenFinal = _rankingRepository.actualizarDatosUsuarioActual(
            nombre: pendiente.nombre,
            avatarUrl: pendiente.avatarUrl,
          );
        } catch (_) {
          // Si falla dejamos el resumen base, volverá a intentar en la siguiente actualización.
        }
        _actualizacionPendiente = null;
      }
      emit(RankingCargado(resumenFinal));
    } catch (_) {
      emit(const RankingError('No fue posible cargar el ranking.'));
    }
  }

  void _onRegistrarEntrega(
    RegistrarEntregaUsuarioActual event,
    Emitter<RankingState> emit,
  ) {
    final currentState = state;
    if (currentState is! RankingCargado) return;

    try {
      final actualizado = _rankingRepository.registrarEntregaUsuarioActual();
      emit(RankingCargado(actualizado));
    } catch (_) {
      emit(const RankingError('No fue posible actualizar el ranking.'));
      add(const CargarRanking());
    }
  }

  void _onActualizarDatosUsuarioActual(
    ActualizarDatosUsuarioActual event,
    Emitter<RankingState> emit,
  ) {
    final currentState = state;
    if (event.nombre == null && event.avatarUrl == null) return;
    if (currentState is! RankingCargado) {
      _guardarActualizacionPendiente(event);
      return;
    }

    try {
      final actualizado = _rankingRepository.actualizarDatosUsuarioActual(
        nombre: event.nombre,
        avatarUrl: event.avatarUrl,
      );
      emit(RankingCargado(actualizado));
      _actualizacionPendiente = null;
    } catch (_) {
      // Si falló, re-cargamos el ranking original.
      add(const CargarRanking());
    }
  }

  void _guardarActualizacionPendiente(ActualizarDatosUsuarioActual evento) {
    final actual = _actualizacionPendiente;
    if (actual == null) {
      _actualizacionPendiente = evento;
      return;
    }

    _actualizacionPendiente = ActualizarDatosUsuarioActual(
      nombre: evento.nombre ?? actual.nombre,
      avatarUrl: evento.avatarUrl ?? actual.avatarUrl,
    );
  }
}
