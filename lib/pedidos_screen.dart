import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/models/pedido_model.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ← IMPORTANTE: dispara la carga de pedidos al abrir la pantalla
    context.read<PedidosBloc>().add(CargarPedidos());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PedidosBloc>().add(CargarPedidos());
        },
        child: BlocBuilder<PedidosBloc, PedidosState>(
          builder: (context, state) {
            if (state is PedidosCargando || state is PedidosInicial) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (state is PedidosCargados) {
              if (state.pedidos.isEmpty) {
                return _buildEmptyView();
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.pedidos.length,
                separatorBuilder: (context, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final pedido = state.pedidos[index];
                  return _buildPedidoCard(context, pedido);
                },
              );
            }
            else if (state is PedidosError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 80),
          SizedBox(height: 12),
          Text(
            'Todavía no registras pedidos.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPedidoCard(BuildContext context, Pedido pedido) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {},
        child: Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.black, size: 26),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pedido.restaurante,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          _buildEstadoBadge(pedido.estado),
                          const SizedBox(width: 6),
                          Text(
                            'Total \$${pedido.total.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70),
                          )
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text('Dirección: ${pedido.direccion}',
                          style: const TextStyle(color: Colors.white54)),
                      Text('Repartidor: ${pedido.repartidor}',
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    late Color bgColor;
    late Color textColor;

    switch (estado.toLowerCase()) {
      case 'entregado':
        bgColor = const Color(0xFF4CAF50); // Verde moderno
        textColor = Colors.white;
        break;

      case 'en camino':
        bgColor = const Color(0xFF42A5F5); // Azul cielo
        textColor = Colors.white;
        break;

      case 'preparando':
        bgColor = Colors.amber[700]!.withOpacity(0.15); // Fondo claro ámbar
        textColor = Colors.white;
        break;

      default:
        bgColor = Colors.grey[700]!;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: estado.toLowerCase() == 'preparando'
            ? Border.all(color: Colors.amber[400]!, width: 1.3)
            : null,
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
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
