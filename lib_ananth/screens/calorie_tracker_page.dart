// lib/screens/calorie_tracker_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calorietracker/models/food_item.dart';
import 'package:calorietracker/providers/calorie_tracker_provider.dart';
import 'package:calorietracker/components/custom_input.dart';
import 'package:calorietracker/components/custom_button.dart';
import 'package:calorietracker/services/nutrition_service.dart';

class CalorieTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalorieTrackerProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Calorie Tracker'),
        ),
        body: CalorieTrackerBody(),
      ),
    );
  }
}

class CalorieTrackerBody extends StatefulWidget {
  @override
  _CalorieTrackerBodyState createState() => _CalorieTrackerBodyState();
}

class _CalorieTrackerBodyState extends State<CalorieTrackerBody> {
  final TextEditingController breakfastController = TextEditingController();
  final TextEditingController lunchController = TextEditingController();
  final TextEditingController dinnerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalorieTrackerProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMealSection(context, 'Breakfast', provider.breakfast, breakfastController, provider),
          _buildMealSection(context, 'Lunch', provider.lunch, lunchController, provider),
          _buildMealSection(context, 'Dinner', provider.dinner, dinnerController, provider),
          SizedBox(height: 20),
          _buildTotalCalories(provider),
        ],
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, String mealName, Meal meal, TextEditingController controller, CalorieTrackerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mealName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: meal.items.length,
          itemBuilder: (context, index) {
            final item = meal.items[index];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Calories: ${item.calories} kcal'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => provider.removeFoodItem(meal, index),
                ),
              ),
            );
          },
        ),
        _buildFoodInputForm(context, meal, controller, provider),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFoodInputForm(BuildContext context, Meal meal, TextEditingController controller, CalorieTrackerProvider provider) {
    return Column(
      children: [
        CustomInput(label: 'Food Item', controller: controller),
        CustomButton(
          label: 'Add Food',
          onPressed: () async {
            final inputText = controller.text;
            if (inputText.isNotEmpty) {
              // Split the input into items based on common delimiters
              final items = inputText.split(RegExp(r',| and | or | \s')).where((item) => item.isNotEmpty).toList();
              
              for (String item in items) {
                // Fetch data for each food item
                final foodItems = await fetchFoodItemData(item.trim());
                if (foodItems != null && foodItems.isNotEmpty) {
                  for (var food in foodItems) {
                    provider.addFoodItem(meal, food);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Food item "$item" not found')),
                  );
                }
              }
              controller.clear(); // Clear the input field after adding the items
            }
          },
        ),
      ],
    );
  }

  Widget _buildTotalCalories(CalorieTrackerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Calories: ${provider.getTotalCalories()} kcal', style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
