import '../data/models/task_model.dart';
import '../data/repositories/task_repository.dart';

class TaskController {
  final TaskRepository _repository = TaskRepository();
  List<Task> _tasks = [];

  Future<void> loadTasks() async {
    _tasks = await _repository.getTasks();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _repository.saveTasks(_tasks);
  }

  List<Task> get tasks => _tasks;

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _repository.saveTasks(_tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _repository.saveTasks(_tasks);
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      await _repository.saveTasks(_tasks);
    }
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    await _repository.clearAllTasks();
  }
}
