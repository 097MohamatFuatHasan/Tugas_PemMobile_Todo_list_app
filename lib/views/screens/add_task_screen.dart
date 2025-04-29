import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../core/utils/date_utils.dart' as custom_date_utils;
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/date_picker.dart';
import '../../data/models/task_model.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  final TaskController controller;

  const AddTaskScreen({super.key, this.task, required this.controller});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TaskController _controller;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;

  TimeOfDay? _reminderTime;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();
    _controller = TaskController();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _initializeReminder();
  }

  void _initializeReminder() {
    _reminderDateTime = widget.task?.reminder;
    if (_reminderDateTime != null) {
      _reminderTime = TimeOfDay.fromDateTime(_reminderDateTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _reminderTime = pickedTime;
        _reminderDateTime = custom_date_utils
            .CustomDateUtils.combineDateAndTime(
          _dueDate,
          DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute),
        );
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final newTask = Task(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      dueDate: _dueDate,
      reminder: _reminderDateTime,
      isCompleted: false,
    );

    try {
      await _controller.addTask(newTask);

      // Kosongkan form setelah menyimpan task
      _titleController.clear();
      _descriptionController.clear();
      _dueDate = DateTime.now(); // Reset due date jika perlu
      _reminderTime = null; // Reset reminder jika perlu
      _reminderDateTime = null;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
            tooltip: 'Save Task',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title*',
                      border: OutlineInputBorder(),
                      hintText: 'Enter task title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Enter task description (optional)',
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 20),
                  const Text('Due Date:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  DatePickerWidget(
                    initialDate: _dueDate,
                    onDateSelected: (date) {
                      if (mounted) {
                        setState(() {
                          _dueDate = date;
                          if (_reminderTime != null) {
                            _reminderDateTime = custom_date_utils
                                .CustomDateUtils.combineDateAndTime(
                              date,
                              DateTime(
                                0,
                                0,
                                0,
                                _reminderTime!.hour,
                                _reminderTime!.minute,
                              ),
                            );
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Reminder:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _selectReminderTime(context),
                        child: Text(
                          _reminderTime != null
                              ? DateFormat('h:mm a').format(
                                DateTime(
                                  0,
                                  0,
                                  0,
                                  _reminderTime!.hour,
                                  _reminderTime!.minute,
                                ),
                              )
                              : 'Set Reminder',
                        ),
                      ),
                      if (_reminderTime != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _reminderTime = null;
                                _reminderDateTime = null;
                              });
                            }
                          },
                          tooltip: 'Clear reminder',
                        ),
                      ],
                    ],
                  ),
                  if (_reminderDateTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Reminder set for ${custom_date_utils.CustomDateUtils.formatDateTime(_reminderDateTime!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
