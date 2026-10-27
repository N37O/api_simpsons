import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

enum ViewState { loading, success, error, empty }

class CharacterProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  String? _currentUser;

  List<Character> _allCharacters = [];
  List<Character> _filteredCharacters = [];
  List<Map<String, dynamic>> _favorites = [];

  ViewState _state = ViewState.loading;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  // Getters
  List<Character> get characters => _filteredCharacters;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  List<Map<String, dynamic>> get favorites => _favorites;
  String? get currentUser => _currentUser;

  CharacterProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentUser = await _auth.getCurrentUser();
    await loadCharacters();
    await loadFavorites();
  }

  Future<void> loadCharacters() async {
    _setState(ViewState.loading);
    try {
      final data = await _api.fetchCharacters(_currentPage);
      _allCharacters = data['characters'];
      _totalPages = data['totalPages'];
      _applyFilter();

      if (_allCharacters.isEmpty) {
        _setState(ViewState.empty);
      } else {
        _setState(ViewState.success);
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu internet.';
      _setState(ViewState.error);
    }
  }

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await loadCharacters();
    }
  }

  Future<void> prevPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await loadCharacters();
    }
  }

  void searchCharacters(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCharacters = _allCharacters;
    } else {
      _filteredCharacters = _allCharacters
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filteredCharacters.isEmpty && _allCharacters.isNotEmpty && _searchQuery.isNotEmpty) {
      _state = ViewState.empty;
    } else if (_allCharacters.isNotEmpty) {
      _state = ViewState.success;
    }
    notifyListeners();
  }

  //FAVORITOS
  Future<void> loadFavorites() async {
    if (_currentUser == null) {
      _favorites = [];
      notifyListeners();
      return;
    }
    _favorites = await _db.getFavorites(_currentUser!);
    notifyListeners();
  }

  Future<void> toggleFavorite(Character character) async {
    if (_currentUser == null) {
      debugPrint('No hay usuario logueado');
      return;
    }

    bool isFav = await _db.isFavorite(character.id, _currentUser!);
    if (isFav) {
      await _db.removeFavorite(character.id, _currentUser!);
      debugPrint('Favorito eliminado: ${character.name}');
    } else {
      await _db.addFavorite(character, _currentUser!);
      debugPrint('Favorito agregado: ${character.name}');
    }
    await loadFavorites();
  }

  Future<void> removeFavoriteById(int id) async {
    if (_currentUser == null) return;
    await _db.removeFavorite(id, _currentUser!);
    await loadFavorites();
  }

  Future<bool> isFavorite(int id) async {
    if (_currentUser == null) return false;
    return await _db.isFavorite(id, _currentUser!);
  }

  Future<void> refreshForCurrentUser() async {
    _currentUser = await _auth.getCurrentUser();
    await loadFavorites();
    notifyListeners();
  }
}