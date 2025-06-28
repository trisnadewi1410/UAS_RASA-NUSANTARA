import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';

class UserProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    try {
      User? localUser = await _databaseHelper.getUser(
        username: username,
        password: password,
      );
      if (localUser != null) {
        _currentUser = localUser;
        notifyListeners();
        return true;
      } else {
        _setError('Username atau password salah');
        return false;
      }
    } catch (e) {
      _setError('Gagal login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(String username, String password) async {
    _setLoading(true);
    _clearError();
    try {
      User newUser = User(username: username, password: password);
      int localId = await _databaseHelper.addUser(newUser);
      if (localId > 0) {
        _currentUser = User(id: localId, username: username, password: password);
        notifyListeners();
        return true;
      } else {
        _setError('Gagal mendaftar');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed') || e.toString().contains('Username sudah ada')) {
        _setError('Username ini sudah terdaftar. Coba username lain.');
      } else {
        _setError('Gagal mendaftar: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  Future<void> loadUserFromLocal(int userId) async {
    try {
      // Implementasi sederhana: hanya set id user
      _currentUser = User(id: userId, username: 'User', password: '');
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat data user');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearData() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
