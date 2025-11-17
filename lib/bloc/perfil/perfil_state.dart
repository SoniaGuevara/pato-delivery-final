import 'package:equatable/equatable.dart';
import 'package:pato_delivery_final/models/perfil_usuario.dart';

enum PerfilStatus { initial, loading, loaded, signedOut }

class PerfilState extends Equatable {
  const PerfilState({
    this.status = PerfilStatus.initial,
    this.perfil,
    this.guardando = false,
    this.subiendoFoto = false,
    this.mensaje,
    this.error,
  });

  final PerfilStatus status;
  final PerfilUsuario? perfil;
  final bool guardando;
  final bool subiendoFoto;
  final String? mensaje;
  final String? error;

  PerfilState copyWith({
    PerfilStatus? status,
    PerfilUsuario? perfil,
    bool? guardando,
    bool? subiendoFoto,
    String? mensaje,
    String? error,
    bool limpiarMensaje = false,
    bool limpiarError = false,
    bool limpiarPerfil = false,
  }) {
    return PerfilState(
      status: status ?? this.status,
      perfil: limpiarPerfil ? null : (perfil ?? this.perfil),
      guardando: guardando ?? this.guardando,
      subiendoFoto: subiendoFoto ?? this.subiendoFoto,
      mensaje: limpiarMensaje ? null : mensaje ?? this.mensaje,
      error: limpiarError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        perfil,
        guardando,
        subiendoFoto,
        mensaje,
        error,
      ];
}
