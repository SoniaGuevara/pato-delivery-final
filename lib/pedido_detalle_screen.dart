part of 'pedidos_screen.dart';

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
