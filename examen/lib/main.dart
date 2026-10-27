import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/character_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/auth_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verifica si hay un usuario logueado antes de mostrar cualquier pantalla
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterProvider(),
      child: MaterialApp(
        title: 'Los Simpson App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          useMaterial3: true,
        ),
        // Si está logueado va al Home, si no, al Login
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}