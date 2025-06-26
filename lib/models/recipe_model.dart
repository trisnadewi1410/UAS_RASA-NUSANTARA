import 'dart:io';
import 'package:flutter/material.dart';

class Recipe {
  final int? id;
  final String title;
  final String description;
  final String ingredients;
  final String steps;
  final String? imagePath;
  final int? userId;
  final String? origin;

  Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.imagePath,
    required this.userId,
    this.origin,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      ingredients: map['ingredients'],
      steps: map['steps'],
      imagePath: map['imagePath'],
      userId: map['userId'],
      origin: map['origin'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'imagePath': imagePath,
      'userId': userId,
      'origin': origin,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Helper untuk menampilkan gambar dari asset/file
  static Widget buildImage(String? imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.image, size: 60, color: Colors.grey);
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
      );
    } else {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
      );
    }
  }
}
