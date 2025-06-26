import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/models/recipe_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'myapp.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        imagePath TEXT,
        userId INTEGER,
        origin TEXT,
        location TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // User Methods
  Future<int> addUser(User user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<User?> getUser({
    required String username,
    required String password,
  }) async {
    Database db = await instance.database;
    var res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;
    var res = await db.query('users');
    return res.isNotEmpty ? res.map((e) => User.fromMap(e)).toList() : [];
  }

  // Recipe Methods
  Future<int> addRecipe(Recipe recipe) async {
    Database db = await instance.database;
    return await db.insert('recipes', recipe.toMap());
  }

  Future<List<Recipe>> getRecipes(int userId) async {
    Database db = await instance.database;
    var recipes = await db.query(
      'recipes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<Recipe> recipeList =
        recipes.isNotEmpty
            ? recipes.map((c) => Recipe.fromMap(c)).toList()
            : [];
    return recipeList;
  }

  Future<int> updateRecipe(Recipe recipe) async {
    Database db = await instance.database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    Database db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Recipe>> getAllRecipes() async {
    Database db = await instance.database;
    var recipes = await db.query('recipes');
    return recipes.isNotEmpty
        ? recipes.map((c) => Recipe.fromMap(c)).toList()
        : [];
  }
}

Future<void> tambahResep({
  required String asalMasakan,
  required String bahanBahan,
  required String deskripsi,
  required String judulResep,
  required String langkahLangkah,
}) async {
  await FirebaseFirestore.instance.collection('Tambah Resep').add({
    'Asal Masakan': asalMasakan,
    'Bahan-Bahan': bahanBahan,
    'Deskripsi': deskripsi,
    'Judul Resep': judulResep,
    'Langkah-Langkah': langkahLangkah,
  });
}

class Resep {
  final String asalMasakan;
  final String bahanBahan;
  final String deskripsi;
  final String judulResep;
  final String langkahLangkah;

  Resep({
    required this.asalMasakan,
    required this.bahanBahan,
    required this.deskripsi,
    required this.judulResep,
    required this.langkahLangkah,
  });

  Map<String, dynamic> toMap() => {
    'Asal Masakan': asalMasakan,
    'Bahan-Bahan': bahanBahan,
    'Deskripsi': deskripsi,
    'Judul Resep': judulResep,
    'Langkah-Langkah': langkahLangkah,
  };

  factory Resep.fromMap(Map<String, dynamic> map) => Resep(
    asalMasakan: map['Asal Masakan'] ?? '',
    bahanBahan: map['Bahan-Bahan'] ?? '',
    deskripsi: map['Deskripsi'] ?? '',
    judulResep: map['Judul Resep'] ?? '',
    langkahLangkah: map['Langkah-Langkah'] ?? '',
  );
}
