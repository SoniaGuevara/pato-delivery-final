import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pato_delivery_final/bloc/perfil/perfil_event.dart';
import 'package:pato_delivery_final/bloc/perfil/perfil_state.dart';
import 'package:pato_delivery_final/models/perfil_usuario.dart';
import 'package:pato_delivery_final/repositories/perfil_repository.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc(this._perfilRepository, this._firebaseAuth)
      : super(const PerfilState()) {
    on<PerfilSubscriptionRequested>(_onSubscriptionRequested);
    on<PerfilAuthStatusChanged>(_onAuthStatusChanged);
    on<PerfilDatosRecibidos>(_onDatosRecibidos);
    on<PerfilGuardarDatosBasicos>(_onGuardarDatosBasicos);
    on<PerfilCambiarDisponibilidad>(_onCambiarDisponibilidad);
    on<PerfilFotoSeleccionada>(_onFotoSeleccionada);
    on<PerfilRegistrarEntrega>(_onRegistrarEntrega);
    on<PerfilNotificacionesLimpiadas>(_onNotificacionesLimpiadas);

    add(const PerfilSubscriptionRequested());
  }

  final PerfilRepository _perfilRepository;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<PerfilUsuario>? _perfilSubscription;

  Future<void> _onSubscriptionRequested(
    PerfilSubscriptionRequested event,
    Emitter<PerfilState> emit,
  ) async {
    await _authSubscription?.cancel();
    _authSubscription =
        _firebaseAuth.authStateChanges().listen((user) => add(PerfilAuthStatusChanged(user)));
  }

  Future<void> _onAuthStatusChanged(
    PerfilAuthStatusChanged event,
    Emitter<PerfilState> emit,
  ) async {
    final user = event.user;
    if (user == null) {
      await _perfilSubscription?.cancel();
      emit(state.copyWith(status: PerfilStatus.signedOut, limpiarPerfil: true));
      return;
    }

    emit(state.copyWith(status: PerfilStatus.loading));
    await _perfilRepository.ensurePerfilExiste(uid: user.uid, email: user.email ?? '');
    await _perfilSubscription?.cancel();
    _perfilSubscription = _perfilRepository
        .escucharPerfil(user.uid)
        .listen((perfil) => add(PerfilDatosRecibidos(perfil)));
  }

  void _onDatosRecibidos(
    PerfilDatosRecibidos event,
    Emitter<PerfilState> emit,
  ) {
    emit(state.copyWith(status: PerfilStatus.loaded, perfil: event.perfil));
  }

  Future<void> _onGuardarDatosBasicos(
    PerfilGuardarDatosBasicos event,
    Emitter<PerfilState> emit,
  ) async {
    final perfil = state.perfil;
    if (perfil == null) return;

    emit(state.copyWith(guardando: true, limpiarMensaje: true, limpiarError: true));
    try {
      await _perfilRepository.actualizarPerfil(perfil.id, {
        'fullName': event.nombre.trim(),
        'dni': event.dni.trim(),
        'phone': event.telefono.trim(),
      });
      emit(state.copyWith(guardando: false, mensaje: 'Datos actualizados'));
    } catch (_) {
      emit(state.copyWith(guardando: false, error: 'No se pudo actualizar el perfil'));
    }
  }

  Future<void> _onCambiarDisponibilidad(
    PerfilCambiarDisponibilidad event,
    Emitter<PerfilState> emit,
  ) async {
    final perfil = state.perfil;
    if (perfil == null || perfil.disponibilidad == event.disponibilidad) {
      return;
    }

    try {
      await _perfilRepository.actualizarDisponibilidad(perfil.id, event.disponibilidad);
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo cambiar la disponibilidad'));
    }
  }

  Future<void> _onFotoSeleccionada(
    PerfilFotoSeleccionada event,
    Emitter<PerfilState> emit,
  ) async {
    final perfil = state.perfil;
    if (perfil == null) return;

    emit(state.copyWith(subiendoFoto: true, limpiarMensaje: true, limpiarError: true));
    try {
      final Uint8List bytes = await event.archivo.readAsBytes();
      final extension = event.archivo.name.split('.').last.toLowerCase();
      final url = await _perfilRepository.subirFotoPerfil(
        uid: perfil.id,
        bytes: bytes,
        extension: extension.isEmpty ? 'jpg' : extension,
      );
      await _perfilRepository.actualizarPerfil(perfil.id, {'photoUrl': url});
      emit(state.copyWith(subiendoFoto: false, mensaje: 'Foto actualizada correctamente'));
    } catch (_) {
      emit(state.copyWith(subiendoFoto: false, error: 'No se pudo subir la foto'));
    }
  }

  Future<void> _onRegistrarEntrega(
    PerfilRegistrarEntrega event,
    Emitter<PerfilState> emit,
  ) async {
    final perfil = state.perfil;
    if (perfil == null) return;

    try {
      await _perfilRepository.incrementarEntregas(perfil.id);
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo actualizar tus entregas')); 
    }
  }

  void _onNotificacionesLimpiadas(
    PerfilNotificacionesLimpiadas event,
    Emitter<PerfilState> emit,
  ) {
    if (state.mensaje == null && state.error == null) {
      return;
    }
    emit(state.copyWith(limpiarMensaje: true, limpiarError: true));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _perfilSubscription?.cancel();
    return super.close();
  }
}
