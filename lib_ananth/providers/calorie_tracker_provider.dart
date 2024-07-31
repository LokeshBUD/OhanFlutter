// lib/providers/calorie_tracker_provider.dart
import 'package:flutter/material.dart';
import 'package:calorietracker/models/food_item.dart';

class Meal {
  List<FoodItem> items;

  Meal() : items = [];
}

class CalorieTrackerProvider with ChangeNotifier {
  Meal breakfast = Meal();
  Meal lunch = Meal();
  Meal dinner = Meal();

  void addFoodItem(Meal meal, FoodItem item) {
    if (item != null) {
      meal.items.add(item);
      notifyListeners();
    } else {
      print('Attempted to add a null FoodItem');
    }
  }

  void removeFoodItem(Meal meal, int index) {
    if (meal.items.isNotEmpty && index < meal.items.length) {
      meal.items.removeAt(index);
      notifyListeners();
    } else {
      print('Invalid index or empty meal items');
    }
  }

  int getTotalCalories() {
    return (breakfast.items.fold(0, (sum, item) => sum + item.calories) as int) +
        (lunch.items.fold(0, (sum, item) => sum + item.calories) as int) +
        (dinner.items.fold(0, (sum, item) => sum + item.calories) as int);
  }
}
