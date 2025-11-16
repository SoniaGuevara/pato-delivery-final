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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
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
              const Text(
                'Pedidos entrantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (state.pendientes.isEmpty)
                _buildEmptyState('No hay pedidos esperando tu respuesta'),
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
              const Text(
                'Historial reciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (state.gestionados.isEmpty)
                _buildEmptyState('Acepta o rechaza pedidos para verlos aquí'),
              ...state.gestionados.map(_buildHistorialTile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60),
      ),
    );
  }

  Widget _buildPedidoCard(
    BuildContext context,
    Pedido pedido, {
    required VoidCallback aceptar,
    required VoidCallback rechazar,
  }) {
    return Card(
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pedido.restaurante,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text('Dirección: ${pedido.direccion}',
                style: const TextStyle(color: Colors.white70)),
            Text('Contacto: ${pedido.repartidor}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: pedido.items
                  .map(
                    (item) => Chip(
                      backgroundColor: Colors.grey.shade800,
                      label: Text(item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: aceptar,
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      foregroundColor: Colors.black,
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

  Widget _buildHistorialTile(Pedido pedido) {
    final esAceptado = pedido.estado == 'Aceptado';
    final color = esAceptado ? Colors.greenAccent : Colors.redAccent;
    final icon = esAceptado ? Icons.check_circle : Icons.cancel;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(pedido.restaurante),
      subtitle: Text('Total: \$${pedido.total.toStringAsFixed(2)}'),
      trailing: Text(
        pedido.estado,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
