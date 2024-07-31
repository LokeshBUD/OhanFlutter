// lib/components/custom_input.dart
import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  CustomInput({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
