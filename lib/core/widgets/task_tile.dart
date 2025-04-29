import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as custom_date_utils;
import '../../data/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool?>? onToggleComplete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onToggleComplete,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            if (task.reminder != null)
              Text(
                'Reminder: ${custom_date_utils.CustomDateUtils.formatDateTime(task.reminder!)}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
