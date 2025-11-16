import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 BLoCs
import 'package:pato_delivery_final/bloc/auth/auth_bloc.dart';
import 'package:pato_delivery_final/bloc/auth/auth_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_bloc.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_event.dart';
import 'package:pato_delivery_final/bloc/pedidos/pedidos_state.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_bloc.dart';
import 'package:pato_delivery_final/bloc/ranking/ranking_event.dart';

// 🔹 Repositorios
import 'package:pato_delivery_final/repositories/pedidos_repository.dart';
import 'package:pato_delivery_final/repositories/ranking_repository.dart';

// 🔹 Pantallas
import 'screens/auth/auth_gate.dart';
import 'home_screen.dart';
import 'pedidos_screen.dart';
import 'perfil_screen.dart';
import 'ranking_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 🔥 Asegura la inicialización de Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => PedidosRepository()),
        RepositoryProvider(create: (_) => const RankingRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          // 🔸 Bloc de Autenticación
          BlocProvider(
            create: (context) =>
            AuthBloc(FirebaseAuth.instance)..add(const AuthSubscriptionRequested()),
          ),

          // 🔸 Bloc de Pedidos
          BlocProvider(
            create: (context) => PedidosBloc(context.read<PedidosRepository>())
              ..add(const SuscribirsePedidos()),
          ),

          // 🔸 Bloc de Ranking
          BlocProvider(
            create: (context) =>
            RankingBloc(context.read<RankingRepository>())..add(const CargarRanking()),
          ),
        ],
        child: MaterialApp(
          title: 'Pato Delivery',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.light,
              primary: Colors.amber,
              secondary: Colors.amber.shade700,
              surface: Colors.grey.shade900,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: Brightness.dark,
              primary: Colors.amber,
              secondary: Colors.amber.shade700,
              surface: Colors.grey.shade900,
              onPrimary: Colors.black,
              onSecondary: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

// 🔹 Pantalla principal con barra inferior
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      PedidosScreen(),
      RankingPage(),
      PerfilScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PedidosBloc, PedidosState>(
      listenWhen: (previous, current) =>
          current.pendientes.length > previous.pendientes.length,
      listener: (_, __) {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.mediumImpact();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BlocBuilder<PedidosBloc, PedidosState>(
          buildWhen: (previous, current) =>
              previous.pendientes.length != current.pendientes.length,
          builder: (context, state) {
            final badgeCount = state.pendientes.length;
            final theme = Theme.of(context);
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.surface,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor:
                  theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
              items: [
                _buildNavItem(icon: Icons.home, label: 'Inicio'),
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  label: 'Pedidos',
                  badgeCount: badgeCount,
                ),
                _buildNavItem(icon: Icons.emoji_events, label: 'Ranking'),
                _buildNavItem(icon: Icons.person, label: 'Perfil'),
              ],
            );
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    return BottomNavigationBarItem(
      icon: _buildIconWithBadge(icon, badgeCount),
      label: label,
    );
  }

  Widget _buildIconWithBadge(IconData icon, int badgeCount) {
    if (badgeCount <= 0) {
      return Icon(icon);
    }

    final display = badgeCount > 9 ? '9+' : badgeCount.toString();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              display,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
