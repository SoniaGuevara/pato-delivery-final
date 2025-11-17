import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/perfil/perfil_bloc.dart';
import '../bloc/perfil/perfil_event.dart';
import '../bloc/perfil/perfil_state.dart';
import '../bloc/ranking/ranking_bloc.dart';
import '../bloc/ranking/ranking_event.dart';
import '../models/perfil_usuario.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const _panelColor = Color(0xFF111111);
  static const _fieldColor = Color(0xFF1C1C1E);
  static const double _statCardHeight = 150;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PerfilBloc, PerfilState>(
          listenWhen: (previous, current) =>
              previous.mensaje != current.mensaje || previous.error != current.error,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state.mensaje != null) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(state.mensaje!),
                  backgroundColor: Colors.green.shade600,
                ),
              );
              context.read<PerfilBloc>().add(const PerfilNotificacionesLimpiadas());
            } else if (state.error != null) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red.shade600,
                ),
              );
              context.read<PerfilBloc>().add(const PerfilNotificacionesLimpiadas());
            }
          },
        ),
        BlocListener<PerfilBloc, PerfilState>(
          listenWhen: (previous, current) {
            final prevPerfil = previous.perfil;
            final currPerfil = current.perfil;
            if (prevPerfil == null || currPerfil == null) {
              return false;
            }
            return prevPerfil.nombreCompleto != currPerfil.nombreCompleto ||
                prevPerfil.fotoUrl != currPerfil.fotoUrl;
          },
          listener: (context, state) {
            final perfil = state.perfil;
            if (perfil == null) return;
            context.read<RankingBloc>().add(ActualizarDatosUsuarioActual(
                  nombre: perfil.nombreCompleto,
                  avatarUrl: perfil.fotoUrl.isEmpty ? null : perfil.fotoUrl,
                ));
          },
        ),
      ],
      child: BlocBuilder<PerfilBloc, PerfilState>(
        builder: (context, state) {
          final perfil = state.perfil;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text(
                'Mi Perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.black,
              foregroundColor: Colors.amber,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar sesión',
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                ),
              ],
            ),
            body: _buildBody(context, state, perfil),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PerfilState state, PerfilUsuario? perfil) {
    if (state.status == PerfilStatus.loading || perfil == null) {
      final isSignedOut = state.status == PerfilStatus.signedOut;
      return Center(
        child: isSignedOut
            ? const Text(
                'Inicia sesión para ver tu perfil',
                style: TextStyle(color: Colors.white70),
              )
            : const CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, state, perfil),
            const SizedBox(height: 24),
            _buildAvailability(context, perfil, state),
            const SizedBox(height: 24),
            _buildStats(perfil),
            const SizedBox(height: 24),
            _buildInfoDetails(perfil),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, PerfilState state, PerfilUsuario perfil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.amber.withOpacity(0.15),
                backgroundImage: perfil.tieneFoto ? NetworkImage(perfil.fotoUrl) : null,
                child: perfil.tieneFoto
                    ? null
                    : const Icon(Icons.person, color: Colors.amber, size: 48),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: state.subiendoFoto ? null : () => _seleccionarFoto(context),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.amber,
                    child: state.subiendoFoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            perfil.nombreCompleto,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            perfil.email,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.guardando ? null : () => _mostrarEditorPerfil(context, perfil),
            icon: const Icon(Icons.edit),
            label: Text(state.guardando ? 'Guardando...' : 'Editar datos'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailability(
      BuildContext context, PerfilUsuario perfil, PerfilState state) {
    const opciones = [
      _DisponibilidadOption('online', 'Disponible', Icons.flash_on, Colors.green),
      _DisponibilidadOption('busy', 'Ocupado', Icons.schedule, Colors.orange),
      _DisponibilidadOption('offline', 'Fuera de servicio', Icons.bedtime, Colors.redAccent),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponibilidad',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: opciones.map((opcion) {
              final selected = opcion.valor == perfil.disponibilidad;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(opcion.icono, size: 16,
                        color: selected ? Colors.black : opcion.color),
                    const SizedBox(width: 6),
                    Text(opcion.texto),
                  ],
                ),
                selected: selected,
                labelStyle: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: selected
                    ? null
                    : (_) => context
                        .read<PerfilBloc>()
                        .add(PerfilCambiarDisponibilidad(opcion.valor)),
                selectedColor: Colors.amber,
                backgroundColor: _fieldColor,
                side: BorderSide(color: opcion.color.withOpacity(0.5)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(PerfilUsuario perfil) {
    final registro =
        '${perfil.fechaRegistro.day}/${perfil.fechaRegistro.month}/${perfil.fechaRegistro.year}';
    final cards = [
      _StatCard(
        title: 'Calificación',
        value: perfil.rating.toStringAsFixed(1),
        icon: Icons.star,
        subtitle: 'Promedio de clientes',
        color: Colors.amber,
        height: _statCardHeight,
      ),
      _StatCard(
        title: 'Entregas',
        value: perfil.totalEntregas.toString(),
        icon: Icons.local_shipping,
        subtitle: 'Completadas',
        color: Colors.greenAccent,
        height: _statCardHeight,
      ),
      _StatCard(
        title: 'Alta',
        value: registro,
        icon: Icons.calendar_month,
        subtitle: 'Fecha de registro',
        color: Colors.blueAccent,
        height: _statCardHeight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = _statColumnsForWidth(maxWidth);
        const spacing = 16.0;
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  int _statColumnsForWidth(double maxWidth) {
    if (maxWidth >= 900) return 3;
    if (maxWidth >= 600) return 2;
    return 1;
  }

  Widget _buildInfoDetails(PerfilUsuario perfil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos personales',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(Icons.phone, 'Teléfono',
              perfil.telefono.isEmpty ? 'Agrega un teléfono' : perfil.telefono),
          _buildInfoTile(Icons.badge, 'DNI',
              perfil.dni.isEmpty ? 'Completa tu documento' : perfil.dni),
          _buildInfoTile(Icons.email, 'Email', perfil.email),
          _buildInfoTile(Icons.wifi_tethering, 'Estado actual', perfil.disponibilidadLegible),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fieldColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFoto(BuildContext context) async {
    final bloc = context.read<PerfilBloc>();
    final picker = ImagePicker();
    final archivo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (archivo != null) {
      bloc.add(PerfilFotoSeleccionada(archivo));
    }
  }

  Future<void> _mostrarEditorPerfil(BuildContext context, PerfilUsuario perfil) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panelColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _PerfilEditorSheet(perfil: perfil),
    );
  }

}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.subtitle,
    required this.color,
    required this.height,
  });

  final String title;
  final String value;
  final IconData icon;
  final String subtitle;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: PerfilScreen._panelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PerfilEditorSheet extends StatefulWidget {
  const _PerfilEditorSheet({required this.perfil});

  final PerfilUsuario perfil;

  @override
  State<_PerfilEditorSheet> createState() => _PerfilEditorSheetState();
}

class _PerfilEditorSheetState extends State<_PerfilEditorSheet> {
  late final TextEditingController _nombreController;
  late final TextEditingController _dniController;
  late final TextEditingController _telefonoController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.perfil.nombreCompleto);
    _dniController = TextEditingController(text: widget.perfil.dni);
    _telefonoController = TextEditingController(text: widget.perfil.telefono);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Editar datos',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildEditorTextField(
                controller: _nombreController,
                label: 'Nombre y apellido',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa tu nombre'
                    : null,
              ),
              _buildEditorTextField(
                controller: _dniController,
                label: 'DNI',
              ),
              _buildEditorTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<PerfilBloc>().add(PerfilGuardarDatosBasicos(
                          nombre: _nombreController.text,
                          dni: _dniController.text,
                          telefono: _telefonoController.text,
                        ));
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisponibilidadOption {
  const _DisponibilidadOption(this.valor, this.texto, this.icono, this.color);

  final String valor;
  final String texto;
  final IconData icono;
  final Color color;
}

Widget _buildEditorTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: PerfilScreen._fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
    ),
  );
}
