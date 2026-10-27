import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String _message = '';
  bool _isRegisterMode = false; // Alterna entre login y registro

  void _submit() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _message = 'Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    bool success;
    if (_isRegisterMode) {
      success = await _authService.register(user, pass);
      if (success) {
        setState(() {
          _message = '¡Registro exitoso! Ahora inicia sesión.';
          _isRegisterMode = false;
        });
      }
    } else {
      success = await _authService.login(user, pass);
      if (success) {
        // Navega a la pantalla principal y elimina el login del historial
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() => _message = 'Usuario o contraseña incorrectos.');
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 16),
              Text(
                _isRegisterMode ? 'Crear Cuenta' : 'Iniciar Sesión',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('exitoso') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(_isRegisterMode ? 'Registrarse' : 'Ingresar'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isRegisterMode = !_isRegisterMode;
                              _message = '';
                              _userController.clear();
                              _passController.clear();
                            });
                          },
                          child: Text(
                            _isRegisterMode 
                                ? '¿Ya tienes cuenta? Inicia sesión' 
                                : '¿No tienes cuenta? Regístrate aquí',
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}