import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.9),
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (state.pendientes.isEmpty)
                _buildEmptyState(context, 'No hay pedidos esperando tu respuesta'),
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
              const SizedBox(height: 32),
              Text(
                'Historial reciente',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildPedidoCard(
    BuildContext context,
    Pedido pedido, {
    required VoidCallback aceptar,
    required VoidCallback rechazar,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      color: colorScheme.surface,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pedido.direccion,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Contacto: ${pedido.repartidor}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${pedido.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
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
                      backgroundColor:
                          colorScheme.secondaryContainer.withOpacity(0.8),
                      label: Text(
                        item,
                        style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialTile(BuildContext context, Pedido pedido) {
    final esAceptado = pedido.estado == 'Aceptado';
    final color = esAceptado ? Colors.green.shade600 : Colors.redAccent;
    final icon = esAceptado ? Icons.check_circle : Icons.cancel;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          pedido.restaurante,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          'Total: \$${pedido.total.toStringAsFixed(2)}',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          pedido.estado,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
