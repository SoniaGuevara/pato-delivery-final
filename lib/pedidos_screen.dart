import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_event.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';

const _pedidosBackground = Colors.black;
const _pedidoCardColor = Color(0xFF1F1F1F);
const _chipColor = Color(0xFF333333);

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _pedidosBackground,
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocBuilder<PedidosBloc, PedidosState>(
        builder: (context, state) {
          if (state.cargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.mensajeError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.mensajeError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              Text(
                'Pedidos entrantes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (state.pendientes.isEmpty) ...[
                _buildEmptyState(
                    context, 'No hay pedidos esperando tu respuesta'),
              ] else ...[
                ...state.pendientes.map(
                  (pedido) => _buildPedidoCard(
                    context,
                    pedido,
                    aceptar: () =>
                        context.read<PedidosBloc>().add(AceptarPedido(pedido)),
                    rechazar: () =>
                        context.read<PedidosBloc>().add(RechazarPedido(pedido)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Text(
                'Historial reciente',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (state.gestionados.isEmpty)
                _buildEmptyState(
                    context, 'Acepta o rechaza pedidos para verlos aquí'),
              ...state.gestionados.map((pedido) => _buildHistorialTile(
                    context,
                    pedido,
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pedidoCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildPedidoCard(
    BuildContext context,
    Pedido pedido, {
    required VoidCallback aceptar,
    required VoidCallback rechazar,
  }) {
    final textStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _pedidoCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.restaurante,
                      style: textStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pedido.direccion,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Contacto: ${pedido.repartidor}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: pedido.items
                .map(
                  (item) => Chip(
                    backgroundColor: _chipColor,
                    label: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: aceptar,
                  icon: const Icon(Icons.check),
                  label: const Text('Aceptar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: rechazar,
                  icon: const Icon(Icons.close),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirDetallePedido(BuildContext context, Pedido pedido) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PedidoDetalleScreen(pedido: pedido),
      ),
    );
  }

  Widget _buildHistorialTile(BuildContext context, Pedido pedido) {
    final esRechazado = pedido.estado == 'Rechazado';
    final esEntregado = pedido.estado == 'Entregado';
    final esEnCurso = pedido.estado == 'En curso';
    final color = esEntregado
        ? Colors.green.shade600
        : esEnCurso
            ? Colors.orange.shade700
            : Colors.redAccent;
    final icon = esEntregado
        ? Icons.check_circle
        : esEnCurso
            ? Icons.delivery_dining
            : Icons.cancel;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _pedidoCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: esRechazado ? null : () => _abrirDetallePedido(context, pedido),
        enabled: !esRechazado,
        leading: Icon(icon, color: color),
        title: Text(
          pedido.restaurante,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Total: \$${pedido.total.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Text(
          pedido.estado,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PedidoDetalleScreen extends StatelessWidget {
  const PedidoDetalleScreen({super.key, required this.pedido});

  final Pedido pedido;

  void _copiarDireccion(BuildContext context, Pedido pedidoActual) {
    Clipboard.setData(ClipboardData(text: pedidoActual.direccion));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dirección copiada al portapapeles')),
    );
  }

  void _marcarComoEntregado(BuildContext context, Pedido pedidoActual) {
    context
        .read<PedidosBloc>()
        .add(MarcarPedidoEntregado(pedidoActual.id));
    context
        .read<RankingBloc>()
        .add(const RegistrarEntregaUsuarioActual());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido marcado como entregado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidosBloc, PedidosState>(
      buildWhen: (previous, current) => previous.gestionados != current.gestionados,
      builder: (context, state) {
        final pedidoActual = state.gestionados.firstWhere(
          (p) => p.id == pedido.id,
          orElse: () => pedido,
        );
        final entregado = pedidoActual.estado == 'Entregado';

        return Scaffold(
          backgroundColor: _pedidosBackground,
          appBar: AppBar(
            title: const Text('Detalles del pedido'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.amber,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pedidoActual.restaurante,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    Chip(
                      avatar: Icon(
                        entregado ? Icons.check_circle : Icons.delivery_dining,
                        color: Colors.white,
                      ),
                      label: Text(
                        pedidoActual.estado,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          entregado ? Colors.green.shade600 : Colors.orange.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on,
                  label: 'Dirección',
                  value: pedidoActual.direccion,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  icon: Icons.person,
                  label: 'Contacto',
                  value: pedidoActual.repartidor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Artículos',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...pedidoActual.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.fastfood, color: Colors.amber),
                    title: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
                SwitchListTile.adaptive(
                  value: entregado,
                  onChanged: entregado
                      ? null
                      : (value) {
                          if (value) {
                            _marcarComoEntregado(context, pedidoActual);
                          }
                        },
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Marcar como entregado',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    entregado
                        ? 'Este pedido ya fue completado'
                        : 'Actívalo cuando hayas entregado el pedido',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _copiarDireccion(context, pedidoActual),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar dirección'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pedidoCardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
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
                  label,
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
}
