import 'package:flutter/material.dart';

class AddTaskDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: 'Task Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final taskName = _controller.text.trim();
            if (taskName.isNotEmpty) {
              Navigator.of(context).pop(taskName);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}