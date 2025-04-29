import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
        widget.onDateSelected(selectedDay);
      },
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }
} 