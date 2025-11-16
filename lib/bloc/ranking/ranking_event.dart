import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

class CargarRanking extends RankingEvent {
  const CargarRanking();
}

class RegistrarEntregaUsuarioActual extends RankingEvent {
  const RegistrarEntregaUsuarioActual();
}
