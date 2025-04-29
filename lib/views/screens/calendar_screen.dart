import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/task_controller.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/task_tile.dart';
import '../../data/models/task_model.dart';
import '../../core/constants/route_names.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskController _controller = TaskController();
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await _controller.loadTasks();
    setState(() => _isLoading = false);
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _controller.tasks.where((task) {
      return isSameDay(task.dueDate, day) ||
          (task.reminder != null && isSameDay(task.reminder!, day));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,
          ),
          const Divider(height: 1),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _getTasksForDay(_selectedDay);

    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks for this day'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onTap: () async {
            await Navigator.pushNamed(
              context,
              RouteNames.addTask,
              arguments: task,
            );
            _loadTasks();
          },
          onDelete: () async {
            await _controller.deleteTask(task.id);
            _loadTasks();
          },
        );
      },
    );
  }
}
