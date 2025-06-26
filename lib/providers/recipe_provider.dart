import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class RecipeProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Recipe> _recipes = [];
  List<Recipe> _allRecipes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get allRecipes => _allRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // CRUD SQLite Lokal
  Future<void> loadUserRecipes(int userId) async {
    _setLoading(true);
    _clearError();
    try {
      List<Recipe> localRecipes = await _databaseHelper.getRecipes(userId);
      _recipes = localRecipes;
      notifyListeners();
    } catch (e) {
      _setError('Gagal mengambil resep: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllRecipes() async {
    _setLoading(true);
    _clearError();
    try {
      _allRecipes = await _databaseHelper.getAllRecipes();
      notifyListeners();
    } catch (e) {
      _setError('Gagal mengambil semua resep: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addRecipe(Recipe recipe) async {
    _setLoading(true);
    _clearError();
    try {
      int id = await _databaseHelper.addRecipe(recipe);
      if (id > 0) {
        await loadUserRecipes(recipe.userId ?? 0);
        return true;
      } else {
        _setError('Gagal menambah resep');
        return false;
      }
    } catch (e) {
      _setError('Gagal menambah resep: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateRecipe(Recipe recipe) async {
    _setLoading(true);
    _clearError();
    try {
      int result = await _databaseHelper.updateRecipe(recipe);
      if (result > 0) {
        await loadUserRecipes(recipe.userId ?? 0);
        return true;
      } else {
        _setError('Gagal mengupdate resep');
        return false;
      }
    } catch (e) {
      _setError('Gagal mengupdate resep: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteRecipe(int recipeId, int userId) async {
    _setLoading(true);
    _clearError();
    try {
      await _databaseHelper.deleteRecipe(recipeId);
      await loadUserRecipes(userId);
      return true;
    } catch (e) {
      _setError('Gagal menghapus resep: $e');
      return false;
    } finally {
      _setLoading(false);
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
    _recipes = [];
    _allRecipes = [];
    _error = null;
    notifyListeners();
  }

  // Fungsi pencarian fleksibel
  List<Recipe> searchRecipes(String query) {
    final q = query.toLowerCase();
    return _allRecipes.where((recipe) {
      final combined = [
        recipe.title,
        recipe.origin ?? '',
        recipe.description,
        recipe.ingredients,
      ].join(' ').toLowerCase();
      return combined.contains(q);
    }).toList();
  }
}
