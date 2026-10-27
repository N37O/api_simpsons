import 'package:flutter/material.dart';
import '../providers/character_provider.dart';

class StateHandler extends StatelessWidget {
  final ViewState state;
  final String errorMessage;
  final VoidCallback onRetry;
  final String emptyMessage;
  final Widget child;

  const StateHandler({
    super.key,
    required this.state,
    required this.errorMessage,
    required this.onRetry,
    required this.emptyMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              )
            ],
          ),
        );
      case ViewState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 50, color: Colors.grey),
              const SizedBox(height: 10),
              Text(emptyMessage, textAlign: TextAlign.center),
            ],
          ),
        );
      case ViewState.success:
        return child;
    }
  }
}