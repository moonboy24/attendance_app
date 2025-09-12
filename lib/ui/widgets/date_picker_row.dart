import 'package:flutter/material.dart';


class DatePickerField extends StatefulWidget {
final Function(DateTime) onDateSelected;
final DateTime? initialDate;


const DatePickerField({super.key, required this.onDateSelected, this.initialDate});


@override
State<DatePickerField> createState() => _DatePickerFieldState();
}


class _DatePickerFieldState extends State<DatePickerField> {
late TextEditingController _controller;
DateTime? _selectedDate;


@override
void initState() {
super.initState();
_selectedDate = widget.initialDate;
_controller = TextEditingController(
text: _selectedDate != null ? _formatDate(_selectedDate!) : '',
);
}


String _formatDate(DateTime date) {
return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}


Future<void> _pickDate() async {
final picked = await showDatePicker(
context: context,
initialDate: _selectedDate ?? DateTime.now(),
firstDate: DateTime(2000),
lastDate: DateTime(2100),
);


if (picked != null) {
setState(() {
_selectedDate = picked;
_controller.text = _formatDate(picked);
});
widget.onDateSelected(picked);
}
}


@override
Widget build(BuildContext context) {
return TextField(
controller: _controller,
readOnly: true,
decoration: const InputDecoration(
labelText: "Select Date",
suffixIcon: Icon(Icons.calendar_today),
),
onTap: _pickDate,
);
}
}