import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../core/constants/route_names.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_tile.dart';
import '../../data/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TaskController _controller;
  late final TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TaskController();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTasks();
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _controller.loadTasks();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load tasks. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _navigateToCalendar(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Completed')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Future<void> _navigateToAddTask(BuildContext context) async {
    await Navigator.pushNamed(context, RouteNames.addTask);
    await _loadTasks();
  }

  Future<void> _navigateToCalendar(BuildContext context) async {
    await Navigator.pushNamed(context, RouteNames.calendar);
  }

  Future<void> _navigateToEditTask(BuildContext context, Task task) async {
    await Navigator.pushNamed(context, RouteNames.addTask, arguments: task);
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await _controller.deleteTask(task.id);
    await _loadTasks();
  }

  Future<void> _toggleTaskCompletion(Task task, bool? value) async {
    await _controller.toggleTaskCompletion(task.id, value ?? false);
    await _loadTasks();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTaskList(_controller.pendingTasks),
        _buildTaskList(_controller.completedTasks),
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return EmptyState(
        message: 'No tasks found',
        actionText: 'Add Task',
        onAction: () => _navigateToAddTask(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            task: task,
            onTap: () => _navigateToEditTask(context, task),
            onDelete: () => _deleteTask(task),
            onToggleComplete: (value) => _toggleTaskCompletion(task, value),
          );
        },
      ),
    );
  }
}
