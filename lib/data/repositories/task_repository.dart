import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TaskRepository {
  static const _tasksKey = 'user_tasks';

  Future<List<Task>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return []; // Return empty list instead of throwing error
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      await prefs.setStringList(_tasksKey, tasksJson);
      debugPrint('Saved ${tasks.length} tasks'); // Debug log
    } catch (e) {
      debugPrint('Error saving tasks: $e');
      rethrow;
    }
  }

  Future<void> clearAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('Clearing all tasks from storage');
      await prefs.remove(_tasksKey);
    } catch (e, stackTrace) {
      debugPrint('Error clearing tasks: $e\n$stackTrace');
      throw Exception('Failed to clear tasks: ${e.toString()}');
    }
  }
}
