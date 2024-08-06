// lib/services/nutrition_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/food_item.dart';

Future<List<FoodItem>> fetchFoodItemData(String foodName) async {
  final apiKey = 'gHvifuKBEkQQzpCyevX0dlgRNPGQjLTWDKjen93b';
  final response = await http.get(
    Uri.parse('https://api.calorieninjas.com/v1/nutrition?query=$foodName'),
    headers: {'X-Api-Key': apiKey},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Response data: $data'); // Debugging statement

    if (data['items'] != null && data['items'].isNotEmpty) {
      final items = data['items'] as List<dynamic>;
      print('Items data: $items'); // Debugging statement

      return items.map((item) {
        return FoodItem(
          name: item['name'] ?? 'Unknown',
          calories: item['calories']?.toInt() ?? 0,
        );
      }).toList();
    } else {
      print('No items found');
    }
  } else {
    print('Failed to fetch data: ${response.statusCode}');
  }
  return [];
}
