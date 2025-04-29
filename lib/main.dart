import 'package:flutter/material.dart';
import 'core/constants/route_names.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/add_task_screen.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/calendar_screen.dart';
import 'controllers/task_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: RouteNames.splash,
      routes: {
        RouteNames.splash: (context) => const SplashScreen(),
        RouteNames.home: (context) => const HomeScreen(),
        RouteNames.addTask:
            (context) => AddTaskScreen(controller: TaskController()),
        RouteNames.calendar: (context) => const CalendarScreen(),
      },
      debugShowCheckedModeBanner: false, // Hilangkan logo debug
    );
  }
}
