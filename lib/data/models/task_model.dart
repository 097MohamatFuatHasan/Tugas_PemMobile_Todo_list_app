import 'dart:convert';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? reminder;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.reminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'reminder': reminder?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
      reminder: map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? reminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      reminder: reminder ?? this.reminder,
    );
  }
}