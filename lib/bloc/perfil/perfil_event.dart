import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pato_delivery_final/models/perfil_usuario.dart';

abstract class PerfilEvent extends Equatable {
  const PerfilEvent();

  @override
  List<Object?> get props => [];
}

class PerfilSubscriptionRequested extends PerfilEvent {
  const PerfilSubscriptionRequested();
}

class PerfilAuthStatusChanged extends PerfilEvent {
  const PerfilAuthStatusChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}

class PerfilDatosRecibidos extends PerfilEvent {
  const PerfilDatosRecibidos(this.perfil);

  final PerfilUsuario perfil;

  @override
  List<Object?> get props => [perfil];
}

class PerfilGuardarDatosBasicos extends PerfilEvent {
  const PerfilGuardarDatosBasicos({
    required this.nombre,
    required this.dni,
    required this.telefono,
  });

  final String nombre;
  final String dni;
  final String telefono;

  @override
  List<Object?> get props => [nombre, dni, telefono];
}

class PerfilCambiarDisponibilidad extends PerfilEvent {
  const PerfilCambiarDisponibilidad(this.disponibilidad);

  final String disponibilidad;

  @override
  List<Object?> get props => [disponibilidad];
}

class PerfilFotoSeleccionada extends PerfilEvent {
  const PerfilFotoSeleccionada(this.archivo);

  final XFile archivo;

  @override
  List<Object?> get props => [archivo.path];
}

class PerfilRegistrarEntrega extends PerfilEvent {
  const PerfilRegistrarEntrega();
}

class PerfilNotificacionesLimpiadas extends PerfilEvent {
  const PerfilNotificacionesLimpiadas();
}

class PerfilErrorReportado extends PerfilEvent {
  const PerfilErrorReportado(this.mensaje);

  final String mensaje;

  @override
  List<Object?> get props => [mensaje];
}
