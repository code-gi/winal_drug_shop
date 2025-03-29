import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final int price;
  final String image;
  final Color color;
  final String type;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.color,
    required this.type,
  });
}
