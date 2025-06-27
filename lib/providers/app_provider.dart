import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipe_provider.dart';
import 'user_provider.dart';

class AppProvider with ChangeNotifier {
  final RecipeProvider recipeProvider = RecipeProvider();
  final UserProvider userProvider = UserProvider();

  AppProvider() {
    recipeProvider.addListener(() {
      notifyListeners();
    });
  }

  bool _isInitialized = false;
  String? _error;
  
  // Settings
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'id'; // 'id' for Indonesian, 'en' for English
  String _themeColor = 'brown'; // default

  // Getters
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => userProvider.isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  String get themeColor => _themeColor;

  String? _snackBarMessage;
  String? get snackBarMessage => _snackBarMessage;

  void showSnackBarMessage(String message) {
    _snackBarMessage = message;
    notifyListeners();
  }

  void clearSnackBarMessage() {
    _snackBarMessage = null;
    // No need to notify listeners, as this is a consuming action
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Initialize app and check login status
  Future<void> initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load settings
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _language = prefs.getString('language') ?? 'id';
      _themeColor = prefs.getString('themeColor') ?? 'brown';
      
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');

      if (userId != null && username != null) {
        // User is logged in, load user data
        await userProvider.loadUserFromLocal(userId);

        // Load user's recipes
        await recipeProvider.loadUserRecipes(userId);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menginisialisasi aplikasi';
      notifyListeners();
    }
  }

  // Settings methods
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    setTabIndex(3);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }

  Future<void> setThemeColor(String color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', color);
    notifyListeners();
  }

  // Login with automatic recipe loading
  Future<bool> login(String username, String password) async {
    final success = await userProvider.login(username, password);

    if (success && userProvider.currentUser != null) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userProvider.currentUser!.id!);
      await prefs.setString('username', username);

      // Load user's recipes
      await recipeProvider.loadUserRecipes(userProvider.currentUser!.id!);
    }

    return success;
  }

  // Register with automatic login
  Future<bool> register(String username, String password) async {
    final success = await userProvider.register(username, password);

    if (success && userProvider.currentUser != null) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userProvider.currentUser!.id!);
      await prefs.setString('username', username);
    }

    return success;
  }

  // Logout with cleanup
  Future<void> logout() async {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear all providers
    userProvider.clearData();
    recipeProvider.clearData();

    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData() async {
    if (userProvider.currentUser != null) {
      await recipeProvider.loadUserRecipes(userProvider.currentUser!.id!);
      await recipeProvider.loadAllRecipes();
      debugPrint('Data berhasil di-refresh dari database lokal.');
    }
  }

  // Error handling
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
